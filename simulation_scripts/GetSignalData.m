function  [xdata ydata] = GetSignalData(signal_file)
% Reads a OGSE simulation output file and returns OGSE frequences,
% gradient strengths, and transverse magnetizations
% Simulation output has rows of the form (frequency, gradient, Mx, My, Mx, My,...)
% 
% Input:
% 	signal_file: name of text file with simulation data
%
% Output:
% 	xdata: structure with the following fields:
% 		freq: array of OGSE frequencies
% 		grad: array of gradient strengths
%
% 	ydata: structure with the following fields:
% 		Mx: array of transverse magnetization x-components  	
%   	My: array of transverse magnetization y-components	   	

% import the text file   
signal_data = importdata(signal_file);

% read frequencies and gradient strengths
freq = signal_data(:,1); % kHz
grad = signal_data(:,2); % T/mm

% read transverse magnetizations
% in this implementation, only take
% the first two columns
Mx = signal_data(:,3);
My = signal_data(:,4);

% first element in Mx was the particle number
% (for GPU simulation output)
num_of_particles = Mx(1);

% normalize Mx and My
Mx = Mx/num_of_particles;
My = My/num_of_particles;

% save frequency and gradient data
xdata.freq = freq;
xdata.grad = grad;
ydata.Mx = Mx;
ydata.My = My;

end

