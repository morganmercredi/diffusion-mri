function perpendicular_diffusivity = cosDiffusivitySphere(par, x)
% Calculates the diffusivity measured in a sphere with a cosine OGSE sequence.

% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% diffusion_coefficient: Diffusion coefficient inside sphere (in units of mm^2/ms)
% radius: Radius of sphere (in units of mm)
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)
%
% The ADC is related to the OGSE signal through the following relationship:
% cosOGSE_signal = exp(-b_cos*ADC_cos)
%
% The signal formula can be found in the following paper:
%
% Xu, Junzhong et al. “Quantitative characterization of tissue microstructure
% with temporal diffusion spectroscopy.” Journal of magnetic resonance 
% (San Diego, Calif. : 1997) vol. 200,2 (2009): 189-97. doi:10.1016/j.jmr.2009.06.022

% Independent variables
frequency = x(:,1);
gradient_duration = x(:,2);
gradient_separation = x(:,3);

% Parameters
diffusion_coefficient = par(1);
radius = par(2);

% Convert to angular frequency
angular_frequency = 2*pi*frequency;

% Some quantities for the calculation
order = 20;
[lambda_n, B_n] = sphere_factors(radius, order);

% Begin signal calculation
beta = 0;
for j=1:order
    a = lambda_n(j)*diffusion_coefficient;
    b = B_n(j).*a.*a;
    c = a.*a + angular_frequency.*angular_frequency;
    d = gradient_duration/2 + sin(2*angular_frequency.*gradient_duration)./(4*angular_frequency);
    e = -1 + exp(-a.*gradient_duration) + exp(-a.*gradient_separation) - 0.5*exp(a.*(gradient_duration - gradient_separation)) -...
        0.5*exp(-a.*(gradient_separation + gradient_duration));

    temp_sum = (b./(c.*c)).*((c./a).*d + e);
    beta = beta + temp_sum;
end

perpendicular_diffusivity = 8*pi*pi*frequency.*frequency.*beta./gradient_duration;

end

