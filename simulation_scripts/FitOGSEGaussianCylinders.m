function fit_results = FitOGSEGaussianCylinders(signal_file, cylinder_file)
% FitOGSEGaussianCylinders.m is a function that analyses OGSE simulation output and
% saves the results in a structure. 
%
% Input:
% 	signal_file = name of text file with simulation data
%	cylinder_file = name of text file with cylinder radii
%
% Output:
% 	fit_results = structure containing the results of the model fitting
tic;
model = 2;
rng default;

% Get OGSE data and signals from file
[xdata ydata] = GetSignalData(signal_file);
freq = xdata.freq;
grad = xdata.grad;
Mx = ydata.Mx;
My = ydata.My;
signals = hypot(Mx,My);

% Create model function for fitting
switch model
    case 1
        signal_model = @(par,x) cosOGSENormCylinder(par(1:8),x);
        lb = [0 0 0 0 0 0 0 0];
        ub = [Inf Inf 2.5e-6 0.01 0.005/3 Inf Inf Inf];
        fixed = [true true true false false true true true];
    case 2
        signal_model = @(par,x) par(9)*cosOGSENormCylinder(par(1:8),x) + (1 - par(9))*cosOGSEHindered([par(1) par(10)],x);
        lb = [0 0 0 0 0 0 0 0 0 0];
        ub = [Inf Inf 2.5e-6 0.005 0.005/3 Inf Inf Inf 1 2.5e-6];
        fixed = [true true true false false true true true false false];
    case 3
        signal_model = @(par,x) par(9)*cosOGSENormCylinder(par(1:8),x) + (1 - par(9))*cosOGSELinearHindered([par(1) par(10) par(11)],x);
        lb = [0 0 0 0 0 0 0 0 0 0 0];
        ub = [Inf Inf 2.5e-6 0.01 0.005/3 Inf Inf Inf 1 2.5e-6 2.5e-6];
        fixed = [true true true false false true true true false false false];
end

% Set some sequence parameters
dur = 20;
tau = dur + 2.26;
intra_diffusion_coefficient = 1e-6;

% Set the range of radii and number of bins
rmin = 0.0;
rmax = 3e-3;
rincrements = 20;

% Prepare to do the fits
number_of_fits = 30;
beta0 = zeros(1,length(fixed));
beta0(fixed) = [dur tau intra_diffusion_coefficient rmin rmax rincrements]; % fix the intra-axonal diffusion coefficient

% Fit to the model
fit_results = RandomFits(signal_model, [freq grad], signals, beta0, fixed, lb, ub, number_of_fits);

% Print the predicted axon diameter distribution and the true distribution
h = print_axon_distribution(cylinder_file, @normpdf, fit_results.pars(1,1:2)', fit_results.fit_nl_covB, rmin, rmax, rincrements);

% Add noise to the signal data and refit the data many times
beta0(~fixed) = fit_results.pars(1,:); % use the best parameters from the noise-free fit as the starting parameters
number_of_trials = 50; % use one trial for now
inverse_snr = 1/50; % use SNR of 50
noisy_pars = NoisyFits(signal_model, [freq grad], [Mx My], beta0, fixed, lb, ub, inverse_snr, number_of_trials);
fit_results.noisy_pars = noisy_pars; % save the noisy fitted parameters

% Output all fixed and variable parameters
beta_fit(~fixed) = fit_results.pars(1,:);
beta_fit(fixed) = beta0(fixed);
fit_results.beta_fit = beta_fit; % beta_fit has the "best" parameters and the fixed parameters
fit_results.fixed = fixed; % remember which parameters were fixed

% Output the predicted signals and actual, noisy signals
fit_results.y_fit = signal_model(beta_fit, [freq grad]);
fit_results.ydata = signals;
fit_results.xdata = [freq grad];
toc;
end