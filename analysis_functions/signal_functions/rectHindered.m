function Eh = rectHindered(par, x)
% Calculates the diffusion-weighted PGSE signal from a radially symmetric
% diffusion tensor when the gradients are applied perpendicular to the principal axis.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variable values

% Parameters:
% hindered_diffusion_coefficient: Hindered diffusion coefficient (in units of mm^2/ms)
%
% Independent variables:
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)

% parameters
hindered_diffusion_coefficient = par(1);

% independent variables
gradient_strength = x(:,1);
gradient_duration = x(:,2);
gradient_separation = x(:,3);

% compute b-values
bvalue = bRect(gradient_strength, gradient_separation, gradient_duration);

% compute signals
Eh = exp(-bvalue*hindered_diffusion_coefficient);

end

