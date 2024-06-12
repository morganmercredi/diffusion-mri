function bvalue = bCos(frequency, gradient_strength, gradient_duration)
% Returns the b-value for a cosine OGSE sequence
%
% Inputs:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/[distance])
% gradient_duration: Gradient duration (in units of ms)

gamma = gyromagnetic_ratio();  % units of 1/(T*ms)

bvalue = gamma*gamma*gradient_duration.*gradient_strength.*gradient_strength./(4*pi*pi*frequency.*frequency);  % units of ms/[distance*distance]

end

