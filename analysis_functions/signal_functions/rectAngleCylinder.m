function Er = rectAngleCylinder(par, x)
% Calculates the diffusion-weighted PGSE signal from inside a cylinder
% when the gradients are applied in an arbitrary direction relative to the
% cylinder axis.
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
% polar_angle_cylinder: Cylinder polar angle (radians)
% azimuthal_angle_cylinder: Cylinder azimuthal angle (radians)
%
% Independent variables:
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)
% polar_angle_gradient: Gradient polar angle (radians)
% azimuthal_angle_gradient: Gradient azimuthal angle (radians)

% Independent variables
gradient_strength = x(:,1);
gradient_duration = x(:,2);
gradient_separation = x(:,3);
polar_angle_gradient = x(:,4);
azimuthal_angle_gradient = x(:,5);

% Parameters
perpendicular_diffusion_coefficient = par(1);
radius = par(2);
parallel_diffusion_coefficient = par(3);
polar_angle_cylinder = par(4);
azimuthal_angle_cylinder = par(5);

% (nhat*ghat)(nhat*ghat) term
dot_product_term = (cos(polar_angle_cylinder).*cos(polar_angle_gradient)...
    + sin(polar_angle_cylinder).*sin(polar_angle_gradient)...
    .*cos(azimuthal_angle_cylinder - azimuthal_angle_gradient)).^2;

% Diffusivity perpendicular to cylinder axis
diffusivity_perpendicular = rectDiffusivityCylinder(par(1:2),x(:,[2 3]));

% b-value
bvalue = bRect(gradient_strength, gradient_separation, gradient_duration);

% Calculate signal
Er_perpendicular = exp(-bvalue.*diffusivity_perpendicular.*(1 - dot_product_term));
Er_parallel = exp(-bvalue.*parallel_diffusion_coefficient.*dot_product_term);

Er = Er_perpendicular.*Er_parallel;

end

