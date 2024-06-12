function ROI = getVoxelDistributions(MicrostructureModel, ROI)
% getVoxelDistributions is a function that generates 
% and saves axon diameter distributions from the structure output
% of OGSEVoxelAnalysis
%
% Input:
% MicrostructureModel: the structure containing model information
% ROI: the structure output from OGSEVoxelAnalysis
%
% Output:
% ROI: the original structure output with additional fields

Rmin = MicrostructureModel.beta_initial(4);
Rmax = MicrostructureModel.beta_initial(5);

% generate the axon diameter distribution for each ROI
for j=1:length(ROI)
	% generate a series of radii for evaluating the diameter distribution
    ri = linspace(Rmin, Rmax, 100);
    % get the number of voxels in the ROI
    numberOfVoxels=size(ROI(j).VoxelSignal,3);    
    % go through all the voxels and find the axon distribution
    for k=1:numberOfVoxels
        % calculate axon diameter distribution from fitted parameters
        % get gamma distribution parameters
        p1 = ROI(j).voxelParameters(k,1);
        p2 = ROI(j).voxelParameters(k,2);

        % calculate the distribution values at the specified radii
        axon_distribution = gampdf(ri, p1, p2);
        axon_distribution = axon_distribution./sum(axon_distribution);

        % convert radii to diameters and change units to micrometers
        axon_diameter = ri*2*10^(3);

        % save the diameter distribution in a field called axon_distribution
        % also save the diameter values where it was evaluated
        % the units of the diameters are in micrometers
        ROI(j).axon_distribution(:,1) = axon_diameter;
        ROI(j).axon_distribution(:,2) = axon_distribution;
        
        % save the mean diameter of the distribution (in micrometers)
        ROI(j).mean_axon_diameter = 2000*ROI.voxelParameters(k,1).*ROI(j).voxelParameters(k,2);
    
    end

end

end