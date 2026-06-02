%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GABAERGIC NEURON-SPECIFIC MODEL RECONSTRUCTION
%
% Pipeline:
%   1. Load transcriptomic data
%   2. Load Recon3D
%   3. Convert identifiers
%   4. Map gene expression to reactions
%   5. Generate tissue-specific model using INIT
%   6. Quality control
%   7. Gapfilling
%   8. Functional validation
%   9. Save final model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars;
close all;
clc;

%% ===================================================================== %%
% COBRA TOOLBOX INITIALIZATION
%% ===================================================================== %%

initCobraToolbox(false);
changeCobraSolver('gurobi','all',1);

%% ===================================================================== %%
% LOAD INPUT DATA
%% ===================================================================== %%

fprintf('\nLoading transcriptomic data...\n');

expressionData = readtable( ...
    'GSE115565_norm_counts_TPM_GRCh38.p13_NCBI_2.xls');

fprintf('Loading Recon3D model...\n');

load('Recon3D_301.mat');

%% ===================================================================== %%
% PREPROCESS GENE IDENTIFIERS
%% ===================================================================== %%

fprintf('\nProcessing gene identifiers...\n');

EntrezIDs = cellstr(num2str(expressionData{:,1}));

expressionData = addvars( ...
    expressionData,...
    EntrezIDs,...
    'After',1,...
    'NewVariableNames','EntrezID');

expressionData.EntrezID = ...
    strtrim(expressionData.EntrezID);

%% ===================================================================== %%
% LOAD ENTREZ ↔ ENSEMBL MAPPING
%% ===================================================================== %%

fprintf('Loading Ensembl mapping...\n');

mappingTable = readtable( ...
    'mart_export.txt',...
    'FileType','text',...
    'Delimiter','\t');

EnsemblIDs = cell(height(expressionData),1);

for i = 1:height(expressionData)

    idx = strcmp( ...
        mappingTable{:,2}, ...
        expressionData.EntrezID{i});

    if any(idx)

        EnsemblIDs{i} = ...
            mappingTable{find(idx,1),1};

    else

        EnsemblIDs{i} = '';

    end
end

expressionData = addvars( ...
    expressionData,...
    EnsemblIDs,...
    'Before',1,...
    'NewVariableNames','EnsemblID');

%% ===================================================================== %%
% MAP GENE EXPRESSION TO REACTIONS
%% ===================================================================== %%

fprintf('\nMapping gene expression to reactions...\n');

Recon3D.genes = ...
    regexprep(Recon3D.genes,'\.[0-9]*','');

expressionColumns = ...
    expressionData.Properties.VariableNames;

FinalExpression = table();

for k = 4:length(expressionColumns)

    expressionToMap = ...
        expressionData(:,[2 k]);

    expressionToMap.Properties.VariableNames = ...
        {'gene','value'};

    expressionToMap.gene( ...
        cellfun('isempty',expressionToMap.gene)) = {' '};

    [expressionRxns,~] = ...
        mapExpressionToReactions( ...
        Recon3D,...
        expressionToMap);

    FinalExpression = addvars( ...
        FinalExpression,...
        expressionRxns,...
        'NewVariableNames',...
        expressionColumns{k});

end

FinalExpression.Properties.VariableNames = ...
    expressionColumns(4:end);

%% ===================================================================== %%
% PREPARE INIT INPUT
%% ===================================================================== %%

fprintf('\nPreparing INIT weights...\n');

defaultWeight = -1;

weights = ...
    defaultWeight * ones(length(Recon3D.rxns),1);

% Replace this section with your actual INIT weights
% derived from reaction expression scores.

options = struct();

options.solver = 'INIT';
options.weights = weights;

%% ===================================================================== %%
% GENERATE TISSUE-SPECIFIC MODEL
%% ===================================================================== %%

fprintf('\nGenerating GABAergic neuron model...\n');

GABANEURONModel = ...
    createTissueSpecificModel( ...
    Recon3D,...
    options);

fprintf('Model generated.\n');

fprintf('Reactions: %d\n', ...
    length(GABANEURONModel.rxns));

fprintf('Metabolites: %d\n', ...
    length(GABANEURONModel.mets));

fprintf('Genes: %d\n', ...
    length(GABANEURONModel.genes));

%% ===================================================================== %%
% QUALITY CONTROL
%% ===================================================================== %%

fprintf('\n====================================\n');
fprintf('QUALITY CONTROL\n');
fprintf('====================================\n');

%% Flux consistency

try

    fprintf('\nChecking flux consistency...\n');

    [consistentRxns,inconsistentRxns] = ...
        findFluxConsistentSubset( ...
        GABANEURONModel);

    fprintf('Consistent reactions: %d\n', ...
        length(consistentRxns));

    fprintf('Inconsistent reactions: %d\n', ...
        length(inconsistentRxns));

catch

    warning('Flux consistency analysis failed.');

end

%% Mass balance

try

    fprintf('\nChecking mass balance...\n');

    [imbalancedRxns,balancedRxns] = ...
        checkMassChargeBalance( ...
        GABANEURONModel);

    fprintf('Balanced reactions: %d\n', ...
        sum(balancedRxns));

    fprintf('Imbalanced reactions: %d\n', ...
        length(imbalancedRxns));

catch

    warning('Mass balance analysis failed.');

end

%% Dead-end metabolites

try

    fprintf('\nDetecting dead-end metabolites...\n');

    deadEnds = ...
        detectDeadEnds( ...
        GABANEURONModel);

    fprintf('Dead-end metabolites: %d\n', ...
        length(deadEnds));

catch

    warning('Dead-end analysis failed.');

end

%% ===================================================================== %%
% GAPFILLING
%% ===================================================================== %%

try

    fprintf('\nRunning gapfilling...\n');

    universalModel = Recon3D;

    [gapfilledModel,addedRxns] = ...
        fastGapFill( ...
        GABANEURONModel,...
        universalModel,...
        1e-4);

    GABANEURONModel = gapfilledModel;

    fprintf('Gapfilling completed.\n');
    fprintf('Added reactions: %d\n', ...
        length(addedRxns));

catch

    warning('Gapfilling failed.');

end

%% ===================================================================== %%
% FUNCTIONAL VALIDATION
%% ===================================================================== %%

try

    fprintf('\nOptimizing model...\n');

    solution = ...
        optimizeCbModel( ...
        GABANEURONModel);

    fprintf('Objective value: %.6f\n', ...
        solution.f);

catch

    warning('Model optimization failed.');

end

%% ===================================================================== %%
% METABOLIC TASK VALIDATION
%% ===================================================================== %%

try

    fprintf('\nRunning metabolic tasks...\n');

    essentialTasks = parseTaskList( ...
        'metabolicTasks_Essential.txt');

    taskReport = checkTasks( ...
        GABANEURONModel,...
        [],...
        true,...
        false,...
        false,...
        essentialTasks);

    save('taskReport.mat','taskReport');

catch

    warning('Task validation failed.');

end

%% ===================================================================== %%
% SAVE MODEL
%% ===================================================================== %%

if ~exist('results','dir')
    mkdir('results');
end

save( ...
    fullfile('results',...
    'GABANEURONModel.mat'),...
    'GABANEURONModel');

fprintf('\nModel successfully saved.\n');
fprintf('Output: results/GABANEURONModel.mat\n');
