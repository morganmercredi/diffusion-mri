function bvalue = bApodCos(frequency, gradient_strength, gradient_duration)
% Returns the b-value for a apodised-cosine OGSE sequence
%
% Inputs:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/[distance]
% gradient_duration: Gradient duration (in units of ms)

N = gradient_duration.*frequency;  % Number of oscillation periods
bvalue = bCos(frequency, gradient_strength, gradient_duration).*(1 - 1./(8*N));  % units of ms/[distance*distance]

end

