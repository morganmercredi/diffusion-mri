function ROI = getROIDistributions(MicrostructureModel, ROI, dir)
% getROIDistributions is a function that generates 
% and saves axon diameter distributions from the structure output
% of OGSEVoxelAnalysis
%
% Input:
% MicrostructureModel: the structure with information on the microstructure
% model
% ROI: the structure output from OGSEVoxelAnalysis
% dir: directory to save the diameter distribution plots
%
% Output:
% ROI: the original structure output with additional fields
%

Rmin = MicrostructureModel.beta_initial(4);
Rmax = MicrostructureModel.beta_initial(5);

% generate the axon diameter distribution for each ROI
for j=1:length(ROI)
	% generate a series of radii for evaluating the diameter distribution
    ri = linspace(Rmin, Rmax, 100);
	
    % calculate axon diameter distribution from fitted parameters
	% get gamma distribution parameters
	p1 = ROI(j).roiParameters(1);
	p2 = ROI(j).roiParameters(2);

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
    
    % plot and save the distribution plot to a file
    figure;
    plot(axon_diameter, axon_distribution, 'k', 'LineWidth', 4.5);   
    title('Predicted Axon Diameter Distribution');
    xlabel('Diameter (\mum)');
    ylabel('Fraction of axons');
    xlim([2*Rmin*10^(3), 2*Rmax*10^(3)]);
    filename = strcat(dir, "\ROI_#", num2str(j), "_axon_distribution.fig");
    saveas(gcf, filename);

end

end