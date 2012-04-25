function varargout = TemplatePreproc(varargin)
% TEMPLATEPREPROC M-file for TemplatePreproc.fig
%      TEMPLATEPREPROC, by itself, creates a new TEMPLATEPREPROC or raises the existing
%      singleton*.
%
%      H = TEMPLATEPREPROC returns the handle to a new TEMPLATEPREPROC or the handle to
%      the existing singleton*.
%
%      TEMPLATEPREPROC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMPLATEPREPROC.M with the given input arguments.
%
%      TEMPLATEPREPROC('Property','Value',...) creates a new TEMPLATEPREPROC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TemplatePreproc_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TemplatePreproc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TemplatePreproc

% Last Modified by GUIDE v2.5 05-Sep-2010 16:30:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TemplatePreproc_OpeningFcn, ...
                   'gui_OutputFcn',  @TemplatePreproc_OutputFcn, ...
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


% --- Executes just before TemplatePreproc is made visible.
function TemplatePreproc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TemplatePreproc (see VARARGIN)

% Choose default command line output for TemplatePreproc
handles.flist=varargin{1};
nfiles=4;
step=round(length(handles.flist)/(nfiles+1));
findx=step:step:nfiles*step;
extracts=[];
for ifile=1:length(findx)
    if exist(handles.flist(findx(ifile)).fnm);%!!!
        load(handles.flist(findx(ifile)).fnm);
        extracts=[extracts tdata];
		
	end
end

handles.extracts=extracts;
handles.numExtracts=size(extracts,2);
set(handles.total1,'string',num2str(handles.numExtracts));
set(handles.total2,'string',num2str(handles.numExtracts));
handles.alloc_index=zeros(1,handles.numExtracts);
handles.trash=[-inf*ones(64,1) inf*ones(64,1)];
handles.NSubSess = varargin{2};
handles.file_nums = varargin{3};
handles.n_elec = varargin{4};
for i=1:3
    handles.T(:,:,i)=handles.trash;
end
handles.active=[0 0 0];
handles.Templates(1:3,:)=zeros(3,64);
handles.output = hObject;
handles.time=1:64;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TemplatePreproc wait for user response (see UIRESUME)
% uiwait(handles.figure1);
getSpikes_Callback(hObject, eventdata, handles);

 Original_PCs_Callback(hObject, eventdata, handles)

% --- Outputs from this function are returned to the command line.
function varargout = TemplatePreproc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% --- Executes on button press in getSpikes.
function getSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to getSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
include=[];
if ~get(handles.rm1,'value')
    include=[include 1];
end
if ~get(handles.rm2,'value')
    include=[include 2];
end
if ~get(handles.rm3,'value')
    include=[include 3];
end
if ~get(handles.rm4,'value')
    include=[include 4];
end
candidates=find(~handles.alloc_index | ismember(handles.alloc_index,include));
set(handles.nalloc,'string',num2str(length(find(~handles.alloc_index))));
tit_str=sprintf('Sub-session: #%2.0f (files: %2.0f:%2.0f)\nElectrode #%1.0f',...
	handles.NSubSess,handles.file_nums,handles.n_elec);
set(handles.title_str,'string',tit_str);%%%
r=randperm(length(candidates));
try
    r=r(1:500);
    handles.smallSample=candidates(r);
%     S0=handles.smallSample(handles.alloc_index(handles.smallSample)==0);
%     S1=handles.smallSample(handles.alloc_index(handles.smallSample)==1);
%     S2=handles.smallSample(handles.alloc_index(handles.smallSample)==2);
%     S3=handles.smallSample(handles.alloc_index(handles.smallSample)==3);
%     S4=handles.smallSample(handles.alloc_index(handles.smallSample)==4);
%     axes(handles.ExtractsPlot), hold off
%     if ~isempty(S0)
%         %plot(1:64,handles.extracts(:,candidates(r)),'k');
%         plot(1:64,handles.extracts(:,S0),'k');
%     end
%     if ~isempty(S1)
%         plot(1:64,handles.extracts(:,S1),'b');
%     end
%     if ~isempty(S2)
%         plot(1:64,handles.extracts(:,S2),'r');
%     end
%     if ~isempty(S3)
%         plot(1:64,handles.extracts(:,S3),'g');
%     end
%     if ~isempty(S4)
%         plot(1:64,handles.extracts(:,S4),'y');
%     end
    
catch
    msgbox('too few non allocated extracts remained')
	return %!!!!!
end

guidata(hObject, handles);
plotSpikes(hObject, eventdata, handles);

