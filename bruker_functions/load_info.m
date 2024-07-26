function info = load_info(serdir)

% Loads info from the IMND, reco, acqp, and subject file.
%
% Author   : Mike Tyszka, Ph.D.
% Location : Caltech BIC
% Dates    : 10/5/2000
% Amended  : May 24, 2006 by Doug Storey & Blair Cardigan Smith


% Default status
status = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          %
%                  IMND                    %
%                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Left out from original imnd file:
%   info.venc
%   info.vencdir
%   info.bpm
%   info.numechoes
%   info.te
%   info.rarefactor
%   info.littledelta
%   info.bigdelta
%   info.littleg
%   info.diffidr

% Prints out a statement if IMND does not exist
methodfile = [serdir '/method'];
imndfile = [serdir '/imnd'];
if exist(methodfile) == 2
    status = 1;
elseif exist(imndfile) == 2
    status = 2;
else
    status = -1;
    fprintf('IMND and Method file do not exist')
end;

if status == 1
    % Loads the imnd file information into the matrix recoinfo
    imndinfo = textread(methodfile,'%s','delimiter','\n','whitespace','');

    % Extract useful parameters from imnd file
    info.fov = extract_matrix(imndinfo, '##$PVM_Fov=');
    info.dim = extract_matrix(imndinfo, '##$PVM_Matrix=');
    info.slices = extract_matrix(imndinfo, '##$PVM_SPackArrNSlices');
    info.method = extract_string(imndinfo, '##$Method=');
    info.nimages = extract_string(imndinfo,'##$PVM_DwNDiffExp=');
    info.navigate = extract_yesno(imndinfo, '##$PVM_Navigate=');
    info.dimension = extract_string(imndinfo, '##$PVM_SpatDimEnum=');
    info.encoding = [];
    
    info.ndims = length(info.dim);
    
elseif status == 2
    % Loads the imnd file information into the matrix recoinfo
    imndinfo = textread(imndfile,'%s','delimiter','\n','whitespace','');

    % Extract useful parameters from imnd file
    info.fov = extract_matrix(imndinfo, '##$IMND_fov=');
    info.dim = extract_matrix(imndinfo, '##$IMND_matrix=');
    info.method = extract_string2(imndinfo, '##$IMND_method=');
    info.navigate = extract_yesno(imndinfo, '##$IMND_navigate=');
    info.dimension = extract_string(imndinfo, '##$IMND_dimension=_');
    info.encoding = extract_string(imndinfo, '##$IMND_phase_encoding_mode_1=');
    
    info.ndims = ndims(info.dim);
    
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          %
%                 reco                     %
%                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Find data type, ie: int32, short, float, etc, from reco file to use in
% analyser programs.  User inputs directory loaction of fid file, serdir.
% Scan number is the file containing the reco file.
% Note: Only distinguishes between int16 and int32 data types.


% Finds scan number
scan_num = '1'; %If your looking at a different reco, this must be changed
reco_loc = ['/pdata/' scan_num '/reco'];

% Loads the reco file information into the matrix recoinfo
recofile = [serdir reco_loc];
recoinfo = textread(recofile,'%s','delimiter','\n','whitespace','');

% Extracts the data type from the reco file
datatype = extract_string(recoinfo, '##$RECO_wordtype=');

% Saves the data typ, int 32 or int16, into the info matrix
if strcmp(datatype, '_32BIT_SGN_INT') == 1
    info.datatype = 'int32';
elseif strcmp(datatype, '_16BIT_SGN_INT') == 1
    info.datatype = 'int16';
else
    beep
    fprintf('Data type other then int32 or int16.\n');
end

% Extracts endian type.
endian = extract_string(recoinfo, '##$RECO_byte_order=');

if strcmp(endian, 'bigEndian') == 1
    info.endian = 'be';
elseif strcmp(endian, 'littleEndian') == 1
    info.endian = 'le';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          %
%                   ACQP                   %
%                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Check for existence of imnd file
acqpfile = [serdir '/acqp'];
if exist(acqpfile) ~= 2
  status = -2;
  return;
end;

% Prints out a statement if ACQP does not exist
if status == -2
    fprintf('ACQP file does not exist')
end

% Loads the acqp file information into the matrix acqpinfo
acqpinfo = textread(acqpfile,'%s','delimiter','\n','whitespace','');

% Extract useful parameters from acqp file
slices = extract_double(acqpinfo, '##$NI=');
rep = extract_double(acqpinfo, '##$NR=');

info.nims = slices * rep;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          %
%                subject                   %
%                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Check for existence of subject file
subjfile = [serdir '/../subject'];
if exist(subjfile) ~= 2
  status = -3;
  return;
end;

% Prints out a statement if subject does not exist
if status == -3
    fprintf('subject file does not exist')
end

% Loads the subject file information into the matrix recoinfo
subjinfo = textread(subjfile,'%s','delimiter','\n','whitespace','');


% Extract useful parameters from subject file
info.id = extract_string2(subjinfo, '##$SUBJECT_id=');
info.name = extract_string2(subjinfo, '##$SUBJECT_name_string=');