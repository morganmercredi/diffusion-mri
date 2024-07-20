function varargout = manreg(varargin)
% MANREG M-file for manreg.fig
%      MANREG, by itself, creates a new MANREG or raises the existing
%      singleton*.
%
%      H = MANREG returns the handle to a new MANREG or the handle to
%      the existing singleton*.
%
%      MANREG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANREG.M with the given input arguments.
%
%      MANREG('Property','Value',...) creates a new MANREG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manreg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to manreg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manreg

% Last Modified by GUIDE v2.5 28-Jun-2022 00:07:29

%% Initialization
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manreg_OpeningFcn, ...
                   'gui_OutputFcn',  @manreg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before manreg is made visible.
function manreg_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = manreg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Set variable defaults
selpath = uigetdir(path); 
[rootpath, number] = fileparts(selpath);
set(handles.reference_file, 'String', selpath);
set(handles.target_file, 'String',selpath);

sample_name = 'exp';
% check folder name
if isempty(sample_name)
    errordlg('Please check the name format of data folder.','Error');
end
new_expname = strcat(sample_name,'_',number);
set(handles.expname, 'String', new_expname);

new_filename_target = strcat(get(handles.expname, 'String'), '_sl_1_1','.mat');
set(handles.filename_target, 'String', new_filename_target);

info_list = load_info(selpath);
set(handles.nimages, 'String', info_list.nimages);
set(handles.nslices, 'String', sum(info_list.slices));

handles.loaded = 0;
handles.scale=[0 0 1 1 0 0 0];
handles.fixed=zeros(4,1);
handles.ns = 1;  % number of slices
handles.ni = 1;  % number of images
handles.pattern_mode = 1; % Default mode: Slice

set(handles.review_stop, 'UserData',[]);
userData.stop = false;
set(handles.review_stop, 'UserData',userData);

set(handles.reference_display, 'Value', 1);
set(handles.target_display, 'Value', 0);
handles.display_switch = 0;

set(handles.slice_mode, 'Value', 1);
set(handles.incremental_mode, 'Value', 0);
set(handles.Techo_mode, 'Value', 0);

handles.x_trans_store = zeros(1000,1000);
handles.y_trans_store = zeros(1000,1000);
handles.x_scale_store = zeros(1000,1000);
handles.y_scale_store = zeros(1000,1000);
handles.x_shear_store = zeros(1000,1000);
handles.y_shear_store = zeros(1000,1000);
handles.rot_angle_store = zeros(1000,1000);

warning off all;

guidata(hObject, handles);

%Manages the pattern which reference/target images are loaded
function [hObject, eventdata, handles] = get_pattern(hObject, eventdata, handles)
    if(handles.pattern_mode == 1)%Slice (Default)
            set(handles.image_num_target, 'String', num2str(str2num(get(handles.nslices, 'String'))*(handles.ni-1) + handles.ns) );
			set(handles.image_num_reference, 'String', num2str(handles.ns));
    elseif(handles.pattern_mode == 0)%Incremental
            set(handles.image_num_target, 'String', num2str(str2num(get(handles.nslices, 'String'))*(handles.ns-1) + handles.ni) );
			set(handles.image_num_reference, 'String', num2str(handles.ns));
	elseif(handles.pattern_mode == 2)%MGE
			set(handles.image_num_target, 'String', num2str(str2num(get(handles.nslices, 'String'))*(handles.ns-1) + handles.ni) );
			set(handles.image_num_reference, 'String', num2str((handles.ns-1) * str2num(get(handles.nslices, 'String')) + 1));
    end

%% Load Images

function reference_file_Callback(hObject, eventdata, handles)
set(handles.reference_file, 'String', get(hObject,'String'));
guidata(hObject,handles);

function reference_file_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function target_file_Callback(hObject, eventdata, handles)
set(handles.target_file, 'String', get(hObject,'String'));
guidata(hObject,handles);

function target_file_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function image_num_reference_Callback(hObject, eventdata, handles)
set(handles.image_num_reference, 'String', get(hObject,'String'));
set(handles.slice_n, 'String', get(handles.image_num_reference, 'String'));
set(handles.image_n, 'String', '1');
set(handles.ni, 'String', '2');
handles.ns = str2double(get(handles.slice_n, 'String'));
guidata(hObject,handles);

function image_num_reference_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function image_num_target_Callback(hObject, eventdata, handles)
set(handles.image_num_target, 'String', get(hObject,'String'));
guidata(hObject,handles);

