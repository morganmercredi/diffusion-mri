function Er = rectAngleCylinder(par, x)
% Calculates the diffusion-weighted PGSE signal from inside a cylinder 
% when the gradients are applied at arbitrary direction to the cylinder axis.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% perpendicular_diffusion_coefficient: Diffusion coefficient inside cylinder
% perpendicular to the cylinder axis (in units of mm^2/ms)
% radius: Radius of cylinder (in units of mm)
% parallel_diffusion_coefficient: Diffusion coefficient inside cylinder
% parallel to the cylinder axis (in units of mm^2/ms)
% polar_angle_cylinder: Cylinder polar angle (radians)
% azimuthal_angle_cylinder: Cylinder azimuthal angle (radians)
%
% Independent variables:
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)
% polar_angle_cylinder: Gradient polar angle (radians)
% azimuthal_angle_cylinder: Gradient azimuthal angle (radians)

% Name independent variables
gradient_strength = x(:,1);
gradient_duration = x(:,2);
gradient_separation = x(:,3);
polar_angle_gradient = x(:,4);
azimuthal_angle_gradient = x(:,5);

% Name parameters
perpendicular_diffusion_coefficient = par(1);
radius = par(2);
parallel_diffusion_coefficient = par(3);
polar_angle_cylinder = par(4);
azimuthal_angle_cylinder = par(5);

% Gradient component perpendicular to fibres
dot_product_term = (cos(polar_angle_cylinder).*cos(polar_angle_gradient)...
    + sin(polar_angle_gradient).*sin(polar_angle_cylinder)...
    .*cos(azimuthal_angle_gradient - azimuthal_angle_cylinder)).^2;
%dot_product = gradient_x.*cylinder_x + gradient_y.*cylinder_y + gradient_z.*sqrt(1 - cylinder_x.*cylinder_x - cylinder_y.*cylinder_y);
diffusivity_perpendicular = rectDiffusivityCylinder(par(1:2),x(:,[2 3]));

% b-value with perpendicular gradient component
bvalue = bRect(gradient_strength, gradient_separation, gradient_duration);

% Calculate signal
Er_perpendicular = exp(-bvalue.*diffusivity_perpendicular.*(1 - dot_product_term));
Er_parallel = exp(-bvalue.*parallel_diffusion_coefficient.*dot_product_term);

%Er_perpendicular = exp(-bvalue.*diffusivity_perpendicular.*(1 - dot_product.*dot_product));
%Er_parallel = exp(-bvalue.*parallel_diffusion_coefficient.*dot_product.*dot_product);

Er = Er_perpendicular.*Er_parallel;

end

