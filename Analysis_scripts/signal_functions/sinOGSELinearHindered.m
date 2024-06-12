function Eh = sinOGSELinearHindered(par, x)
% Calculates diffusion-weighted sine OGSE signal (Eh) for hindered diffusion
% This function assumes that the extracellular ADC varies linearly with OGSE 
% frequency: D(f) = D(f=0) + m*f
%
% For example, see the following paper:
% Xu, Junzhong et al. â€œMapping mean axon diameter and axonal volume fraction by
% MRI using temporal diffusion spectroscopy.â€? NeuroImage vol. 103 (2014): 10-19.
% doi:10.1016/j.neuroimage.2014.09.006
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variable values (frequencies and gradient strengths)

% Parameters:
% hindered_diffusion_coefficient: Hindered diffusion coefficient (in units of mm^2/ms)
% m: Rate of change in ADC in hindered space (mm^2)
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/mm])
% gradient_duration: Gradient duration (in units of ms)

% parameters
hindered_diffusion_coefficient = par(1);
m = par(2);

% independent variables
frequency = x(:,1);
gradient_strength = x(:,2);
gradient_duration = x(:,3);

% compute b-values
bval = bSin(frequency, gradient_strength, gradient_duration);

% compute signals
Eh = exp(-bval.*(hindered_diffusion_coefficient + m*frequency));

end
