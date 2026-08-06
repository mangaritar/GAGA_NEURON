function model = s05_define_neuron_biomass(model, cfg)
% Add/update neuron-specific maintenance biomass from CSV.

if ~isfile(cfg.biomassFile)
    error('biomass_stoichiometry.csv not found.');
end

T = readtable(cfg.biomassFile, 'TextType', 'string');
required = {'metID','coefficient'};
if ~all(ismember(required, T.Properties.VariableNames))
    error('biomass_stoichiometry.csv must include metID,coefficient');
end

rxnID = "BIOMASS_GABA_NEURON";
existing = find(strcmp(model.rxns, rxnID), 1);
if ~isempty(existing)
    model = removeRxns(model, char(rxnID));
end

metList = cellstr(T.metID);
coeffs = double(T.coefficient);

model = addReaction(model, char(rxnID), ...
    'metaboliteList', metList, ...
    'stoichCoeffList', coeffs, ...
    'lowerBound', 0, ...
    'upperBound', 1000, ...
    'reactionName', 'GABAergic neuron maintenance biomass');

model = changeObjective(model, char(rxnID));
end
