function yn = extract_yesno(info, tag)
%
% Extract a YesNo following the tag
%
% Author   : Mike Tyszka, Ph.D.
% Location : Caltech BIC
% Date     : 10/05/2000 From scratch
% Amended  : May 24, 2006 by Blair Cardigan Smith & Doug Storey

% Default is empty matrix
yn = logical(0);

% Search the cell array for the tag
loc = strmatch(tag, info);

% Return if tag not found
if isempty(loc) return; end

if length(loc) > 1
  loc = loc(1);
end

% The answer follows the '=' on this line
s = info{loc};
yn = isempty(findstr('No', s));
