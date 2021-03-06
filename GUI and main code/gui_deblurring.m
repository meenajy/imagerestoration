function varargout = gui_deblurring(varargin)
% GUI_DEBLURRING MATLAB code for gui_deblurring.fig
%      GUI_DEBLURRING, by itself, creates a new GUI_DEBLURRING or raises the existing
%      singleton*.
%
%      H = GUI_DEBLURRING returns the handle to a new GUI_DEBLURRING or the handle to
%      the existing singleton*.
%
%      GUI_DEBLURRING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DEBLURRING.M with the given input arguments.
%
%      GUI_DEBLURRING('Property','Value',...) creates a new GUI_DEBLURRING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_deblurring_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_deblurring_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_deblurring

% Last Modified by GUIDE v2.5 14-Oct-2018 22:09:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_deblurring_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_deblurring_OutputFcn, ...
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


% --- Executes just before gui_deblurring is made visible.
function gui_deblurring_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);


function varargout = gui_deblurring_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in loadimage.
function loadimage_Callback(hObject, eventdata, handles)
global original_image original_image_d original_image_r original_image_g original_image_b original_image_v orig_size fft2_original_img_r fft2_original_img_b fft2_original_img_g fft2_original_img_v
global dft_flag
[path,user_canceled]=imgetfile();  
if user_canceled
    msgbox(sprintf('Error'),'Error','Error'); %display error message
    return
end


set(handles.inbuilt_dft,'Enable','off');
set(handles.external_dft,'Enable','off');

if get(handles.inbuilt_dft,'Value')
    dft_flag = 0;
end

if get(handles.external_dft,'Value')
    dft_flag = 1;
end



original_image = imread(path);
original_image_d = im2double(original_image);
original_image_r = original_image_d(:,:,1);
original_image_g = original_image_d(:,:,2);
original_image_b = original_image_d(:,:,3);
original_image_v = (original_image_r + original_image_g + original_image_b)/3;
orig_size = size(original_image_b);

fft2_original_img_r = fft2(original_image_r);
fft2_original_img_g = fft2(original_image_g);
fft2_original_img_b = fft2(original_image_b);

axes(handles.axes1);
imshow(original_image_d);

% --- Executes on button press in load_kernel.
function load_kernel_Callback(hObject, eventdata, handles)
global blur_size blur_kernel
[path,user_canceled]=imgetfile();  
if user_canceled
    msgbox(sprintf('Error'),'Error','Error'); %display error message
    return
end
blur_kernel = imread(path); 
blur_kernel_d = im2double(blur_kernel);
blur_transformed_hsv = rgb2hsv(blur_kernel_d);
blur_kernel = blur_transformed_hsv(:,:,3);
normalize = sum(blur_kernel(:))
blur_kernel = (blur_transformed_hsv(:,:,3))/normalize;
blur_size = size(blur_kernel);
axes(handles.axes4);
imshow(blur_kernel*normalize);


% --- Executes on button press in load_blur_image.
function load_blur_image_Callback(hObject, eventdata, handles)
global already_blur_image already_blur_image_d
[path,user_canceled]=imgetfile();  
if user_canceled
    msgbox(sprintf('Error'),'Error','Error'); %display error message
    return
end
%imread used for reading image as a matrix according to path
already_blur_image = imread(path); 
already_blur_image_d = im2double(already_blur_image);





% --- Executes on button press in Blur_function.
function Blur_function_Callback(hObject, eventdata, handles)
global blur_img orig_size blur_size blur_kernel fft2_original_img_r fft2_original_img_g fft2_original_img_b fft2_original_img_v
global fft2_pad_blur dft_flag blur_img_v original_image_v
pad_blur = zeros(orig_size(1),orig_size(2));
pad_blur(1:blur_size(1),1:blur_size(2)) = blur_kernel;
fft2_pad_blur = my_dft(pad_blur,dft_flag);
%{
fft2_blur_img_r = ifft2(fft2_pad_blur.*fft2_original_img_r);
fft2_blur_img_g = fft2_pad_blur.*fft2_original_img_g;
fft2_blur_img_b = fft2_pad_blur.*fft2_original_img_b;
fft2_blur_img_v = fft2_pad_blur.*fft2_original_img_v;
%}
blur_img = zeros(orig_size(1),orig_size(2),3);
blur_img(:,:,1) = my_idft(fft2_pad_blur.*fft2_original_img_r,dft_flag);
blur_img(:,:,2) = my_idft(fft2_pad_blur.*fft2_original_img_g,dft_flag);
blur_img(:,:,3) = my_idft(fft2_pad_blur.*fft2_original_img_b,dft_flag);


