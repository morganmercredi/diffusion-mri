function fit_results = FitOGSECylinder(signal_file, SNR)
% FitOGSECylinder.m is a function that analyses OGSE simulation output and
% saves the results in a structure. 
%
% Inputs:
% 	signal_file = name of text file with simulation data
%
% Output:
% 	fit_results = structure containing the results of the analysis
rng default;
model = 2;

% Get OGSE data and signals from file
[xdata, ydata] = GetSignalData(signal_file);
freq = xdata.freq;
grad = xdata.grad;  
Mx = ydata.Mx;
My = ydata.My;
signals = hypot(Mx,My);

% Create model function for fitting
switch model
    case 1
        signal_model = @(par,x) cosOGSECylinder(par(1:2),x);
        lb = [0 0];
        ub = [2.5e-6 0.01];
        fixed = [false false];
    case 2
        signal_model = @(par,x) par(3)*cosOGSECylinder(par(1:2),x) + (1 - par(3))*cosOGSEHindered(par(4),x);
        lb = [0 0 0 0];
        ub = [2.5e-6 0.01 1 2.5e-6];
        fixed = [false false false false];
    case 3
        signal_model = @(par,x) par(3)*cosOGSECylinder(par(1:2),x) + (1 - par(3))*cosOGSELinearHindered(par(4:5),x);
        lb = [0 0 0 0 0];
        ub = [2.5e-6 0.01 1 2.5e-6 1e-5];
        fixed = [false false false false false];
end

% Set sequence parameters
dur = 20;
tau = dur + 2.26;
dur = repmat(dur, size(freq));
tau = repmat(tau, size(freq));

% Prepare to do the fits
number_of_fits = 1000;
beta0 = zeros(1,length(fixed));
xdata = [freq grad dur tau];
ydata = signals;

% Fit to the model
fit_results = RandomFits(signal_model, xdata, ydata, beta0, fixed, lb, ub, number_of_fits);

% Output all fixed and variable parameters
beta_fit(~fixed) = fit_results.pars(1,:);
beta_fit(fixed) = beta0(fixed);
fit_results.beta_fit = beta_fit; % beta_fit has the "best" parameters and the fixed parameters
fit_results.fixed = fixed; % remember which parameters were fixed

% Add noise to the signal data and refit the data many times
inverse_snr = 1/SNR; % use SNR of 50
beta0(~fixed) = fit_results.pars(1,:); % use the best parameters from the noise-free fit as the starting parameters
number_of_trials = 1000; % number of trials
noisy_trials = NoisyFits(signal_model, xdata, [Mx My], beta0, fixed, lb, ub, inverse_snr, number_of_trials);
fit_results.noisy_trials = noisy_trials; % save the noisy fitted parameters

% Get ready to find bootstrap errors
% Generate one set of noisy data
fit_results.noisy_signals = hypot(Mx + inverse_snr*randn(size(Mx)), My + inverse_snr*randn(size(My)));

% Fit the noisy data to the model
opts = optimset('Display', 'Off', 'TolFun', 1e-12);	% Some optional parameters
[par,~,residual,~,~,~,jacobian] = fit_nl(signal_model, beta_fit, xdata, fit_results.noisy_signals, fixed, lb, ub, opts);
fit_results.noisy_fit = par;
fit_results.noisy_residuals = residual;
fit_results.noisy_ci = nlparci(par,residual,'jacobian',jacobian);

% Get bootstrapped errors
nBoot = 1000;
[bootCI, betaBoot] = BootstrapErrors(signal_model, xdata,...
    fit_results.noisy_signals, fit_results.noisy_residuals, nBoot, lb, ub, fixed, beta_fit);
fit_results.bootstrap.bootCI = bootCI;
fit_results.bootstrap.betaBoot = betaBoot;
    
% Output the predicted signals and actual, noisy signals
fit_results.yfit = signal_model(beta_fit, [freq grad dur tau]);
fit_results.ydata = signals;
fit_results.xdata = [freq grad dur tau];

end