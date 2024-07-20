function draw_images(handles)

% Draw images
% Author   : Jonathan Thiessen

if handles.loaded
    if get(handles.reference_display, 'Value')
        axes(handles.axes_images);
        set(handles.axes_images, 'ActivePositionProperty', 'outerposition');
        imagesc(handles.reference(handles.y1:handles.y2, handles.x1:handles.x2)); axis equal; axis off; colormap gray;
    elseif get(handles.target_display, 'Value')
        axes(handles.axes_images);
        set(handles.axes_images, 'ActivePositionProperty', 'outerposition');
        imagesc(handles.target_aligned(handles.y1:handles.y2, handles.x1:handles.x2)); axis equal; axis off; colormap gray;
    end;
        
    axes(handles.axes_difference);
    set(handles.axes_difference, 'ActivePositionProperty', 'outerposition');
    imagesc(handles.difference(handles.y1:handles.y2, handles.x1:handles.x2)); axis equal; axis off; colormap gray;
end;