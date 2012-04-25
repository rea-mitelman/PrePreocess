function varargout = Preproc_prompt(varargin)
% PREPROC_PROMPT M-file for Preproc_prompt.fig
%      PREPROC_PROMPT, by itself, creates a new PREPROC_PROMPT or raises the existing
%      singleton*.
%
%      H = PREPROC_PROMPT returns the handle to a new PREPROC_PROMPT or the handle to
%      the existing singleton*.
%
%      PREPROC_PROMPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROC_PROMPT.M with the given input arguments.
%
%      PREPROC_PROMPT('Property','Value',...) creates a new PREPROC_PROMPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Preproc_prompt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Preproc_prompt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Preproc_prompt

% Last Modified by GUIDE v2.5 25-Apr-2012 15:47:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Preproc_prompt_OpeningFcn, ...
                   'gui_OutputFcn',  @Preproc_prompt_OutputFcn, ...
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


% --- Executes just before Preproc_prompt is made visible.
function Preproc_prompt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Preproc_prompt (see VARARGIN)

% Choose default command line output for Preproc_prompt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Preproc_prompt wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Preproc_prompt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if get(handles.radiobutton_Remove_Stimulus_Artifacts,'value')
	out.Rem_Stim_Art=true;
elseif get(handles.radiobutton_use_raw_data,'value')
	out.Rem_Stim_Art=false;
else
	error('Undefined stimulus artifact removal option')
end

if get(handles.radiobutton_Use_original_PCs,'value')
	out.PCs_option='org';
elseif get(handles.radiobutton_Calculate_new_PCs_using_PCA,'value')
	out.PCs_option='PCA';
elseif get(handles.radiobutton_Use_GUI_to_calculate_PCs,'value')
	out.PCs_option='GUI';
else
	error('Undefined PCs option')
end


out.us_factor=str2double(get(handles.us_factor,'String'));
out.art_end=str2double(get(handles.art_end,'String'));
out.max_dead_time_dur=str2double(get(handles.max_dead_time_dur,'String'));
out.do_lin_decay=get(handles.do_lin_decay,'Value');

varargout{1} = out;
close(gcf)



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_proceed.
function pushbutton_proceed_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_proceed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% keyboard

uiresume(handles.figure1)

% close(gcf)


% --- Executes on button press in pushbutton_abort.
function pushbutton_abort_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)

error('Abort by user')



function us_factor_Callback(hObject, eventdata, handles)
% hObject    handle to us_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of us_factor as text
%        str2double(get(hObject,'String')) returns contents of us_factor as a double


% --- Executes during object creation, after setting all properties.
function varargout = us_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to us_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% out.us_factor=str2num(get(hObject,'String'));
% varargout{1} = out;



function art_end_Callback(hObject, eventdata, handles)
% hObject    handle to art_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of art_end as text
%        str2double(get(hObject,'String')) returns contents of art_end as a double


% --- Executes during object creation, after setting all properties.
function art_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to art_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_dead_time_dur_Callback(hObject, eventdata, handles)
% hObject    handle to max_dead_time_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_dead_time_dur as text
%        str2double(get(hObject,'String')) returns contents of max_dead_time_dur as a double


% --- Executes during object creation, after setting all properties.
function max_dead_time_dur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_dead_time_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in do_lin_decay.
function do_lin_decay_Callback(hObject, eventdata, handles)
% hObject    handle to do_lin_decay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of do_lin_decay
