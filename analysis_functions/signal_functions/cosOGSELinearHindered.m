function Eh = cosOGSELinearHindered(par, x)
% Calculates the diffusion-weighted cosine OGSE signal from a radially symmetric
% diffusion tensor when the gradients are applied perpendicular to the principal axis.
% This function assumes that the radial diffusivity varies linearly with OG
% frequency: D(f) = D(f=0) + m*f
%
% For example, see the following paper:
% Xu, Junzhong et al. “Mapping mean axon diameter and axonal volume fraction by
% MRI using temporal diffusion spectroscopy.” NeuroImage vol. 103 (2014): 10-19.
% doi:10.1016/j.neuroimage.2014.09.006
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variable values

% Parameters:
% hindered_diffusion_coefficient: Hindered diffusion coefficient (in units of mm^2/ms)
% m: Rate of change in ADC in hindered space (mm^2)
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)

% parameters
hindered_diffusion_coefficient = par(1);
m = par(2);

% independent variables
frequency = x(:,1);
gradient_strength = x(:,2);
gradient_duration = x(:,3);

% compute b-values
bval = bCos(frequency, gradient_strength, gradient_duration);

% compute signals
Eh = exp(-bval.*(hindered_diffusion_coefficient + m*frequency));

end

