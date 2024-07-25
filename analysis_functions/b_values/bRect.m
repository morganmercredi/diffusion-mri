function bvalue = bRect(gradient_strength, gradient_separation, gradient_duration)
% Returns the b-value for a PGSE sequence.
% 
% Inputs:
% gradient_strength: Gradient strength (in units of T/[distance])
% gradient_separation: Gradient spacing (in units of ms)
% gradient_duration: Gradient duration (in units of ms)

% Get the gyromagnetic ratio
gamma = gyromagnetic_ratio();  % units of 1/(T*ms)

% Calculate the b-value
bvalue = gamma*gamma*gradient_duration.*gradient_duration.*gradient_strength.*gradient_strength.*(gradient_separation - gradient_duration/3);  % units of ms/[distance*distance]

end

