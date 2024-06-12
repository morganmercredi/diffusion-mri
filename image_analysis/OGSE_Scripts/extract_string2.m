function s = extract_string2(info, tag)
%
% Extract a string from the line following the tag.
%
% Author   : Mike Tyszka, Ph.D.
% Location : Caltech BIC
% Date     : 10/5/2000 From scratch
% Amended  : May 24, 2006 by Blair Cardigan Smith

% Default is empty matrix
s = [];

% Search the cell array for the tag
loc = strmatch(tag, info);

% Return if tag not found
if isempty(loc) return; end

if length(loc) > 1
  fprintf('%s: More than one occurance, using first\n', tag);
  loc = loc(1);
end

% The string is in the next cell
s = info{loc+1};
