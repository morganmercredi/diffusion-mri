function info = load_method_tubes(serdir)

% Loads info from the method, reco, acqp, and subject file.
%
% Author   : Mike Tyszka, Ph.D.
% Location : Caltech BIC
% Dates    : 10/5/2000
% Amended  : May 24, 2006 by Doug Storey & Blair Cardigan Smith

% Prints out a statement if the method file does not exist
methodfile = [serdir 'method'];
if exist(methodfile) == 2
    status = 1;
else
    status = -1;
    fprintf('Method file does not exist.\n')
end

if status == 1
    % Loads the method file information into the matrix recoinfo
    methodinfo = textread(methodfile,'%s','delimiter','\n','whitespace','');

    % Extract useful parameters from method file
    % Extract general image parameters
    info.fov = extract_matrix(methodinfo, '##$PVM_Fov=');
    info.dim = extract_matrix(methodinfo, '##$PVM_Matrix=');
    info.method = extract_string(methodinfo, '##$Method=');
    info.navigate = extract_yesno(methodinfo, '##$PVM_Navigate=');
    info.dimension = extract_string(methodinfo, '##$PVM_SpatDimEnum=');
    info.ndims = length(info.dim);
    
    % Diffusion-weighting gradient duration, separation, direction,
    % amplitude, and maximum diffusion gradient strength on the scanner
    info.graddur = extract_matrix(methodinfo, '##$PVM_DwGradDur=');
    info.gradsep = extract_matrix(methodinfo, '##$PVM_DwGradSep=');
    info.direction = extract_matrix(methodinfo, '##$PVM_DwDir=');
    info.percentgradstrength = extract_matrix1(methodinfo, '##$PVM_DwGradAmp=');    
    info.gradmax = extract_double(methodinfo, '##$PVM_GradCalConst='); 
    
    % Number of diffusion-weighted directions, diffusion-weighted
    % images per experiment, number of experiments, and number of b=0
    % images
    info.ndir = extract_double(methodinfo, '##$PVM_DwNDiffDir=');
    info.ndwi = extract_double(methodinfo, '##$PVM_DwNDiffExpEach=');
    info.numbs = extract_int(methodinfo, '##$PVM_DwNDiffExp=');
    info.NA0 = extract_double(methodinfo, '##$PVM_DwAoImages=');        
    
    if info.method == 'dtiStandard_OGSE'
        info.periods = extract_int(methodinfo, '##$num_of_periods=');
        info.typesinus = extract_string(methodinfo, '##$type_of_sinus=');
    end
        
end

end