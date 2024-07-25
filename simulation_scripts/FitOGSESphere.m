function fit_results = FitOGSESphere(signal_file)
% FitOGSESphere.m is a function that analyses OGSE simulation output and
% saves the results in a structure. 
%
% Inputs:
% 	signal_file = name of text file with simulation data
%
% Output:
% 	fit_results = structure containing the results of the model fitting
rng default;

model = 1;

% Get OGSE data and signals from file
[xdata ydata] = GetSignalData(signal_file);
freq = xdata.freq;
grad = xdata.grad;
Mx = ydata.Mx;
My = ydata.My;
signals = hypot(Mx,My);

% Set gradient duration and separation
dur = 20;
tau = dur + 2.26;
dur = repmat(dur, size(freq));
tau = repmat(tau, size(freq));

% Create model function for fitting
switch model
    case 1
        signal_model = @(par,x) cosOGSESphere(par,x);
        lb = [0 0];
        ub = [2.5e-6 0.01];
        fixed = [false false];
    case 2
        signal_model = @(par,x) par(5)*cosOGSESphere(par(1:4),x) + (1 - par(5))*cosOGSEHindered([par(1) par(6)],x);
        lb = [0 0 0 0 0 0];
        ub = [Inf Inf 2.5e-6 0.01 1 2.5e-6];
        fixed = [true true false false false false];
    case 3
        signal_model = @(par,x) par(5)*cosOGSESphere(par(1:4),x) + (1 - par(5))*cosOGSELinearHindered([par(1) par(6) par(7)],x);
        lb = [0 0 0 0 0 0 0];
        ub = [Inf Inf 2.5e-6 0.01 1 2.5e-6 1e-5];
        fixed = [true true false false false false false];
end

% Prepare to do the fits
number_of_fits = 100;
beta0 = zeros(1,length(fixed));

% Fit to the model
fit_results = RandomFits(signal_model, [freq, grad dur tau], signals, beta0, fixed, lb, ub, number_of_fits); 

% Add noise to the signal data and refit the data many times
beta0(~fixed) = fit_results.pars(1,:); % use the best parameters from the noise-free fit as the starting parameters
number_of_trials = 50; % use one trial for now
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
fit_results.xdata = [freq grad dur tau];

end
