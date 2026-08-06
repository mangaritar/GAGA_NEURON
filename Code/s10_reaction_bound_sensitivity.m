function results = s10_reaction_bound_sensitivity(models, cfg)
% Uniformly contract and expand all finite bounds by ±20%.

stages = fieldnames(models);
scenarios = ["Contracted20","Baseline","Expanded20"];
scales = [1-cfg.boundPerturbation, 1, 1+cfg.boundPerturbation];

rows = [];

for i = 1:numel(stages)
    stage = stages{i};
    model = models.(stage);

    for j = 1:numel(scales)
        testModel = model;
        scale = scales(j);

        finiteLB = isfinite(testModel.lb);
        finiteUB = isfinite(testModel.ub);

        testModel.lb(finiteLB) = testModel.lb(finiteLB) * scale;
        testModel.ub(finiteUB) = testModel.ub(finiteUB) * scale;

        invalid = testModel.lb > testModel.ub;
        if any(invalid)
            error('Bound perturbation created invalid bounds in %s.', stage);
        end

        sol = optimizeCbModel(testModel, 'max');
        rows = [rows; {string(stage), scenarios(j), scale, sol.f}]; %#ok<AGROW>
    end
end

results = cell2table(rows, ...
    'VariableNames', {'Stage','Scenario','BoundScale','ObjectiveFlux'});
end