if get(handles.add_noise,'Value')
prompt = {'Enter value sigma for gaussian additive noise) :'};
title = ' sigma for gaussian additive noise';
%dimension of dialog box
dims = [1 35];
%default inuput of dialog box
definput = {'1'};
%answer will save entered value in array form
answer = inputdlg(prompt,title,dims,definput);
%str2double convert srting to numeric value
sigma = str2double(answer{1})/255;

blur_img = blur_img + sigma*sigma*randn(orig_size(1),orig_size(2),3);
end

blur_img_v = (blur_img(:,:,1) + blur_img(:,:,2) + blur_img(:,:,3))/3

ssim_blur = my_ssim(blur_img_v,original_image_v);
psnr_blur = my_psnr(blur_img_v,original_image_v);
    set(handles.ssim_blur,'String',num2str(ssim_blur));
    set(handles.psnr_blur,'String',num2str(psnr_blur));

axes(handles.axes2);
imshow(blur_img);




% --- Executes on button press in Deblur.
function Deblur_Callback(hObject, eventdata, handles)
global get_blur_img_r get_blur_img_b get_blur_img_g get_blur_img_v get_fft2_blur_img_v get_fft2_blur_img_r get_fft2_blur_img_g get_fft2_blur_img_b already_blur_image_d blur_img
global orig_size fft2_pad_blur original_image_v final_deblur_img dft_flag i
if get(handles.orig_image,'Value') 
get_blur_img_r = blur_img(:,:,1);
get_blur_img_g = blur_img(:,:,2);
get_blur_img_b = blur_img(:,:,3);
get_blur_img_v = (get_blur_img_r + get_blur_img_g + get_blur_img_b)/3;
get_fft2_blur_img_v = my_dft(get_blur_img_v,dft_flag);
get_fft2_blur_img_r = my_dft(get_blur_img_r,dft_flag);
get_fft2_blur_img_g = my_dft(get_blur_img_g,dft_flag);
get_fft2_blur_img_b = my_dft(get_blur_img_b,dft_flag);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if get(handles.blur_image,'Value')
    already_blur_image_r = already_blur_image_d(:,:,1);
    already_blur_image_g = already_blur_image_d(:,:,2);
    already_blur_image_b = already_blur_image_d(:,:,3);
    already_blur_image_v = (already_blur_image_b+already_blur_image_g+already_blur_image_r)/3;

    get_fft2_blur_img_v = my_dft(already_blur_image_v,dft_flag);
    get_fft2_blur_img_r = my_dft(already_blur_image_r,dft_flag);
    get_fft2_blur_img_g = my_dft(already_blur_image_g,dft_flag);
    get_fft2_blur_img_b = my_dft(already_blur_image_b,dft_flag);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if get(handles.inverse_filter,'Value') 
    
        prompt = {'Enter upper range of threshold value:','Enter lower range of threshold value:'};
        title = 'Value of threshold value';
        %dimension of dialog box
        dims = [1 35];
        %default inuput of dialog box
        definput = {'0.001','0.1'};
        %answer will save entered value in array form
        answer = inputdlg(prompt,title,dims,definput);
        %str2double convert srting to numeric value
        t_value_lowerlimit = str2double(answer{1});
        t_value_upperlimit = str2double(answer{2});

        delta_t_value = (t_value_upperlimit-t_value_lowerlimit)/9;
    
        ssim_values = zeros(10,1);

    for i=1:10
        
        t_value = t_value_lowerlimit + delta_t_value*(i-1);
		
		fft2_for_debluring = fft2_pad_blur;
		fft2_for_debluring(abs(fft2_pad_blur)<t_value) = 1
		
		final_deblur_img_v = real(my_idft(get_fft2_blur_img_v./fft2_for_debluring,dft_flag))

        ssim_values(i) = my_ssim(original_image_v,final_deblur_img_v);

    end

    [max_ssim,i_d] = max(ssim_values);
	
    t_value = t_value_lowerlimit + delta_t_value*(i_d-1);
	fft2_for_debluring = fft2_pad_blur;
	fft2_for_debluring(abs(fft2_pad_blur)<t_value) = 1
	final_deblur_img = zeros(orig_size(1),orig_size(2),3);
    
	final_deblur_img(:,:,1) = real(my_idft(get_fft2_blur_img_r./fft2_for_debluring,dft_flag));
	final_deblur_img(:,:,2) = real(my_idft(get_fft2_blur_img_g./fft2_for_debluring,dft_flag));
	final_deblur_img(:,:,3) = real(my_idft(get_fft2_blur_img_b./fft2_for_debluring,dft_flag));
    
    max_psnr = my_psnr(original_image_v,final_deblur_img_v)

    axes(handles.axes3);
    imshow(final_deblur_img);
    set(handles.ssim,'String',num2str(max_ssim));
    set(handles.edit_psnr,'String',num2str(max_psnr));
    set(handles.parameter_value,'String',sprintf('%.3f := value of Threshold', t_value));
 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if get(handles.Wiener_filtering,'Value') 
    
    prompt = {'Enter upper range of K_winer:','Enter lower range of K_winer:'};
    title = 'Value of K_winer';
    %dimension of dialog box
    dims = [1 35];
    %default inuput of dialog box
    definput = {'0.001','0.1'};
    %answer will save entered value in array form
    answer = inputdlg(prompt,title,dims,definput);
    %str2double convert srting to numeric value
    K_winer_lowerlimit = str2double(answer{1});
    K_winer_upperlimit = str2double(answer{2});
    
    delta_K_winer = (K_winer_upperlimit-K_winer_lowerlimit)/9;
    
    abs_filter = abs(fft2_pad_blur);
    abs_filter_sq = abs_filter.^2;
    conj_fft2_pad_blur = conj(fft2_pad_blur);

    ssim_values = zeros(10,1);

    for i=1:10
        K_winer = K_winer_lowerlimit + delta_K_winer*(i-1);

		final_deblur_img_v = real(my_idft(((conj_fft2_pad_blur)./(abs_filter_sq + K_winer*(ones(orig_size(1),orig_size(2))))).*get_fft2_blur_img_v,dft_flag));

        ssim_values(i) = my_ssim(original_image_v,final_deblur_img_v);

    end

    [max_ssim,i_d] = max(ssim_values);

    K_winer = K_winer_lowerlimit + delta_K_winer*(i_d-1);
    final_deblur_img = zeros(orig_size(1),orig_size(2),3);
    
    final_deblur_img(:,:,1) = real(my_idft(((conj_fft2_pad_blur)./(abs_filter_sq + K_winer*(ones(orig_size(1),orig_size(2))))).*get_fft2_blur_img_r,dft_flag));
	final_deblur_img(:,:,2) = real(my_idft(((conj_fft2_pad_blur)./(abs_filter_sq + K_winer*(ones(orig_size(1),orig_size(2))))).*get_fft2_blur_img_g,dft_flag));
	final_deblur_img(:,:,3) = real(my_idft(((conj_fft2_pad_blur)./(abs_filter_sq + K_winer*(ones(orig_size(1),orig_size(2))))).*get_fft2_blur_img_b,dft_flag));

    max_psnr = my_psnr(original_image_v,final_deblur_img_v);
    axes(handles.axes3);
    imshow(final_deblur_img);
    set(handles.ssim,'String',num2str(max_ssim));
    set(handles.edit_psnr,'String',num2str(max_psnr));
    set(handles.parameter_value,'String',sprintf('%.3f := value of K_winer', K_winer));

    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if get(handles.constrained_LS,'Value') 
    
    prompt = {'Enter upper range of gamma:','Enter lower range of gamma:'};
    title = 'Value of gamma';
    %dimension of dialog box
    dims = [1 35];
    %default inuput of dialog box
    definput = {'0.001','0.1'};
    %answer will save entered value in array form
    answer = inputdlg(prompt,title,dims,definput);
    %str2double convert srting to numeric value
    gamma_lowerlimit = str2double(answer{1});
    gamma_upperlimit = str2double(answer{2});
    
    delta_gamma = (gamma_upperlimit-gamma_lowerlimit)/9;

    p_xy = [0,-1,0;-1,4,-1;0,-1,0];
    p_xy_pad = zeros(orig_size(1),orig_size(2));
    p_xy_pad(1:3,1:3) = p_xy;
    abs_fft2_p_xy_sq = abs(fft2(p_xy_pad)).^2;
    
    abs_filter = abs(fft2_pad_blur);
    abs_filter_sq = abs_filter.^2;
    conj_fft2_pad_blur = conj(fft2_pad_blur);

    ssim_values = zeros(10,1);

    for i=1:10
        gamma = gamma_lowerlimit + delta_gamma*(i-1);

        fft2_deblur_img_v = ((conj_fft2_pad_blur)./(abs_filter_sq + gamma*((abs_fft2_p_xy_sq)))).*get_fft2_blur_img_v;

        final_deblur_img_v = real(my_idft(fft2_deblur_img_v,dft_flag));

        ssim_values(i) = my_ssim(original_image_v,final_deblur_img_v);

    end

    [max_ssim,i_d] = max(ssim_values);

    gamma = gamma_lowerlimit + delta_gamma*(i_d-1);
    final_deblur_img = zeros(orig_size(1),orig_size(2),3);
    
    final_deblur_img(:,:,1) = real(my_idft(((conj_fft2_pad_blur)./(abs_filter_sq + gamma*((abs_fft2_p_xy_sq)))).*get_fft2_blur_img_r,dft_flag));
    final_deblur_img(:,:,2) = real(my_idft(((conj_fft2_pad_blur)./(abs_filter_sq + gamma*((abs_fft2_p_xy_sq)))).*get_fft2_blur_img_g,dft_flag));
    final_deblur_img(:,:,3) = real(my_idft(((conj_fft2_pad_blur)./(abs_filter_sq + gamma*((abs_fft2_p_xy_sq)))).*get_fft2_blur_img_b,dft_flag));

    max_psnr = my_psnr(original_image_v,final_deblur_img_v);
    axes(handles.axes3);
    imshow(final_deblur_img);
    set(handles.ssim,'String',num2str(max_ssim));
    set(handles.edit_psnr,'String',num2str(max_psnr));
    
    set(handles.parameter_value,'String',sprintf('%.3f := value of gamma', gamma));
    
    
    
