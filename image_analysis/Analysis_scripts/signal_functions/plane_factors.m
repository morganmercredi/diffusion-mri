function [lambda_n, B_n] = plane_factors(plane_separation, order)
% Returns the pair of numerical factors {lambda(n), B(n)} used to calculate the
% the OGSE signal from between parallel planes. 
%
% For details, see the following paper (Eq. 5):
% Xu, Junzhong et al. “Quantitative characterization of tissue microstructure
% with temporal diffusion spectroscopy.” Journal of magnetic resonance 
% (San Diego, Calif. : 1997) vol. 200,2 (2009): 189-97. doi:10.1016/j.jmr.2009.06.022
% 
% Input:
% 	plane_separation: distance between planes
% 	order: number of terms to return for the calculation (must be less than 31)
%
% Output:
% 	lambda_n: array of numerical values
% 	B_n: array of numerical values

% Generate an array of n integers
n = 1:order;

% Generate an array of n factors 
lambda_n = pi*pi*(2*n - 1).^2/(plane_separation*plane_separation);
B_n = 8*plane_separation*plane_separation./(pi*pi*pi*pi*(2*n - 1).^4);

end
