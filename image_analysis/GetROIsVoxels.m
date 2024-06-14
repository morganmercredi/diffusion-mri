function [ROIs, Noise] = GetROIsVoxels(manregdirectory, expnumstart, expnumstop, startfilename, slice, ScanParameters, dir)
% GetROIsVoxels.m is a function that lets the user draw regions of interest 
% given the directory of the folder containing the registered images, the 
% scans of interest, the start of the file name and the OGSE_parameters 
% structure containing the scan information and saves it to a structure. 
%
% Inputs:
% manregdirectory =  path to where the registered images are saved
% start scan = start of DTI-OGSE scans
% endscan =  end of DTI-OGSE scans
% startfilename = start of file name prior to '_s1_'
% slice = slice number, or the number after 'sl_' 
% ScanParameters = structure containing the magnetic field strengths
% and gradients used for the scans
% dir = directory to save the output structure
%
% Output:
% ROIs = structure containing information on the ROIs drawn
% Noise = structure containing information on the Noise drawn

matrixsize = ScanParameters.size; % matrix size
numscans = expnumstop-expnumstart+1; % number of scans
numbs = size(ScanParameters.GradientStrength, 2); % number of gradients
midfilename = strjoin({'_sl_', num2str(slice), '_'},'');
alignedimages = zeros(matrixsize,matrixsize,numscans,numbs);

count=0;
for expnum=expnumstart:expnumstop
    count = count+1;
    
    mostfilename=strjoin({manregdirectory,startfilename,num2str(expnum),midfilename},'');
    
    for gimage=1:numbs
        filename=strjoin({mostfilename,num2str(gimage),'.mat'},'');
        try 
            load(filename,'target_a*');
        catch
            if gimage>1
                errordlg('Please check if the number of images per scan','Error');
                disp(['Error: File ',filename,' cannot be found in the registered dataset. Each MRI slice in this dataset should have ', num2str(numbs), ' images, but you only have ',num2str(gimage-1), ' images. You will have to check the registration.']);
                return;
            elseif gimage==1
                errordlg('Please check the start of DTI-OGSE scans','Error');
                disp(['Error: File ',filename,' cannot be found in the registered dataset. You will have to check the start of DTI-OGSE scans.']);
                return;
            end
        end
        alignedimages(:,:,count,gimage)=target_aligned;
        clear('target_aligned');
    end
end

% Define ROIs

figure(1);
image_fraction = squeeze(alignedimages(:,:,numscans,1));
imagesc(image_fraction);
axis off;
colormap(gray);
axis equal;

yesorno = input('Do you want to use the same ROIs? Y/N (Y): ','s');
if yesorno == 'N'|| yesorno == 'n'
    num_of_ROI = input('How many ROIs would you like to define: ');
    for i = 1:num_of_ROI
        def_num = ['Please define ROI ',num2str(i),' in Figure 1.'];
        disp(def_num);
        [Mask,xreg,yreg] = roipoly;
        ROIs(i).Mask = Mask;
        ROIs(i).xreg = xreg;
        ROIs(i).yreg = yreg;
    end
    save(strcat(dir, '/ROIs.mat'),'ROIs')
    
    disp('Please define the noise in Figure 1.');
    [Mask,xnoise,ynoise]=roipoly;
    Noise.Mask = Mask;
    Noise.xnoise = xnoise;
    Noise.ynoise = ynoise;
    save(strcat(dir,'/Noise.mat'),'Noise')
    
else % previous defined ROIs and noise   
    roidirectory = uigetdir();
    try
        load(strcat(roidirectory, '/ROIs.mat'))
        load(strcat(roidirectory, '/Noise.mat'))
    catch
        errordlg('Please check the Result folder.','Error');
        disp(['Error: cannot find ',strcat(roidirectory, '/ROIs.mat'), ' and/or ', strcat(roidirectory, '/Noise.mat'), ' .You will have to check the locations']);
    end
end

% Plot MRI and draw ROIs
figure(1);
hold on;
for i = 1:length(ROIs)
    plot(ROIs(i).xreg,ROIs(i).yreg,'r')
end
plot(Noise.xnoise,Noise.ynoise,'y')
hold off;

