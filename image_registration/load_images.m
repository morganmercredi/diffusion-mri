function [reference_images target_images] = load_images(handles)

% Loads images for registration.
%
% Author   : Jonathan Thiessen
% Location : University of Winnipeg
% Dates    : 7/7/2008

reference_images = load_2dseq_unscale(get(handles.reference_file, 'String'), 1);
target_images = load_2dseq_unscale(get(handles.target_file, 'String'), 1);

%{
bthresh = 0.1;
bmin = 100;
nimages = length(reference_images(1,1,:));

for m=1:nimages
    A0_int = squeeze(mat2gray(reference_images(:,:,m)));
    bw = im2bw(A0_int, bthresh);
    bw2(:,:,m) = imfill(bwareaopen(bw,bmin), 'holes');
end;
%}