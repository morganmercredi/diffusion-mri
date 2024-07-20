function n=hist2(A,B,L)
%HIST2 Calculates the joint histogram of two images
%
%   n=hist2(A,B,256) is the joint histogram of matrices A and B, using 256
%   bins for each matrix.
%
%   See also MI, HIST.

%   jfd, 15-11-2006, working
%   jfd, 27-11-2006, memory usage reduced (sub2ind)

ma=min(A(:));
MA=max(A(:));
mb=min(B(:));
MB=max(B(:));

A=round((A-ma)*(L-1)/(MA-ma));
B=round((B-mb)*(L-1)/(MB-mb));

for i=0:L-1
    [x y]=find(A==i);
    j=sub2ind(size(A),x,y);
    n(i+1,:)=hist(B(j),0:L-1);
end
