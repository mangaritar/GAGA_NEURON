function GABANEURONModel = createTissueSpecificModel(model, options)
% createTissueSpecificModel
%
% Generates a tissue-specific GABAergic neuron metabolic model using the
% selected reconstruction algorithm.
%
% INPUTS:
%   model   - Generic genome-scale metabolic model.
%   options - Structure containing the configuration parameters.
%             Required fields:
%               options.solver  - Reconstruction method to use.
%               options.weights - Reaction weights or expression-derived scores.
%
% OUTPUT:
%   GABANEURONModel - Tissue-specific metabolic model.

    % Validate input arguments
    if nargin < 2
        error('Two input arguments are required: model and options.');
    end

    if ~isstruct(options)
        error('The options input must be a structure.');
    end

    if ~isfield(options, 'solver')
        error('The options structure must contain a solver field.');
    end

    if ~isfield(options, 'weights')
        error('The options structure must contain a weights field.');
    end

    % Initialize output model
    GABANEURONModel = struct();

    % Select reconstruction method
    switch upper(options.solver)

        case 'INIT'
            fprintf('Running INIT algorithm...\n');

            % Generate tissue-specific model using INIT
            GABANEURONModel = INIT(model, options.weights, options);

            % Validate output model
            if isempty(GABANEURONModel)
                error('Tissue-specific model generation failed.');
            end

            if ~isfield(GABANEURONModel, 'rxns') || isempty(GABANEURONModel.rxns)
                warning('The generated model does not contain reactions.');
            else
                fprintf('Tissue-specific model generated successfully.\n');
                fprintf('Number of reactions: %d\n', numel(GABANEURONModel.rxns));
            end

        otherwise
            error('Unsupported solver: %s', options.solver);
    end
end
