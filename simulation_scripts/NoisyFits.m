function noisy_pars = NoisyFits(signal_model, xdata, ydata, beta0, fixed, lb, ub, inverse_snr, number_of_trials)
% This function adds noise to data, fits it to a model, 
% and then returns the estimated parameters. This is repeated 
% many times with different instances of noise. It requires the 
% Optimization Toolbox and the custom function fit_nl.
%
% Output:
% 	noisy_pars: array whose rows hold fitted parameters from each noisy fit
%
% Input:
%   signal_model: function handle for the function to fit. Must be of the form
%       signal_model(beta, xdata) where beta is a vector of parameters and xdata is a
%       matrix of independent variables
%   xdata: N-by-p matrix of independent variables, where N is the number of
%        data points and p is the number of independent variables
% 	ydata: N-by-2 array of transverse magnetizations - column #1 has the x-components and
%   	column #2 has the y-components
% 	lb: array specifying lower bounds on the parameters
% 	ub: array specifying upper bounds on the parameters
% 	fixed: array stating which parameters stay fixed when fit (true = fixed)
% 	beta0: array with starting parameters (both fixed and non-fixed)
% 	inverse_snr: the inverse of the desired SNR (= 1/SNR)
% 	number_of_trials: number of times that the function is fit

rng default;

% Get transverse magnetization components from ydata
Mx = ydata(:,1);
My = ydata(:,2);

% Make an array to store the fitted parameters
noisy_pars = zeros(number_of_trials, sum(~fixed));

% Some optional parameters
opts = optimset('Display', 'Off', 'TolFun', 1e-12);

% Start fitting
for j=1:number_of_trials
    % Create some noisy signal data (Rician)
    noisy_signals = hypot(Mx + inverse_snr*randn(size(Mx)), My + inverse_snr*randn(size(My)));
	
	% Fit the noisy data to the model
    par = fit_nl(signal_model, beta0, xdata, noisy_signals, fixed, lb, ub, opts);
	
	% Save the noisy parameters
    noisy_pars(j,:) = par(:);
 end

 end
