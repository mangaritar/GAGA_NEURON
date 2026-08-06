function model = load_single_model(filePath)
if ~isfile(filePath)
    error('Model file not found: %s', filePath);
end

S = load(filePath);
names = fieldnames(S);

for i = 1:numel(names)
    candidate = S.(names{i});
    if isstruct(candidate) && isfield(candidate,'S') && isfield(candidate,'rxns')
        model = candidate;
        return;
    end
end

error('No COBRA model structure found in %s.', filePath);
end
