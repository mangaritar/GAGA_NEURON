function s11_export_results(fbaResults, fvaResults, biomassSensitivity, boundSensitivity, cfg)

writetable(fbaResults, fullfile(cfg.outputDir, 'FBA_results.csv'));
writetable(biomassSensitivity, fullfile(cfg.outputDir, 'biomass_sensitivity.csv'));
writetable(boundSensitivity, fullfile(cfg.outputDir, 'reaction_bound_sensitivity.csv'));

stageNames = fieldnames(fvaResults);
for i = 1:numel(stageNames)
    stage = stageNames{i};
    writetable(fvaResults.(stage), ...
        fullfile(cfg.outputDir, ['FVA_' stage '.csv']));
end

% Figure: objective fluxes
fig1 = figure('Color','w');
bar(categorical(fbaResults.Stage), fbaResults.ObjectiveFlux);
ylabel('Optimal objective flux');
xlabel('Disease stage');
title('FBA objective flux across disease stages');
exportgraphics(fig1, fullfile(cfg.outputDir, 'FBA_objective_flux.png'), 'Resolution', 300);
close(fig1);

% Figure: reaction-bound sensitivity
fig2 = figure('Color','w');
hold on;
stages = unique(boundSensitivity.Stage, 'stable');
for i = 1:numel(stages)
    idx = boundSensitivity.Stage == stages(i);
    plot(1:3, boundSensitivity.ObjectiveFlux(idx), '-o', ...
        'DisplayName', stages(i));
end
xticks(1:3);
xticklabels({'Contracted 20%','Baseline','Expanded 20%'});
ylabel('Optimal objective flux');
xlabel('Reaction-bound perturbation');
title('Sensitivity of FBA predictions to reaction-bound perturbation');
legend('Location','best');
grid on;
exportgraphics(fig2, fullfile(cfg.outputDir, 'reaction_bound_sensitivity.png'), 'Resolution', 300);
close(fig2);
end
