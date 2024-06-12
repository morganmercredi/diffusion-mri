function [ROI, MicrostructureModel] = OGSEVoxelAnalysis(analysis_type, ScanParameters, ROIs, Noise, dir)
% OGSEVoxelAnalysis.m is a function that analyzes the regions of interest (ROIs) 
% given the OGSE_parameters structure containing the scan parameters and 
% the ROIs structure containing the information of the ROIs drawn and 
% saves it to a structure.
%
% Inputs:
% analysis_type = describes whether to do voxel-based analysis ('VBA') or
%                 not ('ROI')
% ScanParameters = structure containing the magnetic field strengths
% and gradients used for the scans
% ROIs = structure containing information on the ROIs drawn
% Noise = structure containing information on the background noise
% dir = directory to save the output structure
%
% Output:
% ROI = structure containing the analysis of the ROIs drawn
% MicrostructureModel = structure containing information on the
% microstructure model

gradient_duration = ScanParameters.GradientDuration; % gradient duration (ms)
freq = ScanParameters.NumberOfPeriods./ScanParameters.GradientDuration; % (kHz)
grad = ScanParameters.GradientStrength; % (T/mm)

% put frequencies, gradients, gradient durations, and gradient separations
% into single columns
freqList = freq(:);
gradList = grad(:);
gradDurationList = gradient_duration(:);
gradSepList = ScanParameters.GradientSeparation(:);

% put frequencies, gradients, gradient durations, and gradient separations
% into an array for fitting later
xdata = [freqList gradList gradDurationList gradSepList];

% get signal data and process it
ROI = ProcessSignalData(analysis_type, ScanParameters, ROIs, Noise);

% select a microstructure model and get model constraints
MicrostructureModel = ModelSelection(ScanParameters);
signal_model = MicrostructureModel.signal_model;
lb = MicrostructureModel.lower_bound;
ub = MicrostructureModel.upper_bound;
fixed = MicrostructureModel.fixed_parameter;
beta0 = MicrostructureModel.beta_initial;
model_choice = MicrostructureModel.model_choice;

% fit data from each ROI
NOF = input('How many times you would like to fit the parameters? (1000):');
if isempty(NOF)
    NOF = 1000;
end

for j=1:length(ROI)
    if strcmp(analysis_type, 'ROI')
        % put the signals in column form
        ydata = ROI(j).roiSignalList;
        % fit and save results for each ROI
        ROI(j).fit_results = RandomFits(signal_model, xdata, ydata, beta0, fixed, lb, ub, NOF);
        
        % save best parameters, the confidence intervals, and the "errors"
        ROI(j).roiParameters = ROI(j).fit_results.pars(1,:);
        ROI(j).roiCI = ROI(j).fit_results.conf_int(:,:,1);
        ROI(j).roiErrors = abs(ROI(j).fit_results.conf_int(:,1,1) - ROI(j).fit_results.conf_int(:,2,1))/2;
        
        % Find the predicted signals and residuals using the best parameters
        betaBest = zeros(size(beta0));
        betaBest(~fixed) = ROI(j).roiParameters;
        betaBest(fixed) = MicrostructureModel.beta_initial(MicrostructureModel.fixed_parameter);
        ROI(j).roiPredictedSignals = signal_model(betaBest, xdata);
        ROI(j).roiResiduals = ROI(j).roiPredictedSignals - ROI(j).roiSignalList;
        
		% Use bootstrapping to find parameter errors
        nBoot = 100;
        [bootCI, parBoot] = BootstrapErrors(signal_model, xdata,...
            ydata, ROI(j).roiResiduals, nBoot, lb, ub, fixed, betaBest);
        ROI(j).bootstrap.bootCI = bootCI;
        ROI(j).bootstrap.parBoot = parBoot;
        
    elseif strcmp(analysis_type, 'VBA')
        numberOfVoxels=size(ROI(j).VoxelSignal,3);
        for k=1:numberOfVoxels
            ydata = ROI(j).voxelSignalList(:,k);
            % fit and save results for each voxel
            ROI(j).fit_results(k) = RandomFits(signal_model, xdata, ydata, beta0, fixed, lb, ub, NOF);
        end
        % get the best parameters for each voxel
        ROI(j).voxelParameters = arrayfun(@(x) x.pars(1,:), ROI(j).fit_results, 'UniformOutput', false)';
        ROI(j).voxelParameters = cell2mat(ROI(j).voxelParameters); % turn into an array
        % take the best parameters and average over the set of voxels
        ROI(j).voxelMeanParameters = mean(ROI(j).voxelParameters);
        % take the best parameters and get the standard deviation (in the
        % mean) over the set of voxels
        ROI(j).voxelStdParameters = std(ROI(j).voxelParameters)/sqrt(numberOfVoxels);
        
    end
end

% if the model is the AxCaliber model, then evaluate the diameter distributions
if (strcmp(model_choice, 'A')|| strcmp(model_choice, 'A2'))
    if strcmp(analysis_type, 'ROI')
        ROI = getROIDistributions(MicrostructureModel, ROI, dir);
    elseif strcmp(analysis_type, 'VBA')
        ROI = getVoxelDistributions(MicrostructureModel, ROI);
    end
end

save(strcat(dir, '/MicrostructureModel.mat'),'MicrostructureModel')
save(strcat(dir, '/Analysis.mat'),'ROI')
end