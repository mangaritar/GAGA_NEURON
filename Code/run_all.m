clear; clc;

cfg = project_config();
s01_initialize_environment(cfg);

if ~cfg.skipReconstruction
    referenceModel = s02_reconstruct_reference_imat(cfg);
    referenceModel = s03_quality_control_and_curation(referenceModel, cfg);
    referenceModel = s04_apply_nutrient_medium(referenceModel, cfg);
    referenceModel = s05_define_neuron_biomass(referenceModel, cfg);
    save(cfg.curatedModelOut, 'referenceModel', '-v7.3');
else
    referenceModel = [];
end

if ~cfg.skipContextualization
    models = s06_contextualize_disease_models(referenceModel, cfg);
else
    models = load_existing_context_models(cfg);
end

fbaResults = s07_run_fba(models, cfg);
fvaResults = s08_run_fva(models, cfg);
biomassSensitivity = s09_biomass_sensitivity(models, cfg);
boundSensitivity = s10_reaction_bound_sensitivity(models, cfg);

s11_export_results(fbaResults, fvaResults, biomassSensitivity, boundSensitivity, cfg);

fprintf('\nWorkflow completed. Results: %s\n', cfg.outputDir);
