function Er = rectAngleHindered(par, x)
% Calculates the diffusion-weighted PGSE signal from a radially symmetric
% diffusion tensor when the gradients are applied in arbitrary directions
% relative to the principal axis.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% perpendicular_diffusion_coefficient: Radial diffusion coefficient (in units of mm^2/ms)
% parallel_diffusion_coefficient: Axial diffusion coefficient (in units of mm^2/ms)
% polar_angle_tensor: Tensor polar angle (radians)
% azimuthal_angle_tensor: Tensor azimuthal angle (radians)
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
parallel_diffusion_coefficient = par(2);
polar_angle_tensor = par(3);
azimuthal_angle_tensor = par(4);

% (nhat*ghat)(nhat*ghat) term
dot_product_term = (cos(polar_angle_tensor).*cos(polar_angle_gradient)...
    + sin(polar_angle_gradient).*sin(polar_angle_tensor)...
    .*cos(azimuthal_angle_gradient - azimuthal_angle_tensor)).^2;

% b-value
bvalue = bRect(gradient_strength, gradient_separation, gradient_duration);

% Calculate signal
Er_perpendicular = exp(-bvalue.*perpendicular_diffusion_coefficient.*(1 - dot_product_term));
Er_parallel = exp(-bvalue.*parallel_diffusion_coefficient.*dot_product_term);

Er = Er_perpendicular.*Er_parallel;

end

