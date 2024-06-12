function [lambda_n, B_n] = cyl_factors(radius, order)
% Returns the pair of numerical factors {lambda(n), B(n)} used to calculate the
% the OGSE signal from inside a cylinder. 
%
% For details, see the following paper (Eq. 6):
% Xu, Junzhong et al. “Quantitative characterization of tissue microstructure
% with temporal diffusion spectroscopy.” Journal of magnetic resonance 
% (San Diego, Calif. : 1997) vol. 200,2 (2009): 189-97. doi:10.1016/j.jmr.2009.06.022
% 
% Input:
% 	radius: radius of cylinder
% 	order: number of terms to return for the calculation (must be less than 31)
%
% Output:
% 	lambda_n: array of numerical values
% 	B_n: array of numerical values

if (order > 30)
    error('Error: The number of terms in the sum must be less than 31.');
end

cyl_roots = [1.8411837812830909034 , 5.3314427736005596259 ,...
    8.536316366394469668 , 11.706004903101559833 , 14.86358863392220897 ,...
    18.015527861984374169 , 21.164369860207948193 ,...
    24.311326857513844146 , 27.457050570329176509 ,...
    30.601922971376499305 , 33.746182898806083017 ,...
    36.889987406595096786 , 40.033444051461721358 ,... 
    43.17662896822066898 , 46.319597560019936111 ,...
    49.462391141071144318 , 52.605041111416163346 ,...
    55.747571790021616778 , 58.890002301317863953 ,...
    62.032347869536181406 , 65.174620801485730226 ,...
    68.316831128658492389 , 71.4589871087512023 ,...
    74.601095611742962888 , 77.743162403643836456 ,...
    80.885192357043337097 , 84.027189585446734554 ,...
    87.169157648798247351 , 90.311099577604508681 ,...
    93.453018007197954375];

% Calculate the factors
lambda_n = (1./(radius.*radius)).*(cyl_roots.*cyl_roots);
B_n = 2*(radius.*radius).*(1./(cyl_roots.*cyl_roots)./(cyl_roots.*cyl_roots - 1));

% Return a subset of factors if desired
lambda_n = lambda_n(:, 1:order);
B_n = B_n(:, 1:order);

end

