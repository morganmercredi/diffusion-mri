function Er = rectPGSEPowderAverageCylinder(par, x)
% Calculates the spherically averaged diffusion-weighted PGSE signal from inside a cylinder.
%
% For example, see the following paper:
% Mariam Andersson, Marco Pizzolato, Hans Martin Kjer, Katrine Forum Skodborg, Henrik Lundell, Tim B. Dyrby,
% Does powder averaging remove dispersion bias in diffusion MRI diameter estimates within real 3D axonal architectures?,
% NeuroImage, Volume 248, 2022, 118718, ISSN 1053-8119, https://doi.org/10.1016/j.neuroimage.2021.118718.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% perpendicular_diffusion_coefficient: Diffusion coefficient inside cylinder
% measured perpendicular to the cylinder axis (in units of mm^2/ms)
% radius: Radius of cylinder (in units of mm)
% parallel_diffusion_coefficient: Diffusion coefficient inside cylinder
% measured parallel to the cylinder axis (in units of mm^2/ms)
%
% Independent variables:
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)

% Independent variables
gradient_strength = x(:,1);
gradient_duration = x(:,2);
gradient_separation = x(:,3);

% Parameters
perpendicular_diffusion_coefficient = par(1);
radius = par(2);
parallel_diffusion_coefficient = par(3);

% Diffusivity perpendicular to cylinder axis
diffusivity_perpendicular = rectDiffusivityCylinder(par(1:2),x(:,[2 3]));

% b-value
bvalue = bRect(gradient_strength, gradient_separation, gradient_duration);

% Compute signal
Er = exp(-bvalue.*diffusivity_perpendicular).*...
    sqrt(pi./(4*bvalue.*(parallel_diffusion_coefficient - diffusivity_perpendicular))).*...
    erf(sqrt(bvalue.*(parallel_diffusion_coefficient - diffusivity_perpendicular)));

end

