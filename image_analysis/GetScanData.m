function ScanParameters = GetScanData(scanner, datadirectory, exps, dir)
% GetScanData.m is a function that reads the MRI data given the 
% directory of the folder containing the scans and the scans of interest 
% and acquires the scan parameters and saves it to a structure.  
%
% Inputs:
% scanner = scanner that was used to acquire images ('UW' or 'Vanderbilt')
% datadirectory = path to where MRI data is saved
% exps = list of DTI-OGSE scans
% dir = directory to save the output structure
%
% Output:
% ScanParameters = structure containing the pertinent information about 
% the scans including gradient duration, separation time, matrix size,
% maximum gradient strength, sequence type, gradient strengths and 
% magnetic field strengths used for the scans.

gamma = 42.6*10^(6); % (Hz/T)

count = 0;
for expnum = exps
	count = count+1;
	
    serdir = [datadirectory,num2str(expnum),'\'];
    info = load_method(serdir);
    
    ScanParameters.GradientDuration(count,1:info.numbs) = info.graddur; % gradient duration (ms)
    ScanParameters.GradientSeparation(count,1:info.numbs) = info.gradsep; % separation time (ms)    
    
    ScanParameters.size = info.dim(1); % matrix size
    ScanParameters.GradientMaximum = info.gradmax; % maximum gradient (Hz/mm)
    ScanParameters.GradientMaximum = ScanParameters.GradientMaximum/gamma; % maximum gradient (T/mm)
	
    if info.NA0 > 0
        ScanParameters.GradientStrength(count,1) = 0; % this is where it assumes A0 image comes first
        ScanParameters.GradientStrength(count,2:info.numbs) = info.percentgradstrength;
		ScanParameters.b_value(count,1) = 0; % this is where it assumes A0 image comes first
        ScanParameters.b_value(count,2:info.numbs) = info.bval*(1e3); % ms/mm^2
    else
        ScanParameters.GradientStrength(count,1:info.numbs) = info.percentgradstrength;
        ScanParameters.b_value(count,1:info.numbs) = info.bval*(1e3); % ms/mm^2		
    end
    
    if isfield(info,'typesinus')
        ScanParameters.typ = info.typesinus; % sequence
        ScanParameters.NumberOfPeriods(count,1:info.numbs) = info.periods; % number of periods
    else
        ScanParameters.typ = 'rect';
    end

end

ScanParameters.GradientStrength = ScanParameters.GradientStrength/100; % percent as a fraction
ScanParameters.GradientStrength = ScanParameters.GradientStrength*ScanParameters.GradientMaximum; % T/mm

if strcmp(scanner,'UW')
    if strcmp(ScanParameters.typ,'sinewave')     
        ScanParameters.b_value = bSin(ScanParameters.NumberOfPeriods./ScanParameters.GradientDuration, ScanParameters.GradientStrength, ScanParameters.GradientDuration);    %OGSE_parameters.b_value
    elseif strcmp(ScanParameters.typ,'apodcoswave')
        ScanParameters.b_value = bApodCos(ScanParameters.NumberOfPeriods./ScanParameters.GradientDuration, ScanParameters.GradientStrength, ScanParameters.GradientDuration);    
    else
        disp(['Error: File ',serdir,' uses the OGSE wave ',info.typesinus,...
            ' which is not supported by this Matlab code. The code supports either sine or apodized cosine. You will have to change the code.']);
    end
end

if ~isfolder(dir)
    mkdir(dir);
end

save(strcat(dir, '\ScanParameters.mat'),'ScanParameters')
end