end



function edit_psnr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_psnr as text
%        str2double(get(hObject,'String')) returns contents of edit_psnr as a double


% --- Executes during object creation, after setting all properties.
function edit_psnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ssim_Callback(hObject, eventdata, handles)
% hObject    handle to ssim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ssim as text
%        str2double(get(hObject,'String')) returns contents of ssim as a double


% --- Executes during object creation, after setting all properties.
function ssim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ssim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_deblur.
function save_deblur_Callback(hObject, eventdata, handles)
% hObject    handle to save_deblur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global final_deblur_img complete_name
[filename, foldername] = uiputfile('Where do you want the file saved?');
complete_name = fullfile(foldername, filename);
imwrite(final_deblur_img, complete_name);


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
close all;



function ssim_blur_Callback(hObject, eventdata, handles)
% hObject    handle to ssim_blur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ssim_blur as text
%        str2double(get(hObject,'String')) returns contents of ssim_blur as a double


% --- Executes during object creation, after setting all properties.
function ssim_blur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ssim_blur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psnr_blur_Callback(hObject, eventdata, handles)
% hObject    handle to psnr_blur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psnr_blur as text
%        str2double(get(hObject,'String')) returns contents of psnr_blur as a double


% --- Executes during object creation, after setting all properties.
function psnr_blur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psnr_blur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_blur_image.
function Save_blur_image_Callback(hObject, eventdata, handles)
global blur_img complete_name
[filename, foldername] = uiputfile('Where do you want the file saved?');
complete_name = fullfile(foldername, filename);
imwrite(blur_img, complete_name);



function parameter_value_Callback(hObject, eventdata, handles)
% hObject    handle to parameter_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of parameter_value as text
%        str2double(get(hObject,'String')) returns contents of parameter_value as a double


% --- Executes during object creation, after setting all properties.
function parameter_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
