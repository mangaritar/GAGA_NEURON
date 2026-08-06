function models = load_existing_context_models(cfg)
stages = fieldnames(cfg.contextModels);
models = struct();

for i = 1:numel(stages)
    stage = stages{i};
    models.(stage) = load_single_model(cfg.contextModels.(stage));
end
end