figure(2);
image_fraction = squeeze(alignedimages(:,:,numscans,1));  % takes 1 is the a0 image, (need to change that number to fit the number of scans you have) 
imagesc(image_fraction);
axis off;
colormap(gray);
axis equal;
hold on;

for i = 1:length(ROIs)
    plot(ROIs(i).xreg,ROIs(i).yreg,'r')
end
plot(Noise.xnoise,Noise.ynoise,'y')
hold off;

% Assure you are satisfied with ROIs and Noise defined, if not change them
figure(1);
yesorno = input('Are you satisfied with the ROIs defined? Y/N (Y): ','s');
if yesorno == 'N'|| yesorno == 'n'
    while 1
        change_ROI = input('Which ROI would you like to change? [0 to exit]: ');
        if change_ROI == 0
            break;
        end
        def_num = ['Please define ROI ',num2str(change_ROI),' in Figure 1.'];
        disp(def_num);
        [Mask,xreg,yreg] = roipoly;
        ROIs(change_ROI).Mask = Mask;
        ROIs(change_ROI).xreg = xreg;
        ROIs(change_ROI).yreg = yreg;
        save(strcat(dir, '/ROIs.mat'),'ROIs')
    end
end

figure(1), clf
image_fraction = squeeze(alignedimages(:,:,1,1));
imagesc(image_fraction);
axis off;
colormap(gray);
axis equal;
hold on;
for i = 1:length(ROIs)
    plot(ROIs(i).xreg,ROIs(i).yreg,'r')
end
plot(Noise.xnoise,Noise.ynoise,'y')
hold off;

figure(1)
yesorno = input('Are you satisfied with the Noise defined? Y/N (Y): ', 's');
if yesorno ==  'N'|| yesorno == 'n'
    disp('Please define the noise in Figure 1.');
    [Mask,xnoise,ynoise]=roipoly;
    Noise.Mask = Mask;
    Noise.xnoise = xnoise;
    Noise.ynoise = ynoise;
    save(strcat(dir, '/Noise.mat'),'Noise')
end

figure(1), clf
image_fraction = squeeze(alignedimages(:,:,1,1));
imagesc(image_fraction);
axis off;
colormap(gray);
axis equal;
hold on;
for i = 1:length(ROIs)
    plot(ROIs(i).xreg,ROIs(i).yreg,'m')
end
plot(Noise.xnoise,Noise.ynoise,'c')
save(strcat(dir, '/MRImage.mat'),'image_fraction')

for i = 1:length(ROIs)
    ROIs(i).roiSignal = zeros(count,numbs);
    ROIs(i).roiStdSignal = zeros(count,numbs);
	ROIs(i).VoxelSignal = zeros(count,numbs,sum(ROIs(i).Mask(:)));
end 

Noise.VoxelSignal = zeros(count,numbs);
Noise.stdnoise = zeros(count,numbs);

for expnum = 1:count	
    for bnum = 1:numbs
        image_fraction = squeeze(alignedimages(:,:,expnum,bnum));
        
        for i = 1:length(ROIs)
            ROIs(i).Mask = roipoly(image_fraction,ROIs(i).xreg,ROIs(i).yreg);
            ROIs(i).MaskImage = image_fraction.*double(ROIs(i).Mask);
            ROIs(i).VoxelSignal(expnum,bnum,:) = ROIs(i).MaskImage(find(ROIs(i).MaskImage))';
            ROIs(i).MeanROISignal(expnum,bnum) = mean(ROIs(i).VoxelSignal(expnum,bnum,:));
            ROIs(i).StDevROISignal(expnum,bnum) = std(ROIs(i).VoxelSignal(expnum,bnum,:));
        end
        
        Noise.Mask = roipoly(image_fraction,Noise.xnoise,Noise.ynoise);
        Noise.MaskImage = image_fraction.*double(Noise.Mask);
        Noise.VoxelSignal = Noise.MaskImage(find(Noise.MaskImage));
        Noise.MeanROISignal(expnum,bnum) = mean(Noise.VoxelSignal);
        Noise.StDevROISignal(expnum,bnum) = std(Noise.VoxelSignal);    
    end  
end

save(strcat(dir, '/ROIs.mat'),'ROIs')
save(strcat(dir, '/Noise.mat'),'Noise')

end