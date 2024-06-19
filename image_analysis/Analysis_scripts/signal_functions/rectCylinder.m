function Er = rectCylinder(par, x)
% Calculates the diffusion-weighted PGSE signal from inside a cylinder 
% when the gradients are applied perpendicular to the cylinder axis.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% diffusion_coefficient: Diffusion coefficient inside cylinder (in units of mm^2/ms)
% radius: Radius of cylinder (in units of mm)
%
% Independent variables:
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)
%
% The signal formula can be found in the following paper:

% Independent variables
gradient_strength = x(:,1);
gradient_duration = x(:,2);
gradient_separation = x(:,3);

Er = exp(-bRect(gradient_strength, gradient_separation, gradient_duration).*rectDiffusivityCylinder(par,x(:,[2 3])));

end

