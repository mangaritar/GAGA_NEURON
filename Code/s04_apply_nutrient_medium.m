function model = s04_apply_nutrient_medium(model, cfg)
% Apply DMEM/F12-inspired exchange constraints from a transparent CSV.

if ~isfile(cfg.mediumBoundsFile)
    error('medium_bounds.csv not found.');
end

T = readtable(cfg.mediumBoundsFile, 'TextType', 'string');
required = {'rxnID','lowerBound','upperBound'};
if ~all(ismember(required, T.Properties.VariableNames))
    error('medium_bounds.csv must include rxnID,lowerBound,upperBound');
end

for i = 1:height(T)
    idx = find(strcmp(model.rxns, T.rxnID(i)), 1);
    if isempty(idx)
        warning('Medium reaction not found: %s', T.rxnID(i));
        continue;
    end
    model.lb(idx) = T.lowerBound(i);
    model.ub(idx) = T.upperBound(i);
end
end
