function m = extract_matrix1(info, tag)
%
% Extract a 1D matrix of values from the cell array 'info'
% and return in m. Searches for the parameter tag and
% parses the following line for values.
%
% Author   : Jonathan Thiessen
% Location : University of Winnipeg
% Date     : August 3, 2011

% Search the info array for the tag
loc = strmatch(tag, info);
mparams = info{loc};

locinc = loc+1;
ms = info{locinc};

% Extract matrix dimensions
mspace = strfind(mparams, ' ');
mn = str2double(mparams(mspace(1)+1:mspace(2)-1));

m = zeros(mn);

% Extract matrix values
while strncmp(info(locinc+1), '#', 1) ~= 1
    locinc = locinc+1;
    ms = [ms, info{locinc}];
end;

% Reshape matrix values into mx x my x mn matrix
m = sscanf(ms, '%f');
