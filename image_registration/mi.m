function I=mi(A,B,varargin)
%MI Determines the mutual information of two images
%
%   I=mi(A,B)
%
%   Assumption: 0*log(0)=0
%
%   See also ENTROPY, WENTROPY.

%   jfd, 15-11-2006
    
na = hist(A(:),256);
na = na/sum(na);

nb = hist(B(:),256);
nb = nb/sum(nb);

n2 = hist2(A,B,256);
n2 = n2/sum(n2(:));

%u=n2.*log2(n2./(na'*nb));
%I=sum(u(:));
 
I=minf(n2,na'*nb);
I=sum(I);

% -----------------------

function y=minf(pab,papb)

%u=pab<1e-12 | papb<1e-12;
%v=pab<1e-12 & papb<1e-12;

I=find(papb>1e-12); % function support

% if sum(v(:)) ~= 0
%     error('Problema 0/0.')
% end

u=pab(I);
v=papb(I);
i=find(u<1e-12);

warning off
y=u.*log2(u./v);
warning on

%warning off
%y=pab(I,J).*log2(pab(I,J)./papb(I,J));
%warning on

% assumption: 0*log(0)=0
y(i)=0;

