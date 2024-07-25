function perpendicular_diffusivity = rectDiffusivityCylinder(par, x)
% Calculates the diffusivity measured perpendicular to the cylinder axis
% with a PGSE sequence.
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
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)
%
% The ADC is related to the PGSE signal through the following relationship:
% PGSE_signal = exp(-b_PGSE*ADC_PGSE)
%
% The signal formula can be found in the following paper:
%
% Jiang, X., Li, H., Xie, J., McKinley, E.T., Zhao, P., Gore, J.C. and Xu,
% J. (2017), In vivo imaging of cancer cell size and cellularity using
% temporal diffusion spectroscopy. Magn. Reson. Med., 78: 156-164.
% https://doi.org/10.1002/mrm.26356

% Independent variables
gradient_duration = x(:,1);
gradient_separation = x(:,2);

% Parameters
diffusion_coefficient = par(1);
radius = par(2);

% Some quantities for the calculation
order = 20;
[lambda_n, B_n] = cyl_factors(radius, order);

% Begin signal calculation
beta = 0;
for j = 1:order
    a = lambda_n(j)*diffusion_coefficient;
    b = B_n(j)*a*a;
    c = a*a;
    d = gradient_duration;
    e = -1.0 + exp(-a*gradient_duration) + exp(-a*gradient_separation) - 0.5*exp(a*(gradient_duration - gradient_separation)) -...
        0.5*exp(-a*(gradient_separation + gradient_duration));
    
    sum = (b./(c.*c)).*((c/a).*d + e);

    beta = beta + sum;
end

perpendicular_diffusivity = 2*beta./(gradient_duration.*gradient_duration.*(gradient_separation - gradient_duration/3));

end

