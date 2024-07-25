function m = extract_matrix(info, tag)
%
% Extract a matrix of values from the cell array 'info'
% and return in m. Searches for the parameter tag and
% parses the following line for values.
%
% Author   : Mike Tyszka, Ph.D.
% Location : Caltech BIC
% Date     : 10/05/2000 From scratch
% Amended  : May 24, 2006 by Blair Cardigan Smith & Doug Storey

% Default value is empty matrix
m = [];

% Search the cell array for the tag
loc = strmatch(tag, info);

% If FOV field not present return default value
if isempty(loc) return; end

if length(loc) > 1
  loc = loc(1);
end

% The matrix values are in the next cell
ms = info{loc+1};

% Convert list of ASCII reals to matrix
m = sscanf(ms, '%f');
