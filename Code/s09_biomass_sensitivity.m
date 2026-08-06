function results = s09_biomass_sensitivity(models, cfg)
% Perturb all nonzero coefficients in the objective reaction by ±20%.

stages = fieldnames(models);
factors = [1-cfg.biomassPerturbation, 1, 1+cfg.biomassPerturbation];
labels = ["Minus20","Baseline","Plus20"];

rows = [];

for i = 1:numel(stages)
    stage = stages{i};
    model = models.(stage);

    objIdx = find(model.c ~= 0, 1);
    if isempty(objIdx)
        error('No objective reaction in model %s.', stage);
    end

    for j = 1:numel(factors)
        testModel = model;
        nz = testModel.S(:,objIdx) ~= 0;
        testModel.S(nz,objIdx) = testModel.S(nz,objIdx) * factors(j);

        sol = optimizeCbModel(testModel, 'max');
        rows = [rows; {string(stage), labels(j), factors(j), sol.f}]; %#ok<AGROW>
    end
end

results = cell2table(rows, ...
    'VariableNames', {'Stage','Scenario','CoefficientFactor','ObjectiveFlux'});
end
