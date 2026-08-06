function results = s07_run_fba(models, cfg) %#ok<INUSD>
stages = fieldnames(models);
results = table('Size',[numel(stages),3], ...
    'VariableTypes',{'string','double','double'}, ...
    'VariableNames',{'Stage','ObjectiveFlux','Status'});

for i = 1:numel(stages)
    stage = stages{i};
    sol = optimizeCbModel(models.(stage), 'max');

    results.Stage(i) = string(stage);
    results.ObjectiveFlux(i) = sol.f;
    if isfield(sol, 'stat')
        results.Status(i) = sol.stat;
    else
        results.Status(i) = NaN;
    end
end
end
