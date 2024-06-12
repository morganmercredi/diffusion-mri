function MicrostructureModel = ModelSelection(ScanParameters)
% ModelSelection.m is a function that lets the user select a microstructure
% model. The function takes an ScanParameters structure containing scan
% information and returns a structure with information on the selected
% microstructure model.
type = contains(lower(ScanParameters.typ),'cos'); % see if it's sine or cosine wave

% some possible parameters for the AxCaliber
Rmin = 0.05e-4;
Rmax = 5e-3;
Rincrements = 50;

fprintf(['These are the available models.\n',...
    'C. Simple Two Compartment Model\n',...
    'C2. Simple Two Compartment Model - Linear Extra-axonal Diffusion Dependence\n',...
    'A. Two Compartment AxCaliber Model\n',...
    'A2. Two Compartment AxCaliber Model - Linear Extra-axonal Diffusion Dependence\n']);
model_choice = input('What model would you like to use for the analysis? Choose a number from 1 to 4:  ','s');

if type == 1 % sequence was apodized cosine
    switch model_choice
        case 'S'
            signal_model = @(par,x) par(3)*cosOGSESphere(par(1:2),x) + (1 - par(3))*cosOGSEHindered(par(4),x);
            lower_bound = [0.05e-6 0 0 0.05e-6]; % lower bounds for parameters
            upper_bound = [2.5e-6 0.01 1 2.5e-6]; % upper bounds for parameters
            fixed_parameter = [false false false false]; % which parameters are fixed
            beta_initial = [1e-06 0.02 0.90686 1e-6]; % starting parameters
            units = {'mm^{2}/ms', 'mm', '[no unit]', 'mm^{2}/ms'}; % parameter units
            description = 'Cosine OGSE - Two Compartment Model - Spheres'; % description of model
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Radius', 'Cell density', 'Hindered diffusion coefficient'};
            unit_converter = [1e6 1e3 1 1e6];
        case 'C'
            signal_model = @(par,x) par(3)*cosOGSECylinder(par(1:2),x) + (1 - par(3))*cosOGSEHindered(par(4),x);      
            lower_bound = [0.05e-6 0 0 0.05e-6]; % lower bounds for parameters
            upper_bound = [2.5e-6 0.01 1 2.5e-6]; % upper bounds for parameters
            fixed_parameter = [false false false false]; % which parameters are fixed
            beta_initial = [1e-06 0.02 0.90686 1e-6]; % starting parameters
            units = {'mm^{2}/ms', 'mm', '[no unit]', 'mm^{2}/ms'};
            description = 'Cosine OGSE - Two Compartment Model - Cylinders';
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Radius', 'Cell density', 'Hindered diffusion coefficient'};
            unit_converter = [1e6 1e3 1 1e6];
        case 'C2'
            signal_model = @(par,x) par(3)*cosOGSECylinder(par(1:2),x) + (1 - par(3))*cosOGSELinearHindered([par(4) par(5)],x);
            lower_bound = [0.05e-6 0 0 0.05e-6 0]; % lower bounds for parameters
            upper_bound = [2.5e-6 0.01 1 2.5e-6 2e-5]; % upper bounds for parameters
            fixed_parameter = [false false false false false]; % which parameters are fixed
            beta_initial = [1e-6 0.002 0.90686 1e-6 2e-6]; % starting parameters
            units = {'mm^{2}/ms', 'mm', '[no unit]', 'mm^{2}/ms', 'mm^{2}/ms^{2}'}; % parameter units
            description = 'Cosine OGSE - Two Compartment Model - Linear Extra-axonal Diffusion'; % description of model
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Radius', 'Cell density', 'Hindered diffusion coefficient', 'Beta_{ex})'};
            unit_converter = [1e6 1e3 1 1e6 1e12];
        case 'A'
            signal_model = @(par,x) par(7)*cosOGSEGammaCylinder(par(1:6),x) + (1 - par(7))*cosOGSEHindered(par(8),x);
            lower_bound = [0 0 0 0 0 0 0 0]; % lower bounds for parameters
            upper_bound = [2.5e-6 50 0.01 Inf Inf Inf 1 2.5e-6]; % upper bounds for parameters
            fixed_parameter = [true false false true true true false false]; % which parameters are fixed
            beta_initial = [1e-6 2 0.001 Rmin Rmax Rincrements 0.75 1e-6]; % starting parameters
            units = {'mm^{2}/ms', '', 'mm^{-1}', 'mm', 'mm', '[no unit]', '[no unit]', 'mm^{2}/ms'};
            description = 'Cosine OGSE - Two Compartment AxCaliber Model - Cylinders';
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Gamma Distribution Parameter #1 (alpha)', 'Gamma Distribution Parameter #2 (beta)',...
                               'Minimum radius', 'Maximum radius', 'Number of bins', 'Cell density', 'Hindered diffusion coefficient'};
            unit_converter = [1e6 1 1e-3 1e3 1e3 1 1 1e6];
        case 'A2'
            signal_model = @(par,x) par(7)*cosOGSEGammaCylinder(par(1:6),x) + (1 - par(7))*cosOGSELinearHindered([par(8) par(9)],x);
            lower_bound = [0 0 0 0 0 0 0 0 0]; % lower bounds for parameters
            upper_bound = [2.5e-6 150 0.01 Inf Inf Inf 1 2.5e-6 2e-5]; % upper bounds for parameters
            fixed_parameter = [true false false true true true false false false]; % which parameters are fixed
            beta_initial = [0.254313944e-6 2 0.001 Rmin Rmax Rincrements 0.75 1e-6 2e-6]; % starting parameters
            units = {'mm^{2}/ms', '', 'mm^{-1}', 'mm', 'mm', '[no unit]', '[no unit]', 'mm^{2}/ms', 'mm^{2}/ms^{2}'};
            description = 'Cosine OGSE - Two Compartment AxCaliber Model - Cylinders - Linear extra-axonal diffusion';
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Gamma Distribution Parameter #1 (alpha)', 'Gamma Distribution Parameter #2 (beta)',...
                               'Minimum radius', 'Maximum radius', 'Number of bins', 'Cell density',...
                               'Hindered diffusion coefficient', 'Beta_{ex})'};
            unit_converter = [1 1 1e6 1 1e-3 1e3 1e3 1 1 1e6];
        otherwise
            disp(['Error: You must choose a model from the list.']);
            return;
    end
