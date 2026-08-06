function model = s03_quality_control_and_curation(model, cfg)
% Structural QC and table-driven manual curation.

blocked = identifyBlockedRxns(model);
massCharge = checkMassChargeBalance(model); %#ok<NASGU>

try
    [leakMets, siphonMets] = findMassLeaksAndSiphons(model); %#ok<NASGU>
catch
    warning('findMassLeaksAndSiphons could not be completed.');
end

qcTable = table(model.rxns(blocked), 'VariableNames', {'BlockedReaction'});
writetable(qcTable, fullfile(cfg.outputDir, 'blocked_reactions.csv'));

if isfile(cfg.manualCurationFile)
    cur = readtable(cfg.manualCurationFile, 'TextType', 'string');
    required = {'rxnID','newLB','newUB'};
    if ~all(ismember(required, cur.Properties.VariableNames))
        error('manual_curation.csv must include rxnID,newLB,newUB');
    end

    for i = 1:height(cur)
        idx = find(strcmp(model.rxns, cur.rxnID(i)), 1);
        if isempty(idx)
            warning('Curation reaction not found: %s', cur.rxnID(i));
            continue;
        end
        model.lb(idx) = cur.newLB(i);
        model.ub(idx) = cur.newUB(i);

        if ismember('newName', cur.Properties.VariableNames) && strlength(cur.newName(i)) > 0
            model.rxnNames{idx} = char(cur.newName(i));
        end
    end
else
    warning('manual_curation.csv not found; no reaction-level manual edits applied.');
end

sol = optimizeCbModel(model, 'max');
if isempty(sol.f) || isnan(sol.f)
    error('Curated model is infeasible.');
end

fprintf('QC completed. Blocked reactions: %d\n', numel(blocked));
end
