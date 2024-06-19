function Er = cosOGSECylinder(par, x)
% Calculates the diffusion-weighted cosine OGSE signal from inside a cylinder
% when the gradients are applied perpendicular to the cylinder axis.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables (frequencies and gradient strengths)
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
%
% The signal formula can be found in the following paper:
%
% Xu, Junzhong et al. “Quantitative characterization of tissue microstructure
% with temporal diffusion spectroscopy.” Journal of magnetic resonance 
% (San Diego, Calif. : 1997) vol. 200,2 (2009): 189-97. doi:10.1016/j.jmr.2009.06.022

% Independent variables
frequency = x(:,1);
gradient_strength = x(:,2);
gradient_duration = x(:,3);
gradient_separation = x(:,4);

Er = exp(-bCos(frequency, gradient_strength, gradient_duration).*cosDiffusivityCylinder(par,x(:,[1 3 4])));

end

