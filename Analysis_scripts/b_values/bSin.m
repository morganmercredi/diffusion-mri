function bvalue = bSin(frequency, gradient_strength, gradient_duration)
% Returns the b-value for a sine OGSE sequence
%
% Inputs:
% frequency: OGSE frequency (in units of kHz)
% gradient_strength: Gradient strength (in units of T/[distance])
% gradient_duration: Gradient duration (in units of ms)

bvalue = 3*bCos(frequency, gradient_strength, gradient_duration); % units of ms/([distance*distance])

end

