%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TISSUE-SPECIFIC MODEL RECONSTRUCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n========================================\n');
fprintf('TISSUE-SPECIFIC MODEL RECONSTRUCTION\n');
fprintf('========================================\n');

%% Generate reaction weights

defaultWeight = -1;

weights = defaultWeight * ones(length(Recon3D.genes),1);

for i = 1:length(Recon3D.genes)

    if i <= length(red)
        weights(i) = red(i);
    end

end

%% Configure reconstruction options

options = struct();
options.solver  = 'INIT';
options.weights = weights;

fprintf('Reconstruction algorithm: %s\n', options.solver);

%% Generate tissue-specific model

GABANEURONModel = createTissueSpecificModel(Recon3D, options);

fprintf('Model reconstruction completed.\n');
fprintf('Reactions: %d\n', length(GABANEURONModel.rxns));
fprintf('Metabolites: %d\n', length(GABANEURONModel.mets));
fprintf('Genes: %d\n', length(GABANEURONModel.genes));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL QUALITY CONTROL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n========================================\n');
fprintf('MODEL QUALITY CONTROL\n');
fprintf('========================================\n');

%% Flux consistency analysis

fprintf('\nRunning flux consistency analysis...\n');

try

    [consistentRxns,inconsistentRxns] = ...
        findFluxConsistentSubset(GABANEURONModel);

    fprintf('Consistent reactions: %d\n', ...
        length(consistentRxns));

    fprintf('Inconsistent reactions: %d\n', ...
        length(inconsistentRxns));

catch ME

    warning('Flux consistency analysis failed.');
    disp(ME.message);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MASS AND CHARGE BALANCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nChecking mass and charge balance...\n');

try

    [massImbalancedRxns,massBalanced] = ...
        checkMassChargeBalance(GABANEURONModel);

    fprintf('Balanced reactions: %d\n', ...
        sum(massBalanced));

    fprintf('Imbalanced reactions: %d\n', ...
        length(massImbalancedRxns));

catch ME

    warning('Mass balance analysis failed.');
    disp(ME.message);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEAD-END METABOLITES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nDetecting dead-end metabolites...\n');

try

    deadEnds = detectDeadEnds(GABANEURONModel);

    fprintf('Dead-end metabolites: %d\n', ...
        length(deadEnds));

catch ME

    warning('Dead-end metabolite analysis failed.');
    disp(ME.message);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GAPFILLING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nRunning gapfilling...\n');

try

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

catch ME

    warning('Gapfilling failed.');
    disp(ME.message);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% METABOLIC TASK VALIDATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nRunning metabolic task validation...\n');

try

    essentialTasks = parseTaskList( ...
        'metabolicTasks_Essential.txt');

    taskReport = checkTasks( ...
        GABANEURONModel,...
        [],...
        true,...
        false,...
        false,...
        essentialTasks);

    fprintf('Metabolic task validation completed.\n');

catch ME

    warning('Task validation failed.');
    disp(ME.message);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONALITY TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nTesting model functionality...\n');

try

    solution = optimizeCbModel(GABANEURONModel);

    if isempty(solution)

        warning('No optimization solution found.');

    else

        fprintf('Objective value: %.6f\n', ...
            solution.f);

    end

catch ME

    warning('Model optimization failed.');
    disp(ME.message);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FINAL MODEL STATISTICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n========================================\n');
fprintf('FINAL MODEL STATISTICS\n');
fprintf('========================================\n');

fprintf('Genes: %d\n', ...
    length(GABANEURONModel.genes));

fprintf('Metabolites: %d\n', ...
    length(GABANEURONModel.mets));

fprintf('Reactions: %d\n', ...
    length(GABANEURONModel.rxns));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE MODEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resultsFolder = 'results';

if ~exist(resultsFolder,'dir')
    mkdir(resultsFolder);
end

save( ...
    fullfile(resultsFolder,...
    'GABANEURONModel.mat'), ...
    'GABANEURONModel');

fprintf('\nModel successfully saved.\n');
fprintf('Location: %s\n', ...
    fullfile(resultsFolder,...
    'GABANEURONModel.mat'));
