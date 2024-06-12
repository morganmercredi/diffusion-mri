function [bootCI, parBoot] = BootstrapErrors(modelfun, xData, yData, residuals, nBoot, lb, ub, fixed, beta_fit)
% This function calculates parameter estimate errors using bootstrapping techniques.
% It requires the Optimization Toolbox and the custom function fit_nl.
%
% The code is mostly based on an example shown in a University of British
% Columbia PowerPoint lecture by Dodo Das.
% https://personal.math.ubc.ca/~keshet/MCB2012/SlidesDodo/DataFitLect3.pdf
% 
% Output:
% 	bootCI: 2-by-(# of fitted parameters) matrix with 95% confidence intervals 
%           for the bootstrapped parameters
%   betaBoot: matrix of size (# of bootstraps)-by-(# of fitted parameters) 
%             storing bootstrapped parameter estimates
%
% Input:
%   modelfun: function handle for the function to fit. Must be of the form
%       modelfun(beta_fit, xData) where beta_fit is a vector of parameters 
%       and xData is a matrix of predictors
%   xData: N-by-p matrix of predictors, where N is the number of
%        data points and p is the number of independent variables
% 	yData: N-by-1 array of responses
%   residuals: N-by-1 array of residuals
% 	nBoot: number of bootstraps
% 	lb: array specifying lower bounds on the parameters
% 	ub: array specifying upper bounds on the parameters
% 	fixed: array stating which parameters stay fixed when fit (true = fixed)
% 	beta_fit: array with starting parameters (both fixed and non-fixed)
    [~, bootIndices] = bootstrp(nBoot, [], residuals);
    bootResiduals = residuals(bootIndices);

    yBoot = repmat(yData, 1, nBoot) + bootResiduals;
    parBoot = zeros(nBoot, length(find(~fixed)));
    for i=1:nBoot
        [par,~,~,~,~,~,~] =...
            fit_nl(modelfun, beta_fit, xData, yBoot(:,i), fixed, lb, ub);
        parBoot(i,:) = par;
    end
    bootCI = prctile(parBoot,[2.5 97.5]); 
end

