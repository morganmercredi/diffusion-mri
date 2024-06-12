function s = extract_string(info, tag)
%
% Extract a string from the end of the line containing the tag.
%
% Author   : Mike Tyszka, Ph.D.
% Location : Caltech BIC
% Date     : 11/02/2000 Clone from parxextractstring2.m
% Amnended : May 24, 2006 by Blair Cardigan Smith & Doug Storey

% Default is empty matrix
s = [];

% Search the cell array for the tag
loc = strmatch(tag, info);

% Return if tag not found
if isempty(loc) return;
end

if length(loc) > 1
  fprintf('%s: More than one occurance, using first\n', tag);
  loc = loc(1);
end

% The string follows the '=' in this line
[l,s] = strtok(info{loc},'=');

% Remove the '=' from s
s(1) = [];