else % if you ran a sine sequence   
    switch model_choice
        case 'S'
            signal_model = @(par,x) par(3)*sinOGSESphere(par(1:2),x) + (1 - par(3))*sinOGSEHindered(par(4),x);
            lower_bound = [0.05e-6 0 0 0.05e-6]; % lower bounds for parameters
            upper_bound = [2.5e-6 0.01 1 2.5e-6]; % upper bounds for parameters
            fixed_parameter = [false false false false]; % which parameters are fixed
            beta_initial = [1e-06 0.02 0.90686 1e-6]; % starting parameters
            units = {'mm^{2}/ms', 'mm', '[no unit]', 'mm^{2}/ms'}; 
            description = 'Sine OGSE - Two Compartment Model - Spheres';
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Radius', 'Cell density', 'Hindered diffusion coefficient'};
            unit_converter = [1e6 1e3 1 1e6];		
        case 'C'
            signal_model = @(par,x) par(3)*sinOGSECylinder(par(1:2),x) + (1 - par(3))*sinOGSEHindered(par(4),x);
            lower_bound = [0.05e-6 0 0 0.05e-6]; % lower bounds for parameters
            upper_bound = [2.5e-6 0.01 1 2.5e-6]; % upper bounds for parameters
            fixed_parameter = [false false false false]; % which parameters are fixed
            beta_initial = [1e-06 0.02 0.90686 1e-6]; % starting parameters
            units = {'mm^{2}/ms', 'mm', '[no unit]', 'mm^{2}/ms'}; 
            description = 'Sine OGSE - Two Compartment Model - Cylinders';
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Radius', 'Cell density', 'Hindered diffusion coefficient'};		
            unit_converter = [1e6 1e3 1 1e6];
        case 'C2'
	        signal_model = @(par,x) par(3)*sinOGSECylinder(par(1:2),x) + (1 - par(3))*sinOGSELinearHindered([par(4) par(5)],x);
	        lower_bound = [0.05e-6 0 0 0.05e-6 0]; % lower bounds for parameters
	        upper_bound = [2.5e-6 0.01 1 2.5e-6 2e-5]; % upper bounds for parameters
	        fixed_parameter = [false false false false false]; % which parameters are fixed
	        beta_initial = [1e-6 0.002 0.90686 1e-6 2e-6]; % starting parameters
	        units = {'mm^{2}/ms', 'mm', '[no unit]', 'mm^{2}/ms', 'mm^{2}/ms^{2}'}; % parameter units
	        description = 'Sine OGSE - Two Compartment Model - Linear Extra-axonal Diffusion'; % description of model
	        parameter_names = {'Intracellular diffusion coefficient',...
							   'Radius', 'Cell density', 'Hindered diffusion coefficient', 'Beta_{ex})'};
		    unit_converter = [1e6 1e3 1 1e6 1e12];
        case 'A'
            signal_model = @(par,x) par(7)*sinOGSEGammaCylinder(par(1:6),x) + (1 - par(7))*sinOGSEHindered([par(8)],x);
            lower_bound = [0 1 0 0 0 0 0 0]; % lower bounds for parameters
            upper_bound = [1.0e-6 50 0.01 Inf Inf Inf 1 2.5e-6]; % upper bounds for parameters
            fixed_parameter = [true false false true true true false false]; % which parameters are fixed
            beta_initial = [1e-6 2 0.001 Rmin Rmax Rincrements 0.75 1e-6]; % starting parameters
            units = {'mm^{2}/ms', '[no unit]', 'mm^{-1}', 'mm', 'mm', '[no unit]', '[no unit]', 'mm^{2}/ms'};
            description = 'Sine OGSE - Two Compartment AxCaliber Model - Cylinders';
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Gamma Distribution Parameter #1 (alpha)', 'Gamma Distribution Parameter #2 (beta)',...
                               'Minimum radius', 'Maximum radius', 'Number of bins', 'Cell density', 'Hindered diffusion coefficient'};
            unit_converter = [1e6 1 1e-3 1e3 1e3 1 1 1e6];
        case 'A2'
            signal_model = @(par,x) par(7)*sinOGSEGammaCylinder(par(1:6),x) + (1 - par(7))*sinOGSELinearHindered([par(8) par(9)],x);
            lower_bound = [0 0 0 0 0 0 0 0 0]; % lower bounds for parameters
            upper_bound = [2.5e-6 150 0.01 Inf Inf Inf 1 2.5e-6 2e-5]; % upper bounds for parameters
            fixed_parameter = [true false false true true true false false false]; % which parameters are fixed
            beta_initial = [0.254313944e-6 2 0.001 Rmin Rmax Rincrements 0.75 1e-6 2e-6]; % starting parameters
            units = {'mm^{2}/ms', '', 'mm^{-1}', 'mm', 'mm', '[no unit]', '[no unit]', 'mm^{2}/ms', 'mm^{2}/ms^{2}'};
            description = 'Sine OGSE - Two Compartment AxCaliber Model - Cylinders - Linear extra-axonal diffusion';
            parameter_names = {'Intracellular diffusion coefficient',...
                               'Gamma Distribution Parameter #1 (alpha)', 'Gamma Distribution Parameter #2 (beta)',...
                               'Minimum radius', 'Maximum radius', 'Number of bins', 'Cell density',...
                               'Hindered diffusion coefficient', 'Beta_{ex})'};
            unit_converter = [1 1 1e6 1 1e-3 1e3 1e3 1 1 1e6]; 
        otherwise
            disp(['Error: You must choose a model from the list.']);
            return;
	end
end


MicrostructureModel.signal_model = signal_model;
MicrostructureModel.lower_bound = lower_bound;
MicrostructureModel.upper_bound = upper_bound;
MicrostructureModel.fixed_parameter = fixed_parameter;
MicrostructureModel.beta_initial = beta_initial;
MicrostructureModel.model_choice = model_choice;
if exist('units', 'var')
    MicrostructureModel.units = units;
end
if exist('description', 'var')
    MicrostructureModel.description = description;
end
if exist('parameter_names', 'var')
    MicrostructureModel.parameter_names = parameter_names;
end
if exist('fixed_parameter_names', 'var')
    MicrostructureModel.fixed_parameter_names = fixed_parameter_names;
end
if exist('unit_converter', 'var')
    MicrostructureModel.unit_converter = unit_converter;
end
end