function image_num_target_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in load_button.
function [hObject, eventdata, handles] = load_button_Callback(hObject, eventdata, handles)
handles.attrib(1) = 0;
handles.attrib(2) = 1;
handles.loaded = 1;

set(handles.axes_images, 'Visible', 'off');
set(handles.axes_difference, 'Visible', 'off');
axes(handles.axes_images);
cla
axes(handles.axes_difference);
cla
drawnow;

if isnumeric(get(handles.reference_file, 'String'))
    return
else
    [handles.reference_images, handles.target_images] = load_images(handles);
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    [M N]=size(handles.reference);
    handles.x1=1;
    handles.y1=1;
    handles.x2=N;
    handles.y2=M;
    draw_images(handles);
end;
set(handles.statustext, 'String', 'Images Loaded');

if(handles.pattern_mode == 2)
    handles.ns = fix(str2num(get(handles.image_num_reference, 'String'))/str2num(get(handles.nslices, 'String'))  ) +1;
else
    handles.ns = str2double(get(handles.image_num_reference, 'String'));
end;

set(handles.slice_n, 'String', num2str(handles.ns));
set(handles.filename_target, 'String', [get(handles.expname, 'String') '_sl_' get(handles.slice_n, 'String') '_' get(handles.image_n, 'String') '.mat']);
guidata(hObject,handles);


%% File Functions

function filename_images_Callback(hObject, eventdata, handles)
set(handles.filename_images, 'String', get(hObject,'String'));
guidata(hObject,handles);
function filename_images_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;

% --- Executes on button press in save_images.
function save_images_Callback(hObject, eventdata, handles)
if handles.loaded
    save_file = get(handles.filename_images, 'String');
    reference_images = handles.reference_images;
    target_images = handles.target_images;
    reference = handles.reference;
    target = handles.target;
    target_aligned = handles.target_aligned;
    difference = handles.difference;
    scale = handles.scale;
    image_num_reference = handles.image_num_reference;
    image_num_target = handles.image_num_target;
    reference_file = handles.reference_file;
    target_file = handles.target_file;
    set(handles.reference_file, 'String', selpath);
    set(handles.target_file, 'String',selpath);
    save(save_file, 'reference_images', 'target_images', 'reference', 'target', 'target_aligned', 'difference', 'scale', 'image_num_reference', 'image_num_target', 'reference_file', 'target_file');
    set(handles.statustext, 'String', 'Saved Images');
    guidata(hObject, handles);
end;

% --- Executes on button press in load_images.
function load_images_Callback(hObject, eventdata, handles)
current_directory = cd;
[filename,pathname]=uigetfile('*.mat','Load Images', current_directory);
if isnumeric(filename)
    return
elseif handles.loaded
    serdir = fullfile(pathname, filename);
    load(serdir);
    handles.loaded = 1;
    handles.reference_images = reference_images;
    handles.target_images = target_images;
    handles.target = target;
    handles.reference = reference;
    handles.target_aligned = target_aligned;
    handles.difference = difference;
    handles.scale = scale;
    handles.image_num_reference = image_num_reference;
    handles.image_num_target = image_num_target;
    handles.reference_file = reference_file;
    handles.target_file = target_file;
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    draw_images(handles);
    set(handles.statustext, 'String', 'Loaded Images');
    guidata(hObject,handles);
end;

% --- Executes on button press in save_params.
function [hObject, eventdata, handles] = save_params_Callback(hObject, eventdata, handles)
if handles.loaded
    save_file = get(handles.filename_params, 'String');
    scale = handles.scale;
    reference_file = handles.reference_file;
    target_file = handles.target_file;
    image_num_reference = handles.image_num_reference;
    image_num_target = handles.image_num_target;
    save(save_file, 'scale', 'image_num_reference', 'image_num_target', 'reference_file', 'target_file');
    set(handles.statustext, 'String', 'Saved Parameters');
    guidata(hObject, handles);
end;

function load_params_Callback(hObject, eventdata, handles)
current_directory = cd;
[filename,pathname]=uigetfile('*.mat','Load Parameters', current_directory);
if isnumeric(filename)
    return
elseif handles.loaded
    serdir = fullfile(pathname, filename);
    load(serdir);
    handles.loaded = 1;
    handles.scale = scale;
    handles.image_num_reference = image_num_reference;
    handles.image_num_target = image_num_target;
    handles.reference_file = reference_file;
    handles.target_file = target_file;
    
    [handles.reference_images, handles.target_images] = load_images(handles);
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    [M N]=size(handles.reference);
    handles.x1=1;
    handles.y1=1;
    handles.x2=N;
    handles.y2=M;
    draw_images(handles);
    set(handles.statustext, 'String', 'Loaded Parameters');
    guidata(hObject,handles);
