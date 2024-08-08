function Er = cosOGSEPowderAverageCylinder(par, x)
% Calculates the diffusion-weighted cosine OGSE signal from inside a cylinder.
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
bvalue = bCos(frequency, gradient_strength, gradient_duration);

% Parameters
diffusion_perpendicular = cosDiffusivity(par(1:2),x(:,[1 3 4]));
diffusion_parallel = par(3);

Er = exp(-bvalue.*diffusion_perpendicular).*...
    sqrt(pi./(4*bvalue.*(diffusion_parallel - diffusion_perpendicular))).*...
    erf(sqrt(bvalue.*(diffusion_parallel - diffusion_perpendicular)));

end

