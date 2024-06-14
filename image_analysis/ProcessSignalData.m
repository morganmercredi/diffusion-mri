function ROI = ProcessSignalData(analysis_type, ScanParameters, ROIs, Noise)
% ProcessSignalData.m is a function that takes a structure of OGSE scan 
% parameters, a structure with drawn regions of interest (ROIs), 
% and a noise structure and processes the signal data from the ROIs.
% The processed signals are stored in a structure called ROI.

% number of frequencies and gradients
NOM = size(ScanParameters.NumberOfPeriods,1); % number of frequencies
NOI = size(ScanParameters.GradientStrength,2); % number of gradients

% get the ROI and voxel signals and normalize them to g=0
for j=1:length(ROIs) % read signals for each ROI
    %disp(['ROI number ',num2str(j),' is being processed.']);
	ROI(j).roiSNR = 0.66*ROIs(j).MeanROISignal./Noise.StDevROISignal; % get the SNR
    ROI(j).roiSignals = ROIs(j).MeanROISignal;
    ROI(j).roiSignalNorm = ROIs(j).MeanROISignal(:,1); % signal for b0
    
    % normalize the signals to g=0
    ROI(j).roiNormalizedSignals = ROI(j).roiSignals./repmat(ROI(j).roiSignalNorm,[1 NOI]);
	
	% put normalized signals into one column
    ROI(j).roiSignalList = ROI(j).roiNormalizedSignals(:);
       
    if strcmp(analysis_type, 'VBA')
        ROI(j).VoxelSignal = ROIs(j).VoxelSignal;
        ROI(j).voxelSignalNorm = ROIs(j).VoxelSignal(:,1,:);

        numberOfVoxels = size(ROI(j).VoxelSignal,3);
        for k=1:numberOfVoxels
			% normalize voxel signals to g=0
            ROI(j).voxelNormalizedSignals(:,:,k) = ROI(j).VoxelSignal(:,:,k)./repmat(ROI(j).voxelSignalNorm(:,:,k),[1 NOI]);
			% put normalized signals into one column
			ROI(j).voxelSignalList(:,k)=reshape(ROI(j).voxelNormalizedSignals(:,:,k), NOM*NOI, 1);
        end
    end
end

end