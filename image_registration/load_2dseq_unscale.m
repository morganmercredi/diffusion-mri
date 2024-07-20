function [unscaled_image info] = load_2dseq_unscale(serdir, reconum)

% Load a Paravision 2dseq file
%
% Author    : Blair Cardigan Smith & Doug Storey
% Place     : University of Winnipeg
% Dates     : 07/06/2006
% Amended   : Jonathan Thiessen

fname = 'load_2dseq';

% Loads the image information
info = load_info(serdir);

% Dimensions
nx = info.dim(1); ny = info.dim(2);
if info.ndims == 2
   nz = info.nims;
   info.dim(3) = nz;
else
    nz = info.dim(3)*info.nims;
end

% Must be changed if using different reconstruction
reco_num = int2str(reconum);

% RECO location
recofile = [serdir '\pdata\' reco_num '\reco'];

% Checks for existence of Reco file
if exist(recofile) ~= 2
    fprintf('RECO file does not exist')
end;

% Reads RECO file
recoinfo = textread(recofile,'%s','delimiter','\n','whitespace','');

% Checking Resizing of matrix
dim = extract_matrix(recoinfo, '##$RECO_ft_size=');
nx = dim(1);
ny = dim(2);

% Read scaling info
slope = extract_matrix1(recoinfo, '##$RECO_map_slope=');
offset = extract_matrix1(recoinfo, '##$RECO_map_offset=');


% Displays matrix data
% fprintf('\nMatrix size: %d %d %d', nx, ny, nz);

% Open the file
filename = [serdir '\pdata\' reco_num '\2dseq'];
if strcmp(info.endian, 'be') == 1
    fd = fopen(filename,'r','ieee-be');
elseif strcmp(info.endian, 'le') == 1
    fd = fopen(filename,'r','ieee-le');
end
if (fd < 1)
  errmsg = sprintf('%s: Could not open %s to read\n', fname, filename);
  waitfor(errordlg(errmsg));
  return;
end

% Read the data
d = fread(fd, info.datatype);

% Close the file
fclose(fd);

% Check if data set is complete
if (nx*ny*nz ~= length(d))
  beep
  errmsg = sprintf('%s: 2dseq file is incomplete\n', fname);
  waitfor(errordlg(errmsg));
  return;
else
  reshaped = reshape(d, nx, ny, nz);
  unscaled_image = zeros(nx,ny,nz);
  for n=1:nz
      unscaled_image(:,:,n) = round(reshaped(:,:,n)/slope(n) + offset(n));
  end;
end;