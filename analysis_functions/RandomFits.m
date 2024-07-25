function fit_results = RandomFits(modelfun, xdata, ydata, beta0, fixed, lb, ub, number_of_fits, opts)
% This function takes data and fits it to a model many times and with
% randomly chosen starting parameters. It requires the Optimization Toolbox
% and the custom function fit_nl.
%
% Input:
%   modelfun: function handle for the function to fit. Must be of the form
%       modelfun(beta, xdata) where beta is a vector of parameters and xdata is a
%       matrix of independent variables
%   number_of_fits: number of fits
%   beta0: vector of starting parameters, the beta0(fixed) are fixed
%       parameters
%   xdata: N-by-p matrix of independent variables, where N is the number of
%        data points and p is the number of independent variables
%   ydata: N-by-1 column vector of output data
%   lb/ub: row vectors with lower/upper bounds for parameters
%   fixed: row vector states which parameters are fixed (true = fixed, false = not fixed)
%
% Output: 
%	fit_results: structure with the following fields:
%	   pars: matrix with estimated parameters for each fit
%      conf_int: 3-D array with 95% CI for estimated parameters
%      initial_guess: matrix of initial parameters for each fit (randomized between lb and ub)
%      sum_squares: Column vector with sum-of-squared residuals for each fit
%      jacobian: jacobian matrix for the best fit
%      fit_nl_covB: covariance matrix for the best fit

% turn off some warnings
warning('off','MATLAB:nearlySingularMatrix');
warning('off','MATLAB:singularMatrix');

% set default options if none are provided
if nargin < 9
    opts = optimset('Display','Off','TolFun', 1e-12);
end
if nargin < 8
    number_of_fits = 10;
end

% create a matrix of initial parameter guesses
initial_guess = repmat(lb(~fixed),[number_of_fits 1]) + ...
    (repmat(ub(~fixed),[number_of_fits 1]) - repmat(lb(~fixed),[number_of_fits 1])).*rand(number_of_fits,sum(~fixed));
	
% create space for the fitted parameters, sum-of-squares, confidence intervals, and jacobian matrices
pars = zeros(number_of_fits,sum(~fixed));
sum_squares = zeros(number_of_fits,1);
conf_int = zeros(sum(~fixed),2,number_of_fits);
jacobian_final = zeros(length(ydata),sum(~fixed),number_of_fits);

% start fitting
for j=1:number_of_fits
    beta0(~fixed) = initial_guess(j,:);
    [par,resnorm,residual,~,~,~,jacobian] = fit_nl(modelfun, beta0, xdata, ydata, fixed, lb, ub, opts);
    ci = nlparci(par,residual,'jacobian',jacobian);

    % store current results
    pars(j,:) = par;
    sum_squares(j,:) = resnorm;
    conf_int(:,:,j) = ci;
    jacobian_final(:,:,j) = jacobian;
end

% sort parameter estimates according to their sum-of-squares
[sum_squares, ind] = sort(sum_squares);
pars = pars(ind,:);
initial_guess = initial_guess(ind,:);
conf_int = conf_int(:,:,ind);
jacobian_final = jacobian_final(:,:,ind);

% save important information for later
fit_results.pars = pars;
fit_results.conf_int = conf_int;
fit_results.init_par = initial_guess;
fit_results.ss = sum_squares;
fit_results.jacobian = jacobian_final;
fit_results.fit_nl_covB = inv(jacobian_final(:,:,1)'*jacobian_final(:,:,1));
fit_results.fit_nl_covB = fit_results.fit_nl_covB*fit_results.ss(1)/(size(jacobian,1)-size(jacobian,2));

end

