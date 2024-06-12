function Er = sinOGSEGammaCylinder(par, x)
% Calculates diffusion-weighted sine OGSE signal (Er) from inside
% a collection of cylinders. The cylinder diameters are assumed 
% to be drawn from a gamma distribution.
%
% Inputs:
% par: Array of function parameters (in the order described below)
% x: Array of independent variables (frequencies and gradient strengths)
%
% Parameters:
% diffusion_perpendicular: Diffusion coefficient inside cylinders (in units of mm^2/ms)
% {alpha, beta}: Gamma distribution parameters (alpha is dimensionless, beta in units of 1/mm)
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
diffusion_perpendicular = par(1);
alpha = par(2);
beta = par(3);
rmin = par(4);
rmax = par(5);
rincrements = par(6);

rinc = (rmax - rmin)/rincrements;

% Begin signal calculation
Er = 0;
norm = 0;
for i = 1:rincrements
    radius = rmin + (i - 0.5)*rinc;
    gammaPDF = gampdf(radius, alpha, beta);    
    Er = Er + gammaPDF*radius*radius*sinOGSECylinder([diffusion_perpendicular; radius], x);
    norm = norm + gammaPDF*radius*radius;
end

Er = Er/norm;

end

