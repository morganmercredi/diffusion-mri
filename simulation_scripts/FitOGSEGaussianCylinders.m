function fit_results = FitOGSEGaussianCylinders(signal_file, cylinder_file, SNR)
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
        signal_model = @(par,x) cosOGSENormCylinder(par(1:6),x);
        lb = [0 0 0 0 0 0];
        ub = [2.5e-6 0.01 0.005/3 Inf Inf Inf];
        fixed = [true false false true true true];
    case 2
        signal_model = @(par,x) par(7)*cosOGSENormCylinder(par(1:6),x) + (1 - par(7))*cosOGSEHindered(par(8),x);
        lb = [0 0 0 0 0 0 0 0];
        ub = [2.5e-6 0.005 0.005/3 Inf Inf Inf 1 2.5e-6];
        fixed = [true false false true true true false false];
    case 3
        signal_model = @(par,x) par(7)*cosOGSENormCylinder(par(1:6),x) + (1 - par(7))*cosOGSELinearHindered([par(8) par(9)],x);
        lb = [0 0 0 0 0 0 0 0 0];
        ub = [2.5e-6 0.01 0.005/3 Inf Inf Inf 1 2.5e-6 2.5e-6];
        fixed = [true false false true true true false false false];
end

% Set some sequence parameters
dur = 20;
tau = dur + 2.26;
dur = repmat(dur, size(freq));
tau = repmat(tau, size(freq));
D = 1e-6;

% Set the range of radii and number of bins
Rmin = 0.05e-3;
Rmax = 5e-3;
Rincrements = 100;

% Prepare to do the fits
number_of_fits = 50;
beta0 = zeros(1,length(fixed));
beta0(fixed) = [D Rmin Rmax Rincrements];

% Do the fits
fit_results = RandomFits(signal_model, [freq grad dur tau], signals, beta0, fixed, lb, ub, number_of_fits);    

% Plot the predicted distribution with the actual distribution
h = print_axon_distribution(cylinder_file, @normpdf, fit_results.pars(1,1:2)', fit_results.fit_nl_covB, Rmin, Rmax, Rincrements);

% Add noise to the signal data and refit the data many times
inverse_snr = 1/SNR; % use SNR of 50
beta0(~fixed) = fit_results.pars(1,:); % use the best parameters from the noise-free fit as the starting parameters
number_of_trials = 1; % number of trials
noisy_trials = NoisyFits(signal_model, [freq grad dur tau], [Mx My], beta0, fixed, lb, ub, inverse_snr, number_of_trials);
fit_results.noisy_trials = noisy_trials; % save the noisy fitted parameters

% Get ready to find bootstrap errors
% Generate one set of noisy data
fit_results.noisy_signals = hypot(Mx + inverse_snr*randn(size(Mx)), My + inverse_snr*randn(size(My)));

% Fit the noisy data to the model
opts = optimset('Display', 'Off', 'TolFun', 1e-12);	% Some optional parameters
[par,~,residual,~,~,~,jacobian] = fit_nl(signal_model, beta0,[freq grad dur tau], fit_results.noisy_signals, fixed, lb, ub, opts);
fit_results.noisy_fit = par;
fit_results.noisy_residuals = residual;
fit_results.noisy_ci = nlparci(par,residual,'jacobian',jacobian);

% Get bootstrapped errors
nBoot = 1;
[bootCI, betaBoot] = BootstrapErrors(signal_model, [freq grad dur tau],...
    fit_results.noisy_signals, fit_results.noisy_residuals, nBoot, lb, ub, fixed, beta0);
fit_results.bootstrap.bootCI = bootCI;
fit_results.bootstrap.betaBoot = betaBoot;
    
% Output the predicted signals and actual, noisy signals
fit_results.yfit = signal_model(beta0, [freq grad dur tau]);
fit_results.ydata = signals;
fit_results.xdata = [freq grad dur tau];
toc;
end