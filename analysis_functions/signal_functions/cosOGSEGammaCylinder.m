function Er = cosOGSEGammaCylinder(par, x)
% Calculates the diffusion-weighted cosine OGSE signal from inside a collection
% of parallel cylinders when the gradients are applied perpendicular to the
% cylinder axes. The cylinder diameters are assumed 
% to be drawn from a gamma distribution.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables (frequencies and gradient strengths)
%
% Parameters:
% diffusion_coefficient: Diffusion coefficient inside cylinders (in units of mm^2/ms)
% Gamma distribution parameter #1 ("k"): dimensionless parameter
% Gamma distribution parameter #2 ("theta"): units of mm
% rmin: Smallest cylinder radius (in units of mm)
% rmax: Largest cylinder radius (in units of mm)
% rincrements: Number of radius bins
%
% Independent variables:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/mm)
% gradient_duration: Gradient duration (in units of ms)
% gradient_separation: Gradient separation (in units of ms)

% Parameters
diffusion_coefficient = par(1);
k = par(2);
theta = par(3);
rmin = par(4);
rmax = par(5);
rincrements = par(6);

rinc = (rmax - rmin)/rincrements;

% Begin signal calculation
Er = 0;
norm = 0;
for i = 1:rincrements
    radius = rmin + (i - 0.5)*rinc;
    gammaPDF = gampdf(radius, k, theta);    
    Er = Er + gammaPDF*radius*radius*cosOGSECylinder([diffusion_coefficient; radius], x);
    norm = norm + gammaPDF*radius*radius;
end

Er = Er/norm;

end

