function s01_initialize_environment(cfg)
if ~isempty(cfg.cobraToolboxDir)
    addpath(genpath(cfg.cobraToolboxDir));
end
if ~isempty(cfg.exp2fluxDir)
    addpath(genpath(cfg.exp2fluxDir));
end

if exist('initCobraToolbox', 'file') ~= 2
    error('COBRA Toolbox not found. Configure cfg.cobraToolboxDir.');
end

initCobraToolbox(false);

ok = changeCobraSolver(cfg.solver, 'LP', 1);
if ~ok
    error('Unable to select COBRA LP solver: %s', cfg.solver);
end

fprintf('COBRA initialized with %s.\n', cfg.solver);
end
