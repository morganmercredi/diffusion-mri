function [reference target target_aligned difference] = calc_images(handles)

% Calculate images for registration.
%
% Author   : Jonathan Thiessen
% Location : University of Winnipeg
% Dates    : 7/7/2008

reference_num = str2double(get(handles.image_num_reference, 'String'));
target_num = str2double(get(handles.image_num_target, 'String'));

reference = fliplr(rot90(handles.reference_images(:,:,reference_num)));
target = fliplr(rot90(handles.target_images(:,:,target_num)));

[M N] = size(reference);

tx = str2double(get(handles.x_trans, 'String'));
ty = str2double(get(handles.y_trans, 'String'));
sx = str2double(get(handles.x_scale, 'String'));
sy = str2double(get(handles.y_scale, 'String'));
shx = str2double(get(handles.x_shear, 'String'));
shy = str2double(get(handles.y_shear, 'String'));
u = str2double(get(handles.rot_angle, 'String'));
    
% Construct T matrix for rotation and translation
Trotation=[cos(u) sin(u) 0; -sin(u) cos(u) 0; 0 0 1;];
Ttranslation=[1 0 0; 0 1 0; tx ty 1;];
Tscale=[sx 0 0; 0 sy 0; 0 0 1;];
Tshear=[1 shy 0; shx 1 0; 0 0 1;];
T=Trotation*Ttranslation*Tscale*Tshear;

% Align the target image
Tform=maketform('affine',T);
target_aligned=imtransform(target,Tform,'Xdata',[1 N],'Ydata',[1 M]);
    
% Calculate percent difference image with transformed image
for x=1:N
    for y=1:M
        if reference(y,x) == 0
            difference(y,x) = 0;
        else
            difference(y,x) = abs(reference(y,x)-target_aligned(y,x))/reference(y,x);

            if difference(y,x) > 1
                difference(y,x) = 1;
            end;
            if difference(y,x) < 0 
                difference(y,x) = 0;
            end;
        end;
    end;
end;