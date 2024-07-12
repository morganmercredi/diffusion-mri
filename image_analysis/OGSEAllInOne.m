function ROI = OGSEAllInOne(scanner, exps, slice, startfilename, analysis_type)
% OGSEAllInOne.m is a function that runs GetOGSEData.m, GetVoxelROIs.m and
% OGSEVoxelAnalysis.m given the Bruker Gradient series used to perform the scans,
% the matrix size of the scans, the scans of interest and the start of the
% file name of the scans and outputs the ROI parameters with 95% upper and 
% lower confidence bounds
%
% Inputs:
% scanner = scanner that was used to acquire images ('UW' or 'Vanderbilt')
% exps = list of DTI-OGSE scans
% slice = slice number, or the number after 'sl_' 
% startfilename = start of the experiment name (e.g. 'mouse_')
% analysis_type = describes whether to do voxel-based analysis ('VBA') or
%                 not ('ROI') 
% 
% Output:
% ROI = structure containing the analysis of the ROIs drawn

[pathstr, ~]=fileparts(mfilename('fullpath'));
date = datestr(datetime('now'));
splitcells = regexp(date,' ','split','once');
dir = strcat(pathstr, '\',startfilename,'results_slice_',num2str(slice),'_',splitcells{1,1}, erase(splitcells{1,2},':'));
if ~exist(dir,'dir')
        mkdir(dir);
end

%% Part I
disp('Select MRI Data:')
datadirectory = uigetdir(); % location of data folder
%[~, fname]=fileparts(datadirectory);
datadirectory = [datadirectory '\'];

%subject_name = regexp(fname,'^[a-z]+','match');
%subject_name = strcat(subject_name{1}, '_');
%if ~strcmp(subject_name, startfilename)  
%    errordlg('Please check if the startfilename matches the subjectname in the chosen folder','Error');
%    disp(['Error: ',datadirectory, ' does not match. You will have to check if the startfilename matches the subjectname in the chosen folder']);
%    return
%end

ScanParameters = GetScanData(scanner, datadirectory, exps, dir);

%% Part II
disp('Select Registered Images:')
manregdirectory = uigetdir(); % registered images folder
%[~, fname]=fileparts(manregdirectory);
manregdirectory = [manregdirectory '\'];

%subject_name = regexp(fname,'^[a-z]+','match');
%subject_name = strcat(subject_name{1}, '_');
%if ~strcmp(subject_name, startfilename)
%    errordlg('Please check if the startfilename matches the subjectname in the chosen folder','Error');
%    disp(['Error: ',datadirectory, ' does not match. You will have to check if the startfilename matches the subjectname in the chosen folder']);
%    return
%end

[ROIs, Noise] = GetROIsVoxels(manregdirectory,exps,startfilename,slice,ScanParameters,dir);

%% Part III
[ROI, MicrostructureModel] = OGSEVoxelAnalysis(analysis_type,ScanParameters,ROIs,Noise,dir);

end


