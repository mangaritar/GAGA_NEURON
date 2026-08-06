MATLAB package for the GABAergic-neuron GEM manuscript

Main entry point: run_all.m

Required software:
- MATLAB
- COBRA Toolbox v3.0
- Gurobi
- exp2flux

Required inputs in data/:
- Recon3DModel.mat
- GSE115565_expression.csv
- GEP_Control.csv
- GEP_EMCI.csv
- GEP_AMCI.csv
- GEP_AD.csv
- manual_curation.csv
- medium_bounds.csv
- biomass_stoichiometry.csv

If the four contextualized models already exist, place them in data/:
- modelo_neurona_Control_reactionSpecific_FIXEDbase.mat
- modelo_neurona_EMCI_reactionSpecific_FIXEDbase.mat
- modelo_neurona_AMCI_reactionSpecific_FIXEDbase.mat
- modelo_neurona_AD_reactionSpecific_FIXEDbase.mat

Then set:
cfg.skipReconstruction = true;
cfg.skipContextualization = true;

Important:
The manuscript does not provide the complete list of the 135 curated reactions,
the 263 retained/refined reactions, the exact medium bounds, the complete biomass
stoichiometry, or the exact exp2flux function signature. Therefore, the package
reads those values from CSV files and does not invent them.
