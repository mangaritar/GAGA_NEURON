function models = s06_contextualize_disease_models(referenceModel, cfg)
% Generate Control, E-MCI, A-MCI and AD models.
%
% The manuscript specifies a modified exp2flux implementation but not its
% exact MATLAB function signature. This wrapper tries common entry points.
% Adjust only call_exp2flux_adapter if your local package differs.

stages = fieldnames(cfg.stageExpression);
models = struct();

for i = 1:numel(stages)
    stage = stages{i};
    exprFile = cfg.stageExpression.(stage);

    if ~isfile(exprFile)
        error('Missing stage expression file: %s', exprFile);
    end

    expr = readtable(exprFile);
    models.(stage) = call_exp2flux_adapter( ...
        referenceModel, expr, cfg.exp2fluxThreshold);

    out = fullfile(cfg.outputDir, ['model_' stage '_contextualized.mat']);
    model = models.(stage); %#ok<NASGU>
    save(out, 'model', '-v7.3');
end
end

function modelOut = call_exp2flux_adapter(modelIn, exprTable, threshold)
if exist('exp2flux', 'file') == 2
    try
        modelOut = exp2flux(modelIn, exprTable, threshold);
        return;
    catch ME1
        try
            modelOut = exp2flux(modelIn, exprTable);
            return;
        catch
            error(['exp2flux was found but its local function signature differs. ' ...
                   'Edit call_exp2flux_adapter. First error: %s'], ME1.message);
        end
    end
else
    error(['exp2flux was not found. Add the package to cfg.exp2fluxDir ' ...
           'or use the pre-contextualized models.']);
end
end
