function fit_results = FitOGSEPlanes(signal_file)
% FitOGSEPlanes.m is a function that that analyses OGSE simulation output and
% saves the results in a structure. 
%
% Inputs:
% 	signal_file = name of text file with simulation data
%
% Output:
% 	fit_results = structure containing the results of the model fitting

rng default;

% Get OGSE data and signals from file
[xdata ydata] = GetSignalData(signal_file);
freq = xdata.freq;
grad = xdata.grad;
Mx = ydata.Mx;
My = ydata.My;
signals = hypot(Mx,My);

% Set gradient duration and half echo time
dur = 20;
tau = dur + 1;
dur = repmat(dur, size(freq), 1);
tau = repmat(tau, size(freq), 1);

% Set bounds and fixed parameters
lb = [0 0];
ub = [8e-6 0.02];
fixed = [false false];

% Create model function for fitting
signal_model = @cosOGSEPlane;

% Prepare to do the fits
number_of_fits = 500;
beta0 = zeros(1,length(fixed));

% Fit to the model
fit_results = RandomFits(signal_model, [freq, grad dur, tau], signals, beta0, fixed, lb, ub, number_of_fits); 

% Add noise to the signal data and refit the data many times
beta0(~fixed) = fit_results.pars(1,:); % use the best parameters from the noise-free fit as the starting parameters
number_of_trials = 1000; % use one trial for now
inverse_snr = 1/50; % use SNR of 50
noisy_pars = NoisyFits(signal_model, [freq grad dur tau], [Mx My], beta0, fixed, lb, ub, inverse_snr, number_of_trials);
fit_results.noisy_pars = noisy_pars; % save the noisy fitted parameters

% Output all fixed and variable parameters
beta_fit(~fixed) = fit_results.pars(1,:);
beta_fit(fixed) = beta0(fixed);
fit_results.beta_fit = beta_fit; % beta_fit has the "best" parameters and the fixed parameters
fit_results.fixed = fixed; % remember which parameters were fixed

% Output the predicted signals and actual, noisy signals
fit_results.y_fit = signal_model(beta_fit, [freq grad dur tau]);
fit_results.ydata = signals;
fit_results.xdata = [freq grad];

end
