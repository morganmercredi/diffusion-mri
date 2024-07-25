function diffusivity = cosDiffusivityMitra(par, x)
% Calculates an approximation to the diffusivity measured at short-times with
% a cosine OGSE sequence.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% diffusion_coefficient: Diffusion coefficient (units = [distance]^2/ms)
% surface_to_volume: Surface-to-volume ratio (units = 1/[distance])
% dimensionality: Dimensionality of the microstructure (1, 2, or 3)
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_duration: Gradient duration (in units of ms)
%
% The ADC is related to the OGSE signal through the following relationship:
% cosOGSE_signal = exp(-b_cos*ADC_cos)
%
% The diffusivity formula can be found in the following paper:
%
% A.L. Sukstanskii, Exact analytical results for ADC with oscillating 
% diffusion sensitizing gradients, Journal of Magnetic Resonance,
% Volume 234, 2013, Pages 135-140, ISSN 1090-7807, https://doi.org/10.1016/j.jmr.2013.06.016.
% 
% This function makes use of the Fresnel integrals:
% John D'Errico (2024). FresnelS and FresnelC
% (https://www.mathworks.com/matlabcentral/fileexchange/28765-fresnels-and-fresnelc),
% MATLAB Central File Exchange. Retrieved June 21, 2024.

% Independent variables
angular_frequency = 2*pi*x(:,1); % convert to angular frequency
gradient_duration = x(:,2);

% Model parameters
diffusion_coefficient = par(1);
surface_to_volume = par(2);
dimensionality = par(3);

% Some quantities for later
N = angular_frequency.*gradient_duration/(2*pi); % number of periods
c = 1/(dimensionality*sqrt(2));
c_N = (4*pi*N.*fresnelC(2*sqrt(N)) + 3*fresnelS(2*sqrt(N)))./(2*pi*N);

% Calculate the ADC
diffusivity = diffusion_coefficient*(1 - c*c_N.*surface_to_volume.*sqrt(diffusion_coefficient./angular_frequency));

end