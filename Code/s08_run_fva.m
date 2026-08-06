function results = s08_run_fva(models, cfg)
stages = fieldnames(models);
results = struct();

for i = 1:numel(stages)
    stage = stages{i};
    model = models.(stage);

    [minFlux, maxFlux] = fluxVariability( ...
        model, cfg.fvaOptPercentage, 'max', model.rxns);

    results.(stage) = table( ...
        string(model.rxns), string(model.rxnNames), ...
        minFlux, maxFlux, maxFlux-minFlux, ...
        'VariableNames', {'ReactionID','ReactionName', ...
        'FVAmin','FVAmax','FluxRange'});
end
end
