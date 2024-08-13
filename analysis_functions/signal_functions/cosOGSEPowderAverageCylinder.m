function Er = cosOGSEPowderAverageCylinder(par, x)
% Calculates the spherically averaged diffusion-weighted cosine OGSE signal from inside a cylinder.
%
% For example, see the following paper:
% Mariam Andersson, Marco Pizzolato, Hans Martin Kjer, Katrine Forum Skodborg, Henrik Lundell, Tim B. Dyrby,
% Does powder averaging remove dispersion bias in diffusion MRI diameter estimates within real 3D axonal architectures?,
% NeuroImage, Volume 248, 2022, 118718, ISSN 1053-8119, https://doi.org/10.1016/j.neuroimage.2021.118718.

% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% diffusion_coefficient: Diffusion coefficient inside cylinder (in units of mm^2/ms)
% radius: Radius of cylinder (in units of mm)
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)

% Independent variables
frequency = x(:,1);
gradient_strength = x(:,2);
gradient_duration = x(:,3);
gradient_separation = x(:,4);

% Parameters
perpendicular_diffusion_coefficient = par(1);
radius = par(2);
parallel_diffusion_coefficient = par(3);

% Diffusivity perpendicular to cylinder axis
diffusivity_perpendicular = cosDiffusivityCylinder(par(1:2),x(:,[1 3 4]));

% b-value
bvalue = bCos(frequency, gradient_strength, gradient_duration);

% Compute signal
Er = exp(-bvalue.*diffusivity_perpendicular).*...
    sqrt(pi./(4*bvalue.*(parallel_diffusion_coefficient - diffusivity_perpendicular))).*...
    erf(sqrt(bvalue.*(parallel_diffusion_coefficient - diffusivity_perpendicular)));
	
end

