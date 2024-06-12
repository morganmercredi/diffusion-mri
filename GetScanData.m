function ScanParameters = GetScanData(scanner, datadirectory, expnumstart, expnumstop, dir)
% GetOGSEData.m is a function that reads the MRI data given the 
% directory of the folder containing the scans and the scans of interest 
% and acquires the scan parameters and saves it to a structure.  
%
% Inputs:
% scanner = scanner that was used to acquire images ('UW' or 'Vanderbilt')
% datadirectory = path to where MRI data is saved
% expnumstart = start of DTI-OGSE scans
% expnumstop = end of DTI-OGSE scans
% dir = directory to save the output structure
%
% Output:
% ScanParameters = structure containing the pertinent information about 
% the scans including gradient duration, separation time, matrix size,
% maximum gradient strength, sequence type, gradient strengths and 
% magnetic field strengths used for the scans.
count = 0;
for expnum = expnumstart:expnumstop
	count = count+1;
    serdir = [datadirectory,num2str(expnum),'\'];
    if strcmp(scanner,'UW')
        info = load_method_tubes(serdir);
    elseif strcmp(scanner,'Vanderbilt')
        info = load_method_vanderbilt(serdir);
    end
    
    ScanParameters.NumberOfPeriods(count,1:info.numbs) = info.periods; % number of periods
    ScanParameters.GradientDuration(count,1:info.numbs) = info.graddur; % gradient duration (ms)
    ScanParameters.GradientSeparation(count,1:info.numbs) = info.gradsep; % separation time (ms)    
    
    ScanParameters.size = info.dim(1); % matrix size
    ScanParameters.grad = info.gradmax; % maximum gradient (Hz/mm)
    gamma = 42.6*10^(6); % (Hz/T)
    ScanParameters.GradientMaximum = ScanParameters.grad/gamma; % maximum gradient (T/mm)
    
    ScanParameters.GradientStrength(count,1) = 0; % this is where it assumes A0 image comes first
    ScanParameters.GradientStrength(count,2:info.numbs) = info.percentgradstrength;
    
    ScanParameters.typ = info.typesinus; % sequence
    
    if strcmp(scanner,'Vanderbilt')
        ScanParameters.b_value(count,1) = 0; % this is where it assumes A0 image comes first
        ScanParameters.b_value(count,2:info.numbs) = info.bval*(1e3); % ms/mm^2
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