% --- Executes on selection change in templateList.
function templateList_Callback(hObject, eventdata, handles)
% hObject    handle to templateList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i=get(handles.templateList,'value');
axes(handles.Template);cla
try
    plot(1:64,handles.extracts(:,handles.alloc_index==i)','k'); axis tight
    hold on, plot(1:64, mean(handles.extracts(:,handles.alloc_index==i)')','r')
    set(handles.allocated,'string',num2str(length(find(handles.alloc_index==i))));
catch
end
% Hints: contents = get(hObject,'String') returns templateList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from templateList


% --- Executes during object creation, after setting all properties.
function templateList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to templateList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compPCs.
function compPCs_Callback(hObject, eventdata, handles)
% hObject    handle to compPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcstr = 'Pcvec3.mat'; %%% changed the name of PC source to fit new spinal PCs
%pcstr='spinal_PCs_itt10.mat';
if ~exist( pcstr, 'file' )
    error( 'missing PC definitions' )
end
load( pcstr )
if length(find(handles.active))<2
	msgbox('Cannot create PCs for a single template')
	handles.PC=pcvec;
else
	xx=0:1/3:65;
	C=zeros(length(xx));
	for i=1:3
		csT=csaps(1:64,handles.Templates(i,:));
		TE=fnval(csT,xx);
		C=C+TE'*TE;
	end
	%     [V,D]=eig(C);
	%     handles.PC=V(:,end:-1:end-2);
	[V,~]=eigs(C,3);
	handles.PC=V;
	handles.PCtype='Manually calculated';
	plot_pcs(handles)
end
guidata(hObject, handles);


% --- Executes on button press in addTemplate.
function addTemplate_Callback(hObject, eventdata, handles)
% hObject    handle to addTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clearTemplate.
function clearTemplate_Callback(hObject, eventdata, handles)
% hObject    handle to clearTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i=get(handles.templateList,'value');
handles.active(i)=0;
handles.T(:,:,i)=[-inf*ones(64,1) inf*ones(64,1)];
handles.alloc_index(handles.alloc_index==i)=0;
handles.Templates(i,:)=zeros(1,64);
guidata(hObject, handles);


% --- Executes on button press in bigger.
function bigger_Callback(hObject, eventdata, handles)
% hObject    handle to bigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i=get(handles.templateList,'value');
handles.active(i)=1;
axes(handles.ExtractsPlot);
[x,y]=ginput(1);
x=round(x);
if isempty(find(handles.alloc_index==i)) %not assigend yet
    handles.alloc_index(~handles.alloc_index & handles.extracts(x,:)>y)=i;
else
    handles.alloc_index(handles.alloc_index==i & handles.extracts(x,:)<y)=0;
end
axes(handles.Template);cla
plot(1:64,handles.extracts(:,handles.alloc_index==i)','k'); axis tight
hold on, plot(1:64, mean(handles.extracts(:,handles.alloc_index==i)')','r')
handles.Templates(i,:)=mean(handles.extracts(:,handles.alloc_index==i)')';
set(handles.allocated,'string',num2str(length(find(handles.alloc_index==i))));
set(handles.nalloc,'string',num2str(length(find(~handles.alloc_index))));
guidata(hObject, handles);
plotSpikes(hObject, eventdata, handles);

% --- Executes on button press in smaller.
function smaller_Callback(hObject, eventdata, handles)
% hObject    handle to smaller (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i=get(handles.templateList,'value');
handles.active(i)=1;
axes(handles.ExtractsPlot);
[x,y]=ginput(1);
x=round(x);
if isempty(find(handles.alloc_index==i)) %not assigend yet
    handles.alloc_index(~handles.alloc_index & handles.extracts(x,:)<y)=i;
else
    handles.alloc_index(handles.alloc_index==i & handles.extracts(x,:)>y)=0;
end
axes(handles.Template);cla
plot(1:64,handles.extracts(:,handles.alloc_index==i)','k'); axis tight
hold on, plot(1:64, mean(handles.extracts(:,handles.alloc_index==i)')','r')
handles.Templates(i,:)=mean(handles.extracts(:,handles.alloc_index==i)')';
set(handles.allocated,'string',num2str(length(find(handles.alloc_index==i))));
set(handles.nalloc,'string',num2str(length(find(~handles.alloc_index))));
guidata(hObject, handles);
plotSpikes(hObject, eventdata, handles);




% --- Executes on button press in rm1.
function rm1_Callback(hObject, eventdata, handles)
% hObject    handle to rm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rm1


% --- Executes on button press in rm2.
function rm2_Callback(hObject, eventdata, handles)
% hObject    handle to rm2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rm2


% --- Executes on button press in rm3.
function rm3_Callback(hObject, eventdata, handles)
% hObject    handle to rm3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rm3


% --- Executes on button press in rm4.
function rm4_Callback(hObject, eventdata, handles)
% hObject    handle to rm4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rm4




% --- Executes on button press in confirm.
function confirm_Callback(hObject, eventdata, handles)
% hObject    handle to confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcvec=handles.PC;
for i=1:length(handles.flist)
    pos=findstr(handles.flist(i).fnm,'pcs');
    f2save=[handles.flist(i).fnm(1:pos-1) 'pcv' handles.flist(i).fnm(pos+3:end)];
	%     savestr=sprintf('save(''%s'',''pcvec'')',f2save);
	%     eval(savestr)
	%changed by Rea, 24/8/10. There's no reason to use eval here - just
	%complicates things in case theres an apostophe in the file name
	save(f2save, 'pcvec')

end
close(gcf)


function plotSpikes(hObject, eventdata, handles)

S0=handles.smallSample(handles.alloc_index(handles.smallSample)==0);
S1=handles.smallSample(handles.alloc_index(handles.smallSample)==1);
S2=handles.smallSample(handles.alloc_index(handles.smallSample)==2);
S3=handles.smallSample(handles.alloc_index(handles.smallSample)==3);
S4=handles.smallSample(handles.alloc_index(handles.smallSample)==4);
axes(handles.ExtractsPlot), hold off
if ~isempty(S0)
    %plot(1:64,handles.extracts(:,candidates(r)),'k');
    plot(1:64,handles.extracts(:,S0),'k'); hold on
end
if ~isempty(S1)
    plot(1:64,handles.extracts(:,S1),'b'); hold on
end
if ~isempty(S2)
    plot(1:64,handles.extracts(:,S2),'r'); hold on
end
if ~isempty(S3)
    plot(1:64,handles.extracts(:,S3),'g'); hold on
end
if ~isempty(S4)
    plot(1:64,handles.extracts(:,S4),'y'); hold on
end
xlim([1,64])
axis auto


% --- Executes during object creation, after setting all properties.
function rm1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function rm1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to rm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over rm2.
function rm2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to rm2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on rm2 and none of its controls.
function rm2_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to rm2 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plot_pcs(handles)
l=length(handles.extracts);
samples=handles.extracts(:,ceil(l*rand(1,1500)));
% 	samples=handles.extracts;
xxx=samples'*handles.PC(4:3:end-1,1);
yyy=samples'*handles.PC(4:3:end-1,2);

%     xxx2=samples'*pcvec(4:3:end-1,1);
%     yyy2=samples'*pcvec(4:3:end-1,2);

axes(handles.PCs_vectors), cla,
plot(1:64, handles.PC(4:3:end-1,1), 1:64, handles.PC(4:3:end-1,2),'r',1:64,handles.PC(4:3:end-1,3),'g'), pause(3)
title(handles.PCtype)
axes(handles.PCs_projection), cla,
% 	plot(xxx2,yyy2,'b.','markersize',.5); pause(2)
plot(xxx,yyy,'k.','markersize',.5);
set(handles.confirm,'enable','on');


% --- Executes on button press in Original_PCs.
function Original_PCs_Callback(hObject, eventdata, handles)
% hObject    handle to Original_PCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcstr = 'Pcvec3.mat'; %%% changed the name of PC source to fit new spinal PCs
%pcstr='spinal_PCs_itt10.mat';
if ~exist( pcstr, 'file' )
    error( 'missing PC definitions' )
end
load( pcstr )
handles.PC=pcvec;
handles.PCtype='Original';
plot_pcs(handles)


% --- Executes on button press in comp_PCA.
function comp_PCA_Callback(hObject, eventdata, handles)
% hObject    handle to comp_PCA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x=1:64;
xx=0:1/3:65;
ext_spl=spline(x,handles.extracts(:,handles.alloc_index~=4)',xx);
[~,~,v]=svds(ext_spl,3);
handles.PC=v;
handles.PCtype='PCA';
plot_pcs(handles)



% --- Executes on button press in ICA.
function ICA_Callback(hObject, eventdata, handles)
% hObject    handle to ICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=1:64;
xx=0:1/3:65;
ext_spl=spline(x,handles.extracts(:,handles.alloc_index~=4)',xx);
addpath D:\Rea''''s_Documents\MATLAB\FastICA_25
[A,~]=fastica (ext_spl', 'only','all','firstEig',1,'lastEig',50,'numOfIC',3, 'displayMode', 'off', 'verbose', 'off');
handles.PC=A;
handles.PCtype='ICA';
plot_pcs(handles)
