function [err]=rescale_diff(scale,I,I_transform)

[M N]=size(I);

% Apply transformation with various scale parameters until the correlation 
% between the base and the aligned image is acceptable  
%**************************************************************************
tx=scale(1);
ty=scale(2);
sx=scale(3);
sy=scale(4);
shx=scale(5);
shy=scale(6);
u=scale(7);

Trotation=[cos(u) sin(u) 0; -sin(u) cos(u) 0; 0 0 1;];
Ttranslation=[1 0 0; 0 1 0; tx ty 1;];
Tscale=[sx 0 0; 0 sy 0; 0 0 1;];
Tshear=[1 shy 0; shx 1 0; 0 0 1;];
T=Trotation*Ttranslation*Tscale*Tshear;

Tform=maketform('affine',T);
I_aligned=imtransform(I_transform,Tform,'Xdata',[1 N],'Ydata',[1 M]);
%**************************************************************************

% Find the correlation between the base and the aligned images
%**************************************************************************
err=sum(sum(abs(I - I_aligned)));
%**************************************************************************

end