end;

function filename_params_Callback(hObject, eventdata, handles)
set(handles.filename_params, 'String', get(hObject,'String'));
guidata(hObject,handles);

function filename_params_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filename_target_Callback(hObject, eventdata, handles)
set(handles.filename_target, 'String', get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function filename_target_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in save_target.
function [hObject, eventdata, handles] = save_target_Callback(hObject, eventdata, handles)
if handles.loaded
    save_file = [get(handles.filename_target, 'String')];
    [~, name, ext] = fileparts(save_file);    
    target_aligned = handles.target_aligned;
    scale = handles.scale;
    reference_file = handles.reference_file;
    target_file = handles.target_file;
    image_num_reference = handles.image_num_reference;
    image_num_target = handles.image_num_target;
    [rootpath, ~] = fileparts(get(handles.reference_file, 'String'));
    [~, save_folder, ~] = fileparts(rootpath);
    save_folder = fullfile('Registered_Images', save_folder);
    if ~isfolder(save_folder)
        mkdir(save_folder);
    end
    save([fullfile(save_folder, name), ext], 'target_aligned', 'scale', 'image_num_reference', 'image_num_target', 'reference_file', 'target_file'); % save file to the folder
    set(handles.statustext, 'String', 'Saved Aligned Image');
    if handles.ni < str2double(get(handles.nimages, 'String'))
        handles.ni = handles.ni + 1;
        set(handles.image_n, 'String', num2str(handles.ni));
    else
        handles.ni = 1;
        set(handles.image_n, 'String', num2str(handles.ni));
        if handles.ns < str2double(get(handles.nslices, 'String'))
            handles.ns = handles.ns + 1;
        else
            handles.ns = 1;
        end;
    end;
    
	[hObject, eventdata, handles] = get_pattern(hObject, eventdata, handles);
        
    set(handles.slice_n, 'String', num2str(handles.ns));
    set(handles.image_n, 'String', num2str(handles.ni));
    guidata(hObject, handles);
end;

% --- Executes on button press in load_target.
function load_target_Callback(hObject, eventdata, handles)
current_directory = cd;
[filename,pathname]=uigetfile('*.mat','Load Target Image (aligned)', current_directory);
if isnumeric(filename)
    return
elseif handles.loaded
    serdir = fullfile(pathname, filename);
    load(serdir);
    handles.loaded = 1;
    handles.target_aligned = target_aligned;
    handles.scale = scale;
    handles.image_num_reference = image_num_reference;
    handles.image_num_target = image_num_target;
    handles.reference_file = reference_file;
    handles.target_file = target_file;
    
    [handles.reference_images, handles.target_images] = load_images(handles);
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    [M N]=size(handles.reference);
    handles.x1=1;
    handles.y1=1;
    handles.x2=N;
    handles.y2=M;
    draw_images(handles);
    set(handles.statustext, 'String', 'Loaded Aligned Image');
    guidata(hObject,handles);
end;


%% Zoom and Full View
% --- Executes on button press in crop_zoom.
function crop_zoom_Callback(hObject, eventdata, handles)
if handles.loaded
    axes(handles.axes_images);
    set(handles.axes_images, 'ActivePositionProperty', 'outerposition');

    handles.crop = getrect;
    handles.x1 = round(handles.crop(1));
    handles.x2 = round(handles.crop(1)+handles.crop(3));
    handles.y1 = round(handles.crop(2));
    handles.y2 = round(handles.crop(2)+handles.crop(4));
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    draw_images(handles);
    guidata(hObject,handles);
end;

% --- Executes on button press in full_view.
function full_view_Callback(hObject, eventdata, handles)
guidata(hObject,handles);
if handles.loaded
    [M N]=size(handles.reference);
    handles.x1 = 1;
    handles.x2 = N;
    handles.y1 = 1;
    handles.y2 = M;
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    draw_images(handles);
    guidata(hObject,handles);
end;

%% Registration (fminsearch)
% Functions for automatic image registration using fminsearch and various
% image comparison methods.

% --- Executes on button press in mi.
function mi_Callback(hObject, eventdata, handles)
if handles.loaded
    handles.scale(1) = str2double(get(handles.x_trans, 'String'));
    handles.scale(2) = str2double(get(handles.y_trans, 'String'));
    handles.scale(3) = str2double(get(handles.x_scale, 'String'));
    handles.scale(4) = str2double(get(handles.y_scale, 'String'));
    handles.scale(5) = str2double(get(handles.x_shear, 'String'));
    handles.scale(6) = str2double(get(handles.y_shear, 'String'));
    handles.scale(7) = str2double(get(handles.rot_angle, 'String'));
    
    handles.bounds(1) = str2double(get(handles.bounds_trans, 'String'));
    handles.bounds(2) = str2double(get(handles.bounds_trans, 'String'));
    handles.bounds(3) = str2double(get(handles.bounds_scale, 'String'));
    handles.bounds(4) = str2double(get(handles.bounds_scale, 'String'));
    handles.bounds(5) = str2double(get(handles.bounds_shear, 'String'));
    handles.bounds(6) = str2double(get(handles.bounds_shear, 'String'));
    handles.bounds(7) = str2double(get(handles.bounds_rot, 'String'));
    
    bounds = handles.bounds;
    initial_scale = handles.scale;
    LB = initial_scale - bounds;
    UB = initial_scale + bounds;
    
    % Normalize reference and target images
    reference = handles.reference./max(max(handles.reference));
    target = handles.target./max(max(handles.target));
    
    options = optimset('MaxFunEvals', 5000, 'MaxIter', 5000, 'TolX', 1e-12);
    reg_scale = fminsearchbnd(@(reg_scale) rescale_mi(reg_scale,reference,target),initial_scale,LB,UB,options);
    handles.scale = reg_scale;
    
    set(handles.x_trans, 'String', num2str(handles.scale(1)));
    set(handles.y_trans, 'String', num2str(handles.scale(2)));
    set(handles.x_scale, 'String', num2str(handles.scale(3)));
    set(handles.y_scale, 'String', num2str(handles.scale(4)));
    set(handles.x_shear, 'String', num2str(handles.scale(5)));
    set(handles.y_shear, 'String', num2str(handles.scale(6)));
    set(handles.rot_angle, 'String', num2str(handles.scale(7)));
    
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    draw_images(handles);
    set(handles.statustext, 'String', 'Registered');
    guidata(hObject,handles);
end;


% --- Executes on button press in correlation.
function [hObject, eventdata, handles] = correlation_Callback(hObject, eventdata, handles)
if handles.loaded
    handles.scale(1) = str2double(get(handles.x_trans, 'String'));
    handles.scale(2) = str2double(get(handles.y_trans, 'String'));
    handles.scale(3) = str2double(get(handles.x_scale, 'String'));
    handles.scale(4) = str2double(get(handles.y_scale, 'String'));
    handles.scale(5) = str2double(get(handles.x_shear, 'String'));
    handles.scale(6) = str2double(get(handles.y_shear, 'String'));
    handles.scale(7) = str2double(get(handles.rot_angle, 'String'));
    
    handles.bounds(1) = str2double(get(handles.bounds_trans, 'String'));
    handles.bounds(2) = str2double(get(handles.bounds_trans, 'String'));
    handles.bounds(3) = str2double(get(handles.bounds_scale, 'String'));
    handles.bounds(4) = str2double(get(handles.bounds_scale, 'String'));
    handles.bounds(5) = str2double(get(handles.bounds_shear, 'String'));
    handles.bounds(6) = str2double(get(handles.bounds_shear, 'String'));
    handles.bounds(7) = str2double(get(handles.bounds_rot, 'String'));
    
    bounds = handles.bounds;
    initial_scale = handles.scale;
    LB = initial_scale - bounds;
    UB = initial_scale + bounds;
    
    % Normalize reference and target images
    reference = handles.reference./max(max(handles.reference));
    target = handles.target./max(max(handles.target));
    
    options = optimset('MaxFunEvals', 5000, 'MaxIter', 5000, 'TolX', 1e-12);
    reg_scale=fminsearchbnd(@(reg_scale) rescale_corr(reg_scale,reference,target),initial_scale,LB,UB,options);
    handles.scale = reg_scale;
    
    set(handles.x_trans, 'String', num2str(handles.scale(1)));
    set(handles.y_trans, 'String', num2str(handles.scale(2)));
    set(handles.x_scale, 'String', num2str(handles.scale(3)));
    set(handles.y_scale, 'String', num2str(handles.scale(4)));
    set(handles.x_shear, 'String', num2str(handles.scale(5)));
    set(handles.y_shear, 'String', num2str(handles.scale(6)));
    set(handles.rot_angle, 'String', num2str(handles.scale(7)));
    
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    draw_images(handles);
    set(handles.statustext, 'String', 'Registered');
    
    [hObject, eventdata, handles] = save_affine_values(hObject, eventdata, handles, str2num(get(handles.image_num_reference, 'String')), str2num(get(handles.image_num_target, 'String')));
    
    guidata(hObject,handles);
end;

% --- Executes on button press in abs_diff.
function abs_diff_Callback(hObject, eventdata, handles)
if handles.loaded
    handles.scale(1) = str2double(get(handles.x_trans, 'String'));
    handles.scale(2) = str2double(get(handles.y_trans, 'String'));
    handles.scale(3) = str2double(get(handles.x_scale, 'String'));
    handles.scale(4) = str2double(get(handles.y_scale, 'String'));
    handles.scale(5) = str2double(get(handles.x_shear, 'String'));
    handles.scale(6) = str2double(get(handles.y_shear, 'String'));
    handles.scale(7) = str2double(get(handles.rot_angle, 'String'));
    
    handles.bounds(1) = str2double(get(handles.bounds_trans, 'String'));
    handles.bounds(2) = str2double(get(handles.bounds_trans, 'String'));
    handles.bounds(3) = str2double(get(handles.bounds_scale, 'String'));
    handles.bounds(4) = str2double(get(handles.bounds_scale, 'String'));
    handles.bounds(5) = str2double(get(handles.bounds_shear, 'String'));
    handles.bounds(6) = str2double(get(handles.bounds_shear, 'String'));
    handles.bounds(7) = str2double(get(handles.bounds_rot, 'String'));
    
    bounds = handles.bounds;
    initial_scale = handles.scale;
    LB = initial_scale - bounds;
    UB = initial_scale + bounds;
    
    % Normalize reference and target images
    reference = handles.reference./max(max(handles.reference));
    target = handles.target./max(max(handles.target));
    
    options = optimset('MaxFunEvals', 5000, 'MaxIter', 5000, 'TolX', 1e-12);
    reg_scale=fminsearchbnd(@(reg_scale) rescale_diff(reg_scale,reference,target),initial_scale,LB,UB,options);
    handles.scale = reg_scale;
    
    set(handles.x_trans, 'String', num2str(handles.scale(1)));
    set(handles.y_trans, 'String', num2str(handles.scale(2)));
    set(handles.x_scale, 'String', num2str(handles.scale(3)));
    set(handles.y_scale, 'String', num2str(handles.scale(4)));
    set(handles.x_shear, 'String', num2str(handles.scale(5)));
    set(handles.y_shear, 'String', num2str(handles.scale(6)));
    set(handles.rot_angle, 'String', num2str(handles.scale(7)));
    
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    draw_images(handles);
    set(handles.statustext, 'String', 'Registered');
    guidata(hObject,handles);
end;

%% Image Display
% --- Executes on button press in reference_display.
function reference_display_Callback(hObject, eventdata, handles)
set(handles.reference_display, 'Value', 1);
set(handles.target_display, 'Value', 0);
handles.display_switch = 0;
[handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
draw_images(handles);
guidata(hObject,handles);

% --- Executes on button press in target_display.
function [hObject, eventdata, handles] = target_display_Callback(hObject, eventdata, handles)
set(handles.reference_display, 'Value', 0);
set(handles.target_display, 'Value', 1);
handles.display_switch = 1;
[handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
draw_images(handles);
guidata(hObject,handles);

% --- Executes on button press in poi.
function poi_Callback(hObject, eventdata, handles)
if handles.loaded
    axes(handles.axes_difference);
    [xp1 yp1] = ginput(1);
    handles.xp1 = round(xp1)+handles.x1-1;
    handles.yp1 = round(yp1)+handles.y1-1;
    set(handles.difference_poi, 'String', num2str(handles.difference(handles.yp1, handles.xp1)*100));
end;
guidata(hObject,handles);


%% Affine Transformation Parameters

% --- Executes on button press in reset_values.
function reset_values_Callback(hObject, eventdata, handles)
set(handles.x_trans, 'String', '0');
set(handles.y_trans, 'String', '0');
set(handles.x_scale, 'String', '1');
set(handles.y_scale, 'String', '1');
set(handles.x_shear, 'String', '0');
set(handles.y_shear, 'String', '0');
set(handles.rot_angle, 'String', '0');
set(handles.bounds_trans, 'String', '5');
set(handles.bounds_scale, 'String', '0');
set(handles.bounds_shear, 'String', '0');
set(handles.bounds_rot, 'String', '0.1');

function [hObject, eventdata, handles] = load_affine_values(hObject, eventdata, handles, reference, target)
    set(handles.x_trans, 'String', num2str(handles.x_trans_store(reference,target)));
    set(handles.y_trans, 'String', num2str(handles.y_trans_store(reference,target)));
    set(handles.x_scale, 'String', num2str(handles.x_scale_store(reference,target)));
    set(handles.y_scale, 'String', num2str(handles.y_scale_store(reference,target)));
    set(handles.x_shear, 'String', num2str(handles.x_shear_store(reference,target)));
    set(handles.y_shear, 'String', num2str(handles.y_shear_store(reference,target)));
    set(handles.rot_angle, 'String', num2str(handles.rot_angle_store(reference,target)));
    
function [hObject, eventdata, handles] = save_affine_values(hObject, eventdata, handles, reference, target)
    handles.x_trans_store(reference,target) = str2double(get(handles.x_trans,'String'));
    handles.y_trans_store(reference,target) = str2double(get(handles.y_trans,'String'));
    handles.x_scale_store(reference,target) = str2double(get(handles.x_scale,'String'));
    handles.y_scale_store(reference,target) = str2double(get(handles.y_scale,'String'));
    handles.x_shear_store(reference,target) = str2double(get(handles.x_shear,'String'));
    handles.y_shear_store(reference,target) = str2double(get(handles.y_shear,'String'));
    handles.rot_angle_store(reference,target) = str2double(get(handles.rot_angle,'String'));

% --- Executes on button press in redraw.
function [hObject, eventdata, handles] = redraw_Callback(hObject, eventdata, handles)
if handles.loaded
    [handles.reference, handles.target, handles.target_aligned, handles.difference] = calc_images(handles);
    draw_images(handles);
end;

function x_trans_Callback(hObject, eventdata, handles)
set(handles.x_trans, 'String', get(hObject,'String'));
guidata(hObject,handles);

function x_trans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function y_trans_Callback(hObject, eventdata, handles)
set(handles.y_trans, 'String', get(hObject,'String'));
guidata(hObject,handles);

function y_trans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x_scale_Callback(hObject, eventdata, handles)
set(handles.x_scale, 'String', get(hObject,'String'));
guidata(hObject,handles);

function x_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function y_scale_Callback(hObject, eventdata, handles)
set(handles.y_scale, 'String', get(hObject,'String'));
guidata(hObject,handles);

function y_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function x_shear_Callback(hObject, eventdata, handles)
set(handles.x_shear, 'String', get(hObject,'String'));
guidata(hObject,handles);

function x_shear_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function y_shear_Callback(hObject, eventdata, handles)
set(handles.y_shear, 'String', get(hObject,'String'));
guidata(hObject,handles);

function y_shear_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rot_angle_Callback(hObject, eventdata, handles)
set(handles.rot_angle, 'String', get(hObject,'String'));
guidata(hObject,handles);

function rot_angle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function bounds_trans_Callback(hObject, eventdata, handles)
set(handles.bounds_trans, 'String', get(hObject,'String'));
guidata(hObject,handles);

function bounds_trans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bounds_scale_Callback(hObject, eventdata, handles)
set(handles.bounds_scale, 'String', get(hObject,'String'));
guidata(hObject,handles);

function bounds_scale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bounds_shear_Callback(hObject, eventdata, handles)
set(handles.bounds_shear, 'String', get(hObject,'String'));
guidata(hObject,handles);

function bounds_shear_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bounds_rot_Callback(hObject, eventdata, handles)
set(handles.bounds_rot, 'String', get(hObject,'String'));
guidata(hObject,handles);

function bounds_rot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nslices_Callback(hObject, eventdata, handles)
set(handles.nslices, 'String', get(hObject,'String'));
guidata(hObject,handles);

function nslices_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nimages_Callback(hObject, eventdata, handles)
set(handles.nimages, 'String', get(hObject,'String'));
guidata(hObject,handles);

function nimages_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expname_Callback(hObject, eventdata, handles)
set(handles.expname, 'String', get(hObject,'String'));
guidata(hObject,handles);

function expname_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function load_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over load_button.
function load_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in AUTO.
function AUTO_Callback(hObject, eventdata, handles)
    load_button_Callback(hObject, eventdata, handles);
    correlation_Callback(hObject, eventdata, handles);
    save_target_Callback(hObject, eventdata, handles);

% hObject    handle to AUTO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function AUTO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AUTO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over AUTO.
function AUTO_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to AUTO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in AUTOALL.
function AUTOALL_Callback(hObject, eventdata, handles)
    handles.start_target = str2num(get(handles.image_num_target, 'String'));
    for auto_i = handles.start_target:(str2num(get(handles.nimages, 'String')) * str2num(get(handles.nslices, 'String')))
        [hObject, eventdata, handles] = load_button_Callback(hObject, eventdata, handles);
        [hObject, eventdata, handles] = correlation_Callback(hObject, eventdata, handles);
        [hObject, eventdata, handles] = save_target_Callback(hObject, eventdata, handles);   
    end
  
    %subfolder = dir(rootpath);
    %num_subfolder = length(subfolder) - 2 - 3;  % number of slices
    splitcells = regexp(get(handles.expname, 'String'),'_','split');
    new_expname = strcat(splitcells{1,1}, '_',num2str(str2num(splitcells{1,2})+1));
    set(handles.expname, 'String', new_expname);
        
    splitcells = regexp(get(handles.filename_target, 'String'),'_','split');
    new_filename_target = strcat(splitcells{1,1}, '_',num2str(str2num(splitcells{1,2})+1), '_',splitcells{1,3}, '_', splitcells{1,4},'_', get(handles.image_n, 'String') , '.mat');
    set(handles.filename_target, 'String', new_filename_target);
    
    [rootpath, name, ~] = fileparts(get(handles.target_file, 'String'));
    new_target_file = strcat(rootpath, '\',num2str(str2num(name)+1));
    set(handles.target_file, 'String',new_target_file);
    
% hObject    handle to AUTOALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function AUTOALL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AUTOALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over AUTOALL.
function AUTOALL_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to AUTOALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in review_forward.
function [hObject, eventdata, handles] = review_forward_Callback(hObject, eventdata, handles)
    if (handles.display_switch == 1)
        handles.display_switch = 0;
        set(handles.reference_display, 'Value', 1);
        set(handles.target_display, 'Value', 0);
        reference_display_Callback(hObject, eventdata, handles);
       
    elseif (handles.display_switch == 0)
        handles.display_switch = 1;
        if handles.ni < str2double(get(handles.nimages, 'String'))
            handles.ni = handles.ni + 1;
            set(handles.image_n, 'String', num2str(handles.ni));
        else
            handles.ni = 1;
            set(handles.image_n, 'String', num2str(handles.ni));
            if handles.ns < str2double(get(handles.nslices, 'String'))
                handles.ns = handles.ns + 1;
            else
                handles.ns = 1;
            end;
        end;
        
        [hObject, eventdata, handles] = get_pattern(hObject, eventdata, handles);
        
        set(handles.slice_n, 'String', num2str(handles.ns));
        set(handles.image_n, 'String', num2str(handles.ni));
        
        [hObject, eventdata, handles] = load_affine_values(hObject, eventdata, handles, str2num(get(handles.image_num_reference, 'String')), str2num(get(handles.image_num_target, 'String')));
        
        [hObject, eventdata, handles] = target_display_Callback(hObject, eventdata, handles);
        [hObject, eventdata, handles] = redraw_Callback(hObject, eventdata, handles);
        
        set(handles.reference_display, 'Value', 0);
        set(handles.target_display, 'Value', 1);
        
    end;
% hObject    handle to review_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function review_forward_CreateFcn(hObject, eventdata, handles)
% hObject    handle to review_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over review_forward.
function review_forward_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to review_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in review_back.
function [hObject, eventdata, handles] = review_back_Callback(hObject, eventdata, handles)
    if (handles.display_switch == 1)
        handles.display_switch = 0;
        reference_display_Callback(hObject, eventdata, handles);
        set(handles.reference_display, 'Value', 1);
        set(handles.target_display, 'Value', 0);
    elseif (handles.display_switch == 0)
        handles.display_switch = 1;
        if handles.ni > 0
            handles.ni = handles.ni - 1;
            set(handles.image_n, 'String', num2str(handles.ni));
        else
            handles.ni = str2double(get(handles.nimages, 'String'));
            set(handles.image_n, 'String', num2str(handles.ni));
            if handles.ns > 0
                handles.ns = handles.ns - 1;
            %else
            %    handles.ns = str2double(get(handles.nslices, 'String'));
            end;
        end;
        
        [hObject, eventdata, handles] = get_pattern(hObject, eventdata, handles);
        
        set(handles.slice_n, 'String', num2str(handles.ns));
        set(handles.image_n, 'String', num2str(handles.ni));
        
        [hObject, eventdata, handles] = load_affine_values(hObject, eventdata, handles, str2num(get(handles.image_num_reference, 'String')), str2num(get(handles.image_num_target, 'String')));
        
        [hObject, eventdata, handles] = target_display_Callback(hObject, eventdata, handles);
        [hObject, eventdata, handles] = redraw_Callback(hObject, eventdata, handles);
        
        set(handles.reference_display, 'Value', 0);
        set(handles.target_display, 'Value', 1);
    end;
% hObject    handle to review_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function review_back_CreateFcn(hObject, eventdata, handles)
% hObject    handle to review_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over review_back.
function review_back_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to review_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function n_increment_Callback(hObject, eventdata, handles)
    set(handles.n_increment, 'String', get(hObject,'String'));
    guidata(hObject,handles);
% hObject    handle to n_increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_increment as text
%        str2double(get(hObject,'String')) returns contents of n_increment as a double


% --- Executes during object creation, after setting all properties.
function n_increment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in review.
function review_Callback(hObject, eventdata, handles)
   handles.start_target = str2num(get(handles.image_num_target, 'String'));
   for auto_i = handles.start_target :(str2num(get(handles.nimages, 'String')) * str2num(get(handles.nslices, 'String')) * 2)
        [hObject, eventdata, handles] = review_forward_Callback(hObject, eventdata, handles);
        pause(str2double(get(handles.review_time,'String')));
        
        userData = get(handles.review_stop, 'UserData');
        
        if(userData.stop == true)
           userData.stop = false;
           set(handles.review_stop, 'UserData', userData);
           break;
        end
        
        if(str2num(get(handles.image_num_target, 'String')) == (str2num(get(handles.nimages, 'String')) * str2num(get(handles.nslices, 'String'))))
            break;
        end
    end
% hObject    handle to review (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function review_CreateFcn(hObject, eventdata, handles)
% hObject    handle to review (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over review.
function review_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to review (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function review_time_Callback(hObject, eventdata, handles)
    set(handles.review_time, 'String', get(hObject,'String'));
    guidata(hObject,handles);
% hObject    handle to review_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of review_time as text
%        str2double(get(hObject,'String')) returns contents of review_time as a double


% --- Executes during object creation, after setting all properties.
function review_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to review_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in review_stop.
function review_stop_Callback(hObject, eventdata, handles)
    userData = get(handles.review_stop, 'UserData');
    userData.stop = true;
    set(handles.review_stop, 'UserData', userData);
% hObject    handle to review_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function review_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to review_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over review_stop.
function review_stop_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to review_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in slice_mode.
function slice_mode_Callback(hObject, eventdata, handles)
    set(handles.slice_mode, 'Value', 1);
    set(handles.incremental_mode, 'Value', 0);
    set(handles.Techo_mode, 'Value', 0);
    handles.pattern_mode = 1;
    guidata(hObject,handles);
% hObject    handle to slice_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slice_mode


% --- Executes on button press in incremental_mode.
function incremental_mode_Callback(hObject, eventdata, handles)
    set(handles.slice_mode, 'Value', 0);
    set(handles.Techo_mode, 'Value', 0);
    set(handles.incremental_mode, 'Value', 1);
    handles.pattern_mode = 0;
    guidata(hObject,handles);
% hObject    handle to incremental_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of incremental_mode


% --- Executes during object creation, after setting all properties.
function slice_mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slice_mode.
function slice_mode_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slice_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function incremental_mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to incremental_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over incremental_mode.
function incremental_mode_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to incremental_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Techo_mode.
function Techo_mode_Callback(hObject, eventdata, handles)
    set(handles.Techo_mode, 'Value', 1);
    set(handles.slice_mode, 'Value', 0);
    set(handles.incremental_mode, 'Value', 0);
    handles.pattern_mode = 2;
    guidata(hObject,handles);
% hObject    handle to Techo_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Techo_mode


% --- Executes during object creation, after setting all properties.
function Techo_mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Techo_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Techo_mode.
function Techo_mode_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Techo_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function correlation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function statustext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statustext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
