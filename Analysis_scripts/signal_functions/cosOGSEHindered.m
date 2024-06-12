function Eh = cosOGSEHindered(par, x)
% Calculates diffusion-weighted cosine OGSE signal (Eh) for hindered diffusion
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variable values (frequencies and gradient strengths)

% Parameters:
% hindered_diffusion_coefficient: Hindered diffusion coefficient (in units of mm^2/ms)
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)

% parameters
hindered_diffusion_coefficient = par(1);

% independent variables
frequency = x(:,1);
gradient_strength = x(:,2);
gradient_duration = x(:,3);

% compute b-values
bval = bCos(frequency, gradient_strength, gradient_duration);

% compute signals
Eh = exp(-bval*hindered_diffusion_coefficient);

end

