function cfg = project_config()
rootDir = fileparts(mfilename('fullpath'));

cfg.rootDir   = rootDir;
cfg.dataDir   = fullfile(rootDir, 'data');
cfg.outputDir = fullfile(rootDir, 'results');

if ~exist(cfg.dataDir, 'dir'); mkdir(cfg.dataDir); end
if ~exist(cfg.outputDir, 'dir'); mkdir(cfg.outputDir); end

cfg.cobraToolboxDir = '';
cfg.exp2fluxDir = '';
cfg.solver = 'gurobi';

cfg.reconModelFile = fullfile(cfg.dataDir, 'Recon3DModel.mat');
cfg.referenceExpr = fullfile(cfg.dataDir, 'GSE115565_expression.csv');

cfg.stageExpression.Control = fullfile(cfg.dataDir, 'GEP_Control.csv');
cfg.stageExpression.EMCI = fullfile(cfg.dataDir, 'GEP_EMCI.csv');
cfg.stageExpression.AMCI = fullfile(cfg.dataDir, 'GEP_AMCI.csv');
cfg.stageExpression.AD = fullfile(cfg.dataDir, 'GEP_AD.csv');

cfg.manualCurationFile = fullfile(cfg.dataDir, 'manual_curation.csv');
cfg.mediumBoundsFile = fullfile(cfg.dataDir, 'medium_bounds.csv');
cfg.biomassFile = fullfile(cfg.dataDir, 'biomass_stoichiometry.csv');

cfg.contextModels.Control = fullfile(cfg.dataDir, 'modelo_neurona_Control_reactionSpecific_FIXEDbase.mat');
cfg.contextModels.EMCI = fullfile(cfg.dataDir, 'modelo_neurona_EMCI_reactionSpecific_FIXEDbase.mat');
cfg.contextModels.AMCI = fullfile(cfg.dataDir, 'modelo_neurona_AMCI_reactionSpecific_FIXEDbase.mat');
cfg.contextModels.AD = fullfile(cfg.dataDir, 'modelo_neurona_AD_reactionSpecific_FIXEDbase.mat');

cfg.skipReconstruction = false;
cfg.skipContextualization = false;

cfg.iMAT.lowPercentile = 25;
cfg.iMAT.highPercentile = 75;

cfg.exp2fluxThreshold = 1.0;
cfg.exp2fluxSensitivityThresholds = [0.5 1.0 2.0];

cfg.fvaOptPercentage = 100;
cfg.biomassPerturbation = 0.20;
cfg.boundPerturbation = 0.20;

cfg.referenceModelOut = fullfile(cfg.outputDir, 'reference_GABAergic_GEM.mat');
cfg.curatedModelOut = fullfile(cfg.outputDir, 'reference_GABAergic_GEM_curated.mat');
end
