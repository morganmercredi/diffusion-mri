function perpendicular_diffusivity = cosDiffusivityConnectedCylindricalPore(par, x)
% Calculates the diffusivity measured perpendicular to a connected cylindrical
% pore geometry with a cosine OGSE sequence.

% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables
%
% Parameters:
% diffusion_coefficient: Short-time diffusion coefficient (in units of mm^2/ms)
% radius: Radius of sphere (in units of mm)
% hindered_diffusion_coefficient: Long-time diffusion coefficient (in units of mm^2/ms)
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)
%
% The ADC is related to the OGSE signal through the relationship
% cosOGSE_signal = exp(-b_cos*ADC_cos), where ADC_cos has the form of
% Eq. (6) in the paper:
%
% Parsons Jr, Edward C., Mark D. Does, and John C. Gore. "Temporal diffusion spectroscopy:
% theory and implementation in restricted systems using oscillating gradients." 
% Magnetic Resonance in Medicine 55, no. 1 (2006): 75-84.
% 
% The ADC spectrum is that of a cylinder's, but with an added offset term so that
% ADC(frequency --> 0) --> nonzero constant depending on pore tortuosity [sic?]

% Independent variables
frequency = x(:,1);
gradient_duration = x(:,2);
gradient_separation = x(:,3);

% Parameters
diffusion_coefficient = par(1);
radius = par(2);
hindered_diffusion_coefficient = par(3);

% Convert to angular frequency
angular_frequency = 2*pi*frequency;

% Some quantities for the calculation
order = 20;
[lambda_n, B_n] = cyl_factors(radius, order);

% Begin signal calculation
beta = 0;
for j = 1:order
    a = lambda_n(j)*(diffusion_coefficient - hindered_diffusion_coefficient);
    b = B_n(j)*a*a;
    c = a*a + angular_frequency.*angular_frequency;
    d = gradient_duration/2 + sin(2*angular_frequency.*gradient_duration)./(4*angular_frequency);
    e = -1.0 + exp(-a*gradient_duration) + exp(-a*gradient_separation) - 0.5*exp(a*(gradient_duration - gradient_separation)) -...
        0.5*exp(-a*(gradient_separation + gradient_duration));
    
    sum = (b./(c.*c)).*((c/a).*d + e);

    beta = beta + sum;
end

perpendicular_diffusivity = 8*pi*pi*f.*f.*beta/gradient_duration + hindered_diffusion_coefficient;

end

