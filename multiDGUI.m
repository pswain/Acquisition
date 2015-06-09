
function varargout = multiDGUI(varargin)
% MULTIDGUI M-file for multiDGUI.fig
%      MULTIDGUI, by itself, creates a new MULTIDGUI or raises the existing
%      singleton*.
%
%      H = MULTIDGUI returns the handle to a new MULTIDGUI or the handle to
%      the existing singleton*.
%
%      MULTIDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIDGUI.M with the given input arguments.
%
%      MULTIDGUI('Property','Value',...) creates a new MULTIDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before multiDGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stopacq.  All inputs are passed to multiDGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help multiDGUI

% Last Modified by GUIDE v2.5 21-Nov-2014 12:49:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @multiDGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @multiDGUI_OutputFcn, ...
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


% --- Executes just before multiDGUI is made visible.
function multiDGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to multiDGUI (see VARARGIN)



handles.output = hObject;

% Set up a structure to hold the acquisition parameters.
%Fields are channels, z, time, points, flow, info

%Channels. Will be a cell array
%Column 1 - name of channel
%Column 2 - exposure time in ms
%Column 3 - skip number - eg if 2 only take an image every 2nd time point in this channel, if 3 only every 3rd etc.
%Column 4 - 1 if using Z sectioning, 0 if not
%Column 5 - starting timepoint - no images will be captured in this channel until this timepoint
%Column 6 - Camera mode. 1 if EM with gain+exposure correction, 2 if CCD, 3 if EM with constant gain and exposure
%Column 7 - Starting EM gain (not used if camera in CCD mode, default 270).
%Column 8 - LED voltage - number between 0 and 4 - the voltage applied across the LED during the exposure

%Z sectioning:
%z. double array
%1. number of sections
%2. spacing in microns
%3. PFS on (1 or 0 - only added on start of experiment)
%4. anyZ (1 if any channel does z sectioning, 0 if not, only added at start of experiment
%5. drift - the drift in the z plane, recorded during a timlapse by querying the position of the z drive after the pfs has corrected it.
%6. method - method of z sectioning. 1. 'PIFOC' or 2. 'PIFOC_PFSON' or 3. 'PFS'


%Timelapse settings
%time. double array
%Column 1 - use timelapse (1 for yes, 0 for no)
%Column 2 - interval in s (300s (5min) default)
%Column 3 - number of time points (180 default) 
%Column 4 - total time (54000s (15hr) default)

%Point visiting
%points. cell array
%Column 1 - name
%Column 2 - x stage position (microns)
%Column 3 - y stage position (microns) 
%Column 4 - microscope z drive position (microns)
%Column 5 - PFS offset position (microns)
%Column 6 - Group - all points that are members of a group should have the same exposure settings - eg - should all be the same genotype and media condition
%Changes to exposure time settings that affect one member of the group
%should affect them all - eg if the intensity approaches saturation and the
%exposure time is reduced accordingly this should happen to all points in
%the group coordinately. This allows one position to be used to measure the
%bleaching of all points in the group.
%Columns 7-? - exposure times for each used channel at the point - or a string 'double'- means do a double exposure for this point - for asessing bleaching


%Flow control
%flow. Cell array

%Column 1 - Contents of syringe in pump 1 (string)
%Column 2 - Contents of syringe in pump 2 (string)
%Column 3 - 
%Column 4 - cell array of pump objects
%Column 5 - switches object


%Experimental information
%info. Cell array
%Column 1 - experiment name
%Column 2 - user name
%Column 3 - root for folder to save files
%Column 4 - Experiment description/aims
%Column 5 - object of class switches

%Image size
%.imagesize
%2 element array. [height width]

%Add necessary folders to path
addpath(genpath('C:\AcquisitionData\Swain Lab\OmeroCode'));
addpath(['.' filesep 'transitionGUI']);
%Get computer name
[idum,hostname]= system('hostname');
%Create microscope object - details will depend on which computer is
%running this
handles.acquisition.microscope=Microscope;




 
%Show warning if running from the shared, public folder
if strcmp(pwd,'C:\Users\Public\Microscope Control');
    msgbox('MultiDGUI is running from the shared Microscope Control folder - please do not edit this version of the software!','Running shared software','Warn');
end

%Get free disk space
handles.freeDisk=checkDiskSpace;
set(handles.GbFree,'String',num2str(handles.freeDisk));

%If there is a last saved acquisition file then load the acquisition
%settings from that. Points are not loaded.
%First get the file name of the last saved acquisition:
user=getenv('USERNAME');
[root user]=makeRoot(user);%this provides a root directory based on the name and date
handles.acquisition.info={'exp' user root 'Aim:   Strain:  Comments:'};%Initialise the experimental info - exp name and details may be altered later when refreshGUI is called but root and user stay the same
lastSavedPath=strcat('C:\Documents and Settings\All Users\multiDGUIfiles\',user,'lastSaved.txt');
if exist (lastSavedPath,'file')==2
fileWithPath=fopen(lastSavedPath);
acqFilePath=textscan(fileWithPath,'%s','Delimiter','');%read with empty delimiter,'' - prevents new line being started at spaces in the path name 
fclose(fileWithPath);
acqFilePath=acqFilePath{:};
lastSavedFilename=char(acqFilePath);
%then load that file into handles.acquisition if the file exists
    if exist (lastSavedFilename,'file')==5
    handles.acquisition=loadAcquisition(lastSavedFilename);
    handles.acquisition.info={'exp' user root 'Aim:   Strain:  Comments:'};%Initialise the experimental info - not loaded from acquisition file
    %then import the data from the handles.acquisition structure into the GUI:
    refreshGUI(handles);
    guidata(hObject, handles);
    else%If there is no last saved acquisition initialise with defaults
        handles.acquisition.channels={};
        handles.acquisition.z=[1 0 0 0 0 2]; 
        handles.acquisition.time=[1 300 180 54000];
        p1=pump('COM5',19200);p2=pump('COM6',19200);%CHANGE 2ND INPUT TO CORRECT BAUD RATE FOR THE RELEVANT PUMP
        handles.acquisition.flow={'2% raffinose in SC' '2% galactose in SC' 1 [p1 p2],flowChanges({p1, p2})};
        %info entry is already initialised above
    end
else%If there is no file containing the path of a last saved acquisition the initialise with defaults
handles.acquisition.channels={};
handles.acquisition.z=[1 0 0 0 0 2]; 
handles.acquisition.time=[1 300 180 54000];
p1=pump('COM5',19200);p2=pump('COM6',19200);%CHANGE 2ND INPUT TO CORRECT BAUD RATE FOR THE RELEVANT PUMP
handles.acquisition.flow={'2% raffinose in SC' '2% galactose in SC' 1 [p1 p2],flowChanges({p1, p2})};
%info entry is already initialised above
end
set(handles.live,'BackgroundColor',[0.2 .9 0.2]);
updateFlowDisplay(handles);%makes the graph from the flow settings

%Initialise the list of points. This is not retrieved from the last saved
%acquisition
handles.acquisition.points={};

%Initialise the user list - only need to edit the getUsers.m function when
%a new user is added
[swain tyers millar]=getUsers;
users=[swain tyers millar];

%Initialize the Omero projects and tags lists
if ismac
   addpath(genpath('/Volumes/AcquisitionData/Swain Lab/OmeroCode'));
   load('/Volumes/AcquisitionData/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/dbInfoSkye.mat');
   addpath('\\SCE-BIO-C02471\AcquisitionData\Swain Lab\OmeroCode');
   macMMPath;
else
    [idum,hostname]= system('hostname');
    if strcmp(hostname(1:end-1),'SCE-BIO-C03727')
        addpath(genpath('\\SCE-BIO-C03982\AcquisitionData\Omero code master copy'));
        load('\\SCE-BIO-C03982\AcquisitionData\Swain Lab\Ivan\software in progress\omeroinfo_donottouch\dbInfoSkye.mat');
    else
        load('C:\AcquisitionData\Swain Lab\Ivan\software in progress\omeroinfo_donottouch\dbInfoSkye.mat');
    end
end
handles.aquisition.omero=struct('project',{}, 'tags',{}, 'object',{});
handles.acquisition.omero.object=obj2;


%Display the projects
proj=handles.acquisition.omero.object.getProjectNames;
%Make sure there is a 'Default project' entry
if ~any(strcmp('Default project',proj))
     proj{end+1}='Default project';
     defaultValue=length(proj);
else
     defaultValue=find(strcmp(proj,'Default project'));
     defaultValue=defaultValue(1);
end
proj{end+1}='Add a new project';
set(handles.OmeroProjects,'String',proj);
set(handles.OmeroProjects,'Value', defaultValue);
%Define the default project as the one to be used when the experiment is
%run:
handles.acquisition.omero.project='Default project';

%Same thing for the tags list:

%Retrieve recorded tag names:
tags=handles.acquisition.omero.object.getTagNames(false);
%Add a menu item for making new tags:
tags{end+1}='Add a new tag';
%Set menu items:
set(handles.OmeroTags,'String',tags);
set(handles.OmeroTags,'Value', length(tags));

%Define the date tag as the only one to be used (so far) when the
%experiment is run:
handles.acquisition.omero(1).tags{1}=date;
%Set the list box entry
set(handles.TagList,'String',handles.acquisition.omero.tags);

%Create the icons
s=imread('skull.tif');
s=imresize(s,0.1);
set(handles.addKill,'CData',s);

s=imread('left.jpg');
s=imresize(s,0.1);
set(handles.shiftLeft,'CData',s);
set(handles.shiftLeft,'String','');

s=imread('right.jpg');
s=imresize(s,0.1);
set(handles.shiftRight,'CData',s);
set(handles.shiftRight,'String','');

s=imread('up.jpg');
s=imresize(s,0.1);
set(handles.shiftUp,'CData',s);
set(handles.shiftUp,'String','');

s=imread('down.jpg');
s=imresize(s,0.1);
set(handles.shiftDown,'CData',s);
set(handles.shiftDown,'String','');

%need variables to keep track of selections in the points list,
%period of flow switching, distance to shift and whether or not the stopacq acquisition button
%has been pressed
handles.selected = struct([]);
handles.period=0;
handles.stop=0;
handles.distance=10;%Default is 10 microns.

%Set some properties in the GUI before user input
a=fopen('version.txt');
b=textscan(a,'%s');
b=b{:};
b=b{end};
set(hObject, 'Name', ['Swain Lab Microscope: Multi Dimensional Acquisition ' b]);
set(handles.rootName,'String',handles.acquisition.info(3));
set(handles.pointsTable,'Data',handles.acquisition.points);

%microscope control
%Find out if an mmc and gui object have been initialised - if so can
%activate the eyepiece and camera buttons and inactivate the launch
%micromanager button
isthereagui=exist ('gui','var');
global gui;
if isthereagui~=1
    if ismac%Don't initialize the gui if working on the software on a mac - won't necessarily have micromanager on the path
        disp('Initializing micromanager path for mac');
        macMMPath;
        %use dummy gui class to create a virtual gui - just to allow the
        %software to run - this only because I have so far failed to start
        %the gui from a mac
        gui=DemoGUI;
    end
 guiconfig;
end

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = multiDGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function exptName_Callback(hObject, eventdata, handles)
handles.acquisition.info(1)=cellstr(get(hObject,'String'));
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function exptName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exptName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radiobutton1.
function radiobutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function expChannel_Callback(hObject, eventdata, handles)
% hObject    handle to expCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expCh1 as text
%        str2double(get(hObject,'String')) returns contents of expCh1 as a double
[chName tagEnd]=getChannel(hObject,handles);


expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),chName)==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function expCh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expCh2_Callback(hObject, eventdata, handles)
% hObject    handle to expCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expCh2 as text
%        str2double(get(hObject,'String')) returns contents of expCh2 as a double
expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'CFP')==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function expCh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expCh3_Callback(hObject, eventdata, handles)
% hObject    handle to expCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expCh3 as text
%        str2double(get(hObject,'String')) returns contents of expCh3 as a double
expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'GFP')==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function expCh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expCh4_Callback(hObject, eventdata, handles)
% hObject    handle to expCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expCh4 as text
%        str2double(get(hObject,'String')) returns contents of expCh4 as a double
expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'YFP')==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function expCh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expCh5_Callback(hObject, eventdata, handles)
% hObject    handle to expCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expCh5 as text
%        str2double(get(hObject,'String')) returns contents of expCh5 as a double
expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'mCherry')==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function expCh5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expCh6_Callback(hObject, eventdata, handles)
% hObject    handle to expCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expCh6 as text
%        str2double(get(hObject,'String')) returns contents of expCh6 as a double
expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'tdTomato')==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function expCh6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DICpointexp.
function DICpointexp_Callback(hObject, eventdata, handles)
% hObject    handle to DICpointexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DICpointexp
pointexpose=get(hObject,'Value');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if pointexpose==1;
   set(handles.expCh1,'Enable','off'); 

else
    set(handles.expCh1,'Enable','on');
end
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'DIC')==1
        handles.acquisition.channels{n,3}=pointexpose;
        end
    end
end
 guidata(hObject, handles);

% --- Executes on button press in CFPpointexp.
function CFPpointexp_Callback(hObject, eventdata, handles)
% hObject    handle to CFPpointexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CFPpointexp
pointexpose=get(hObject,'Value');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if pointexpose==1;
   set(handles.expCh2,'Enable','off'); 

else
    set(handles.expCh2,'Enable','on');
end
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'CFP')==1
        handles.acquisition.channels{n,3}=pointexpose;
        end
    end
end
 guidata(hObject, handles);

% --- Executes on button press in skipCh3.
function GFPpointexp_Callback(hObject, eventdata, handles)
% hObject    handle to GFPpointexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFPpointexp
pointexpose=get(hObject,'Value');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if pointexpose==1;
   set(handles.expCh3,'Enable','off'); 

else
    set(handles.expCh3,'Enable','on');
end
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'GFP')==1
        handles.acquisition.channels{n,3}=pointexpose;
        end
    end
end
 guidata(hObject, handles);

% --- Executes on button press in YFPpointexp.
function YFPpointexp_Callback(hObject, eventdata, handles)
% hObject    handle to YFPpointexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of YFPpointexp
pointexpose=get(hObject,'Value');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if pointexpose==1;
   set(handles.expCh4,'Enable','off'); 

else
    set(handles.expCh4,'Enable','on');
end
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'YFP')==1
        handles.acquisition.channels{n,3}=pointexpose;
        end
    end
end
 guidata(hObject, handles);

% --- Executes on button press in skipCh5.
function mChpointexp_Callback(hObject, eventdata, handles)
% hObject    handle to mChpointexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mChpointexp
pointexpose=get(hObject,'Value');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if pointexpose==1;
   set(handles.expCh5,'Enable','off'); 

else
    set(handles.expCh5,'Enable','on');
end
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'mCherry')==1
        handles.acquisition.channels{n,3}=pointexpose;
        end
    end
end
 guidata(hObject, handles);

% --- Executes on button press in tdpointexp.
function tdpointexp_Callback(hObject, eventdata, handles)
% hObject    handle to tdpointexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tdpointexp
pointexpose=get(hObject,'Value');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if pointexpose==1;
   set(handles.expCh6,'Enable','off'); 

else
    set(handles.expCh6,'Enable','on');
end
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'tdTomato')==1
        handles.acquisition.channels{n,3}=pointexpose;
        end
    end
end
 guidata(hObject, handles);

% --- Executes on button press in text5. Use CFP
function useCh2_Callback(hObject, eventdata, handles)

sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
     if get(handles.ZsectCh2,'Value')==1
       set(handles.nZsections,'Enable','on');
       set(handles.zspacing,'Enable','on');
     end
   set(handles.skipCh2,'Enable','on');
   set(handles.ZsectCh2,'Enable','on');
   set(handles.starttpCh2,'Enable','on');
   set(handles.snapCh2,'Enable','on');
   set(handles.cammodeCh2,'Enable','on');
   set(handles.skipCh2,'Enable','on');
    %camera settings - enable controls
   set(handles.cammodeCh2,'Enable','on');%%%%%
   if get(handles.cammodeCh2,'Value')==1%channel set to camera EM mode
       set (handles.startgainCh2,'Enable','on');%%%%%
       set (handles.voltCh2,'Enable','on');%%%%%
   end   %%%%%
   set(handles.expCh2,'Enable','on');
   handles.acquisition.channels{nChannels+1,1}='CFP';
   handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.expCh2,'String'));
   handles.acquisition.channels{nChannels+1,4}=get(handles.ZsectCh2,'Value');%add to others
   handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.skipCh2,'String'));
   handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.starttpCh2,'String'));%add to others
    %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.cammodeCh2,'Value');
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.startgainCh2,'String'));
   if isempty(handles.acquisition.channels(nChannels+1,7))
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end
   handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.voltCh2,'String')));
   %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else
    set(handles.expCh2,'Enable','off');
    set(handles.skipCh2,'Enable','off');
    set(handles.ZsectCh2,'Enable','off');%add to others
    set(handles.starttpCh2,'Enable','off');%add to others
    set(handles.snapCh2,'Enable','off');
    set(handles.cammodeCh2,'Enable','off');
    set(handles.startgainCh2,'Enable','off');%%%%%
    set(handles.voltCh2,'Enable','off');%%%%%
    set(handles.skipCh2,'Enable','off');

    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it. And also records if any channel does sectioning.
            if strcmp(char(handles.acquisition.channels(n,1)),'CFP')==1
            delnumber=n;
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
        
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0%deactivate z settings choices if no channel is using z
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
     
        
        
guidata(hObject, handles);

% --- Executes on button press in text6. Use GFP
function useCh3_Callback(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text6

sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
     if get(handles.ZsectCh3,'Value')==1
       set(handles.nZsections,'Enable','on');
   
       set(handles.zspacing,'Enable','on');
     end
   set(handles.skipCh3,'Enable','on');
   set(handles.ZsectCh3,'Enable','on');
   set(handles.starttpCh3,'Enable','on');%add to others
   set(handles.snapCh3,'Enable','on');%%%%%
   set(handles.cammodeCh3,'Enable','on');%%%%%
   %camera settings - enable controls
   set(handles.cammodeCh3,'Enable','on');%%%%%
   if get(handles.cammodeCh3,'Value')==1%channel set to camera EM mode
       set (handles.startgainCh3,'Enable','on');%%%%%
       set (handles.voltCh3,'Enable','on');%%%%%
   end   %%%%%
   set(handles.expCh3,'Enable','on');
   handles.acquisition.channels{nChannels+1,1}='GFP';
   handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.expCh3,'String'));
   handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.skipCh3,'String'));
   handles.acquisition.channels{nChannels+1,4}=get(handles.ZsectCh3,'Value');%add to others
   handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.starttpCh3,'String'));%add to others
   %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.cammodeCh3,'Value');%%%%%
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.startgainCh3,'String'));%%%%%
   if isempty(handles.acquisition.channels(nChannels+1,7))%%%%%
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end%
      handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.voltCh3,'String')));
   %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else
    set(handles.expCh3,'Enable','off');
    set(handles.skipCh3,'Enable','off');
    set(handles.ZsectCh3,'Enable','off');%add to others
    set(handles.starttpCh3,'Enable','off');%add to others
    set(handles.snapCh3,'Enable','off');%%%%%
    set(handles.cammodeCh3,'Enable','off');%%%%%
    set(handles.startgainCh3,'Enable','off');%%%%%
    set(handles.voltCh3,'Enable','off');%%%%%
    sizeChannels=size(handles.acquisition.channels);%%%%%
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it. And also records if any channel does sectioning.
            if strcmp(char(handles.acquisition.channels(n,1)),'GFP')==1
            delnumber=n;
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0%deactivate z settings choices if no channel is using z
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);
% --- Executes on button press in text7. Use YFP button
function useCh4_Callback(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text7
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
     if get(handles.ZsectCh4,'Value')==1
      set(handles.nZsections,'Enable','on');
      set(handles.zspacing,'Enable','on');
     end
   set(handles.skipCh4,'Enable','on');
   set(handles.ZsectCh4,'Enable','on');
   set(handles.starttpCh4,'Enable','on');%add to others
   set(handles.snapCh4,'Enable','on');%%%%%
   set(handles.cammodeCh4,'Enable','on');%%%%%
   %camera settings - enable controls
   set(handles.cammodeCh4,'Enable','on');%%%%%
   if get(handles.cammodeCh4,'Value')==1%channel set to camera EM mode
       set (handles.startgainCh4,'Enable','on');%%%%%
       set (handles.voltCh4,'Enable','on');%%%%%
   end   %%%%%
   set(handles.expCh4,'Enable','on');
   handles.acquisition.channels{nChannels+1,1}='YFP';
   handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.expCh4,'String'));
   handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.skipCh4,'String'));
   handles.acquisition.channels{nChannels+1,4}=get(handles.ZsectCh4,'Value');%add to others
   handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.starttpCh4,'String'));%add to others
   %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.cammodeCh4,'Value');%%%%%
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.startgainCh4,'String'));%%%%%
   if isempty(handles.acquisition.channels(nChannels+1,7))%%%%%
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end%
      handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.voltCh4,'String')));
    %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else
    set(handles.expCh4,'Enable','off');
    set(handles.skipCh4,'Enable','off');
    set(handles.ZsectCh4,'Enable','off');%add to others
    set(handles.starttpCh4,'Enable','off');%add to others
    set(handles.snapCh4,'Enable','off');%%%%%
    set(handles.cammodeCh4,'Enable','off');%%%%%
    set(handles.startgainCh4,'Enable','off');%%%%%
    sizeChannels=size(handles.acquisition.channels);%%%%%
    set(handles.voltCh4,'Enable','off');%%%%%
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
       anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it. And also records if any channel does sectioning.
            if strcmp(char(handles.acquisition.channels(n,1)),'YFP')==1
            delnumber=n;
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0%deactivate z settings choices if no channel is using z
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);

% --- Executes on button press in text8. mCherry use button
function useCh5_Callback(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text8
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
     if get(handles.ZsectCh5,'Value')==1
       set(handles.nZsections,'Enable','on');
       set(handles.zspacing,'Enable','on');
     end
   set(handles.skipCh5,'Enable','on');
   set(handles.ZsectCh5,'Enable','on');
   set(handles.starttpCh5,'Enable','on');%add to others
   set(handles.snapCh5,'Enable','on');
   set(handles.cammodeCh5,'Enable','on');
   set(handles.skipCh5,'Enable','on');
    %camera settings - enable controls
   set(handles.cammodeCh5,'Enable','on');%%%%%
   if get(handles.cammodeCh5,'Value')==1%channel set to camera EM mode
       set (handles.startgainCh5,'Enable','on');%%%%%
       set (handles.voltCh5,'Enable','on');%%%%%
   end   %%%%%
   set(handles.expCh5,'Enable','on');
   handles.acquisition.channels{nChannels+1,1}='mCherry';
   handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.expCh5,'String'));
   handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.skipCh5,'String'));
   handles.acquisition.channels{nChannels+1,4}=get(handles.ZsectCh5,'Value');%add to others
   handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.starttpCh5,'String'));%add to others
   %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.cammodeCh5,'Value');
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.startgainCh5,'String'));
   if isempty(handles.acquisition.channels(nChannels+1,7))
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end
      handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.voltCh5,'String')));
    %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else
    set(handles.expCh5,'Enable','off');
    set(handles.skipCh5,'Enable','off');
    set(handles.ZsectCh5,'Enable','off');%add to others
    set(handles.starttpCh5,'Enable','off');%add to others
    set(handles.snapCh5,'Enable','off');
    set(handles.cammodeCh5,'Enable','off');
    set(handles.startgainCh5,'Enable','off');%%%%%
    set(handles.voltCh5,'Enable','off');%%%%%
    set(handles.skipCh5,'Enable','off');
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it. And also records if any channel does sectioning.
            if strcmp(char(handles.acquisition.channels(n,1)),'mCherry')==1
            delnumber=n;
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0%deactivate z settings choices if no channel is using z
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);

% --- Executes on button press in text9. tdTomato use button
function useCh6_Callback(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text9
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
     if get(handles.ZsectCh6,'Value')==1
       set(handles.nZsections,'Enable','on');
       set(handles.zspacing,'Enable','on');
     end
   set(handles.skipCh6,'Enable','on');
   set(handles.ZsectCh6,'Enable','on');
   set(handles.starttpCh6,'Enable','on');%add to others
   set(handles.snapCh6,'Enable','on');
   set(handles.cammodeCh6,'Enable','on');
    %camera settings - enable controls
   set(handles.cammodeCh6,'Enable','on');%%%%%
   if get(handles.cammodeCh6,'Value')==1%channel set to camera EM mode
       set (handles.startgainCh6,'Enable','on');%%%%%
       set (handles.voltCh6,'Enable','on');%%%%%
   end   %%%%%
   set(handles.expCh6,'Enable','on');
   handles.acquisition.channels{nChannels+1,1}='tdTomato';
   handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.expCh6,'String'));
   handles.acquisition.channels{nChannels+1,4}=get(handles.ZsectCh6,'Value');%add to others
   handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.skipCh6,'String'));
   handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.starttpCh6,'String'));%add to others
   %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.cammodeCh6,'Value');
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.startgainCh6,'String'));
   if isempty(handles.acquisition.channels(nChannels+1,7))
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end
      handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.voltCh6,'String')));
   %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else
    set(handles.expCh6,'Enable','off');
    set(handles.skipCh6,'Enable','off');
    set(handles.ZsectCh6,'Enable','off');%add to others
    set(handles.starttpCh6,'Enable','off');%add to others
    set(handles.snapCh6,'Enable','off');
    set(handles.cammodeCh6,'Enable','off');
    set(handles.startgainCh6,'Enable','off');%%%%%
    set(handles.voltCh6,'Enable','off');%%%%%
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it. And also records if any channel does sectioning.
            if strcmp(char(handles.acquisition.channels(n,1)),'tdTomato')==1
            delnumber=n;
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0%deactivate z settings choices if no channel is using z
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);


% --- Executes on button press in useCh1.
function useChannel_Callback(hObject, eventdata, handles)
% hObject    handle to useCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Callback to be used for all "Use" channel buttons
%First determine which one has called it.

[chName tagEnd]=getChannel(hObject,handles);

sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
   if get(handles.(['Zsect' tagEnd]),'Value')==1
       set(handles.nZsections,'Enable','on');
       set(handles.zspacing,'Enable','on');
   end
   set(handles.(['skip' tagEnd]),'Enable','on');
   set(handles.(['Zsect' tagEnd]),'Enable','on');
   set(handles.(['starttp' tagEnd]),'Enable','on');
   set(handles.(['snap' tagEnd]),'Enable','on');
   set(handles.(['skip' tagEnd]),'Enable','on');

   switch handles.acquisition.microscope.Name
       case 'Batman'
           set(handles.(['cammode' tagEnd]),'Enable','on');
           set(handles.(['volt' tagEnd]),'Enable','on');
       case 'Robin'
   end
   %camera settings - enable controls
   set(handles.(['cammode' tagEnd]),'Enable','on');%%%%%
   if get(handles.(['cammode' tagEnd]),'Value')==1%channel set to camera EM mode
       set (handles.(['startgain' tagEnd]),'Enable','on');%%%%%
       set (handles.(['volt' tagEnd]),'Enable','on');%%%%%
   end   %%%%%
   set(handles.(['exp' tagEnd]),'Enable','on');
   %initialise channels entry
   handles.acquisition.channels{nChannels+1,1}=chName;
   handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.(['exp' tagEnd]),'String'));
   handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.(['skip' tagEnd]),'String'));
   handles.acquisition.channels{nChannels+1,4}=get(handles.(['Zsect' tagEnd]),'Value');
   handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.(['starttp' tagEnd]),'String'));
   %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.(['cammode' tagEnd]),'Value');
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.(['startgain' tagEnd]),'String'));%%%%%
   if isempty(handles.acquisition.channels(nChannels+1,7))%%%%%
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end%
      handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.(['volt' tagEnd]),'String')));
   %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else%this channel has been deselected
    set(handles.(['exp' tagEnd]),'Enable','off');
    set(handles.(['skip' tagEnd]),'Enable','off');
    set(handles.(['Zsect' tagEnd]),'Enable','off');
    set(handles.(['starttp' tagEnd]),'Enable','off');
    set(handles.(['snap' tagEnd]),'Enable','off');
    set(handles.(['cammode' tagEnd]),'Enable','off');
    set(handles.(['startgain' tagEnd]),'Enable','off')
    set(handles.(['volt' tagEnd]),'Enable','off');
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it
            if strcmp(char(handles.acquisition.channels(n,1)),chName)==1
            delnumber=n;%mark this channel for deletion
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
    if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
    end
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);


% --- Executes on button press in useCh3.
%function useGFP_Callback(hObject, eventdata, handles)
% hObject    handle to useCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useCh3


% --- Executes on button press in useCh4.
%function useYFP_Callback(hObject, eventdata, handles)
% hObject    handle to useCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useCh4


% --- Executes on button press in useCh5.
%function usemCh_Callback(hObject, eventdata, handles)
% hObject    handle to useCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useCh5


% --- Executes on button press in useCh6.
%function usetd_Callback(hObject, eventdata, handles)
% hObject    handle to useCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useCh6


% --- Executes on selection change in units.
%function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from units


% --- Executes during object creation, after setting all properties.
function units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totaltime_Callback(hObject, eventdata, handles)
% hObject    handle to totaltime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totaltime as text
%        str2double(get(hObject,'String')) returns contents of totaltime as a double


% --- Executes during object creation, after setting all properties.
function totaltime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totaltime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nTimepoints_Callback(hObject, eventdata, handles)
timepoints=str2double(get(hObject,'String'));
handles.acquisition.time(3)=timepoints;%set number of timepoints in acquisition data
totalS=(timepoints*handles.acquisition.time(2));%Work out total time in seconds - n timepoints * interval
handles.acquisition.time(4)=totalS;%set total time in acquisition data
%Update total time in the GUI - depends on the units.
totalUnits=get(handles.unitsTotal,'Value');
switch (totalUnits)
    case {1}%value 1 represents 's'
       set(handles.totaltime,'String',num2str(totalS));
    case{2}%'min'
        set(handles.totaltime,'String',num2str(totalS/60));
    case{3}%'hr'
       set(handles.totaltime,'String',num2str(totalS/3600));
end
%need to update flow switching settings based on the new total number of
%timepoints.
sizeFlow=size(handles.acquisition.flow{4});
nFlowTimepoints=sizeFlow(1);
% if nFlowTimepoints<timepoints
%    %If switching times have been entered individually then they are still
%    %valid - but need to increase their number to correspond to the new
%    %number of timepoints
%    %If switching times are periodic then they need to be updated.
%    method=get(handles.switchMethod,'Value');
%    if method==3%ie if periodic was selected
%        switchInterval=handles.period;
%         handles.acquisition.flow(4)={zeros(1,timepoints)};%initialise logical array
%         nSwitches=floor(handles.acquisition.time(3)/switchInterval);
%         for n=1:nSwitches
%             handles.acquisition.flow{4}(n*switchInterval)=1;
%         end
%    else
%        handles.acquisition.flow{4}(nFlowTimepoints+1:timepoints)=0;
%    end
% end
updateDiskSpace(handles);

guidata(hObject, handles);

updateFlowDisplay(handles);

% --- Executes during object creation, after setting all properties.
function nTimepoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nTimepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function interval_Callback(hObject, eventdata, handles)
intervalEntered=str2double(get(hObject,'String'));%get the time interval
intUnits=get(handles.units,'Value');%get the units

%define the time interval in s, depending on the units
%also update the total time based on this interval
switch (intUnits)
    case {1}%value 1 represents 's'
    handles.acquisition.time(2)=intervalEntered;     
    case{2}%'min'
    handles.acquisition.time(2)=intervalEntered*60; 
    case{3}%'hr'
    handles.acquisition.time(2)=intervalEntered*3600; 
end
%update the total time based on the new interval
timepoints=handles.acquisition.time(3);%get the number of timepoints
newInterval=handles.acquisition.time(2);
totalS=(timepoints*newInterval);%Work out total time in seconds - n timepoints * interval
handles.acquisition.time(4)=totalS;%set total time in acquisition data
%Update total time in the GUI - depends on the units.
totalUnits=get(handles.unitsTotal,'Value');
switch (totalUnits)
    case {1}%value 1 represents 's'
       set(handles.totaltime,'String',num2str(totalS));
    case{2}%'min'
        set(handles.totaltime,'String',num2str(totalS/60));
    case{3}%'hr'
       set(handles.totaltime,'String',num2str(totalS/3600));
end
 guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function interval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ZsectCh1.
function ZsectChannel_Callback(hObject, eventdata, handles)
[chName tagEnd]=getChannel(hObject,handles);

if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    switch handles.acquisition.microscope.Name
        case 'Batman'
            set(handles.zMethod,'Enable','on');
        case 'Robin'
    end
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    handles.acquisition.z(4)=1;
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),chName)==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),chName)==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
       set(handles.zMethod,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
       handles.acquisition.z(4)=0;
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);


% --- Executes on button press in ZsectCh3.
function ZsectCh3_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'GFP')==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'GFP')==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
    end
end
updateDiskSpace(handles);
  guidata(hObject, handles);


% --- Executes on button press in ZsectCh4.
function ZsectCh4_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'YFP')==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'YFP')==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
    end
end
updateDiskSpace(handles);
  guidata(hObject, handles);
  
% --- Executes on button press in ZsectCh5.
function ZsectCh5_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'mCherry')==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'mCherry')==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
    end
end
updateDiskSpace(handles);
  guidata(hObject, handles);

% --- Executes on button press in ZsectCh6.
function ZsectCh6_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'tdTomato')==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'tdTomato')==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
    end
end
updateDiskSpace(handles);
  guidata(hObject, handles);


% --- Executes on button press in ZsectCh2.
function ZsectCh2_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'CFP')==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'CFP')==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
    end
end
updateDiskSpace(handles);
  guidata(hObject, handles);


function starttpCh2_Callback(hObject, eventdata, handles)
offset=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
if isempty(get(hObject,'String'))~=1;
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'CFP')==1
            handles.acquisition.channels(n,5)=num2cell(offset);
            end
        end
else
    set(handles.starttpCh2,'String','0');
     for n=1:sizeChannels(1)
         if strcmp(char(handles.acquisition.channels(n,1)),'CFP')==1
            handles.acquisition.channels(n,5)=num2cell(0);
            end
     end   
end
   guidata(hObject, handles);

   
   
% --- Executes during object creation, after setting all properties.
function starttpCh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function starttpCh3_Callback(hObject, eventdata, handles)
offset=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
if isempty(get(hObject,'String'))~=1;
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'GFP')==1
            handles.acquisition.channels(n,5)=num2cell(offset);
            end
        end
else
    set(handles.starttpCh3,'String','0');
     for n=1:sizeChannels(1)
         if strcmp(char(handles.acquisition.channels(n,1)),'GFP')==1
            handles.acquisition.channels(n,5)=num2cell(0);
            end
     end   
end
   guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function starttpCh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function starttpCh4_Callback(hObject, eventdata, handles)
offset=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
if isempty(get(hObject,'String'))~=1;
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'YFP')==1
            handles.acquisition.channels(n,5)=num2cell(offset);
            end
        end
else
    set(handles.starttpCh4,'String','0');
     for n=1:sizeChannels(1)
         if strcmp(char(handles.acquisition.channels(n,1)),'YFP')==1
            handles.acquisition.channels(n,5)=num2cell(0);
            end
     end   
end
   guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function starttpCh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function starttpCh5_Callback(hObject, eventdata, handles)
offset=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
if isempty(get(hObject,'String'))~=1;
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'mCherry')==1
            handles.acquisition.channels(n,5)=num2cell(offset);
            end
        end
else
    set(handles.starttpCh5,'String','0');
     for n=1:sizeChannels(1)
         if strcmp(char(handles.acquisition.channels(n,1)),'mCherry')==1
            handles.acquisition.channels(n,5)=num2cell(0);
            end
     end   
end
   guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function starttpCh5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function starttpCh6_Callback(hObject, eventdata, handles)
offset=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
if isempty(get(hObject,'String'))~=1;
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'tdTomato')==1
            handles.acquisition.channels(n,5)=num2cell(offset);
            end
        end
else
    set(handles.starttpCh6,'String','0');
     for n=1:sizeChannels(1)
         if strcmp(char(handles.acquisition.channels(n,1)),'tdTomato')==1
            handles.acquisition.channels(n,5)=num2cell(0);
            end
     end   
end
   guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function starttpCh6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function starttp_Callback(hObject, eventdata, handles)
%Sets the starting timepoint for the appropriate channel - there will be no
%imaging before this timepoint.
starttp=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
callingTag=get(hObject,'Tag');
%Get the name of the channel
[channelName tagEnd]=getChannel(hObject,handles);


if isempty(get(hObject,'String'))~=1;
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),channelName)==1
                handles.acquisition.channels(n,5)=num2cell(starttp);
            end
        end
else
    set(handles.starttpCh1,'String','1');
     for n=1:sizeChannels(1)
         if strcmp(char(handles.acquisition.channels(n,1)),channelName)==1
            handles.acquisition.channels(n,5)=num2cell(1);
         end
     end   
end
updateDiskSpace(handles);
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function starttpCh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nZsections_Callback(hObject, eventdata, handles)
handles.acquisition.z(1)=str2double(get(hObject,'String'));
updateDiskSpace(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nZsections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nZsections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zspacing_Callback(hObject, eventdata, handles)
handles.acquisition.z(2)=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function zspacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zspacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Before running acquisisition - simple checks - eg are there any channels,
%approx time for capturing stack will fit into time interval.
%have experiment details been entered?
if ~isempty(handles.acquisition.channels)
    sizeChannels=size(handles.acquisition.channels(:,1));
    nChannels=(sizeChannels(1));
    if nChannels==0
        warndlg('No channels are selected - try again','No channels','modal');
        return;
    end
else
     warndlg('No channels are selected - try again','No channels','modal');
        return;
end

%Then - display a modal dialog box showing the experimental settings with a
%click to continue or return

handles.stop=0;
set(handles.start,'Enable','off');
set(handles.stopacq,'Enable','on');
guidata(hObject,handles);
handles.acquisition.guihandle=gco;%alllows gui to be queried during the acquisition - eg acqData.stop - has the stop button been clicked
runAcquisition(handles.acquisition);
set(handles.start,'Enable','on');
set(handles.stopacq,'Enable','off');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over start.
function start_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on selection change in units.
function units_Callback(hObject, eventdata, handles)
%This callback will not change the time interval in the acquisition data
%(which is always in seconds) - only changes the string displayed in the
%time interval text box.
content=get(hObject,'Value');%get the selected units
timeInterval=handles.acquisition.time(2);%get the total time in seconds
switch (content)
    case {1}%value 1 represents 's'
        set (handles.interval,'String',num2str(timeInterval));
    case{2}%'min'
        set (handles.interval,'String',num2str(timeInterval/60));
    case{3}%'hr'
        set (handles.interval,'String',num2str(timeInterval/3600));  
end
    guidata(hObject, handles);


% --- Executes on button press in doTimelapse.
function doTimelapse_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1%timelapse experiment selected
    %enable time lapse controls
set(handles.interval,'Enable','on');
set(handles.units,'Enable','on');
set(handles.nTimepoints,'Enable','on');
set(handles.totaltime,'Enable','on');
set(handles.unitsTotal,'Enable','on');
handles.acquisition.time(1)=1;
else
    set(handles.interval,'Enable','off');
set(handles.units,'Enable','off');
set(handles.nTimepoints,'Enable','off');
set(handles.totaltime,'Enable','off');
set(handles.unitsTotal,'Enable','off');
handles.acquisition.time(1)=0;
end
updateDiskSpace(handles);
guidata(hObject, handles);


% --- Executes on selection change in unitsTotal.
function unitsTotal_Callback(hObject, eventdata, handles)
%this callback will not change the total time in the acquisition data
%(which is always in s) - only changes the number displayed in the total
%time text box in the gui.
content=get(hObject,'Value');%get the selected units
totalTime=handles.acquisition.time(4);%get the total time in seconds
switch (content)
    case {1}%value 1 represents 's'
        set (handles.totaltime,'String',num2str(totalTime));
    case{2}%'min'
        set (handles.totaltime,'String',num2str(totalTime/60));
    case{3}%'hr'
        set (handles.totaltime,'String',num2str(totalTime/3600));  
end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function unitsTotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unitsTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in markPoint.
function markPoint_Callback(hObject, eventdata, handles)
set(handles.pointsTable,'Enable','on');%Make sure the table is activated (won't be if this is the first point to be defined)
nPoints=size(handles.acquisition.points,1);%number of points previously defined
%define a default group (the group of the previous point +1 if there is one,
%otherwise 1)
if nPoints>0
    group=cell2mat(handles.acquisition.points(nPoints,6))+1;
else%this is the first point defined. Set group to 1 and also initialise the column headings (based on the chosen channels)
    group=1;
    headings={'Name','x (microns)','y (microns)','z (microns)', 'PFS offset', 'Group'};
    numChannels=size(handles.acquisition.channels,1);
    editable=[true true true true true true];
    for ch=1:numChannels
        headings(6+ch)=strcat(handles.acquisition.channels(ch,1),'(ms)');
        editable(6+ch)=true;
    end
    set(handles.pointsTable,'ColumnName',headings);
    set(handles.pointsTable,'ColumnEditable',editable);
end
%Generate a default name and make sure this name hasn't already been taken
number=nPoints+1;
defName=strcat('pos',num2str(number,'%02d'));%generate default point name
nameOK=0;
while nameOK==0
    usename=1;
    for n=1:nPoints
        name=char(handles.acquisition.points(n));
        if strcmp(name,defName)==1
            usename=0;
        end
    end
    if usename==1
        nameOK=1;
    else
        number=number+1;
        defName=strcat('pos',num2str(number));%generate default point name
    end
end

[x y z PFS]=handles.acquisition.microscope.definePoint;%call to function that gets position data from scope
handles.acquisition.points((nPoints+1),1:6)={defName,x,y,z,PFS,group};%add data to acquisition data
%The first 6 columns of the points table have been defined. The remaining
%columns are exposure times, one for each channel. Need the channels
%selected and default exposure times.
numChannels=size(handles.acquisition.channels,1);
for ch=1:numChannels
handles.acquisition.points(nPoints+1,6+ch)={num2str(cell2mat(handles.acquisition.channels(ch,2)))};%this has to be a string - will allow entries other than numbers - eg 'double' for a double exposure to test bleaching
end
set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
updateDiskSpace(handles);
guidata(hObject, handles);


% --- Executes when entered data in editable cell(s) in pointsTable.
function pointsTable_CellEditCallback(hObject, eventdata, handles)

% eventdata = 
% 
%          Indices: [1 7]
%     PreviousData: '10'
%         EditData: 'double'
%          NewData: 'double'
%            Error: []

%Loop through each changed entry
for n=1:size(eventdata.Indices,1)
    %get generally-useful information
    row=eventdata.Indices(n,1);
    column=eventdata.Indices(n,2);
    table=get(hObject,'Data');
    groupno=cell2mat(table(row,6));
    groups=cell2mat(table(:,6));
    group=groups==groupno;
    %If one of the exposure times has been altered:
    if column>6%ie an exposure time
        %1. If to a new numeric value - change all others of the same group to that
        %value (unless their exposure time entry is 'double')
        %2. If to 'double' - check that there is at least one other member of that
        %group - if so, leave it. If not - revert to previous value and display an
        %error dialogue.
        %. If any other string - revert to previous value and display an error
        %dialogue
        if isempty(str2num(eventdata.NewData))%the entry is not numeric
            %is it 'double'?
            if strcmp('double',eventdata.NewData)
                %the entry is 'double'
                %are there other members of this group?
                if nnz(group)==1
                    errordlg('There must be more than one member of this position group to do a double exposure','Single point with double exposure');
                    table(row,column)={eventdata.PreviousData};
                end
            else%the entry is a non-numeric string that is not double
                errordlg('Please enter an exposure time (ms) or ''double'' for a double exposure','Incorrect entry in exposure time for point');
                table(row,column)={eventdata.PreviousData};

            end
        else%the entry is numeric - a new exposure time
            %set all group members to this (rounded) exposure time - unless their
            %exposure is 'double'
            nondouble=group;
            for o=1:size(table,1)
                if strcmp({table(o,column)},'double')==1
                    nondouble(o)=false;
                end
                entry=round(str2double({eventdata.NewData}));
                table(nondouble,column)={num2str(entry)};
            end
        end%of if/else statement - is the entry numeric
    end
%Change in a group - if leaves only one member of a group with double - ask
%for exposure time entry
%Set the exposure time to the same as the other group members
    
    if column==6%ie a group number
        %first check if the previous group has only one entry that is
        %'double'
        oldgroupno=eventdata.PreviousData;
        oldgroup=groups==oldgroupno;
        if nnz(oldgroup)==1
            oldgroupmember=find(oldgroup);
            for p=7:size(table,2)%Loop through the channels (ie exposure time columns)
                exposentry=char(table(oldgroupmember,p));
                if isempty(str2num(exposentry))%the entry is not a number
                    if strcmp(exposentry,'double')
                       errordlg(strcat('Groups must have at least one exposure time entered. ''double'' changed to previous exposure time for group_',num2str(oldgroupno),'. Channel:',char(handles.acquisition.channels(p-6,1))),'Old group left with only a double entry');
                       oldexpos=table(row,p);
                       table(oldgroupmember,p)=oldexpos;
                    end
                end
            end
        end
        %Now make sure all members of the selected group have the same
        %exposure times
        if nnz(group)>1%number of members of the input group
            newgroup=group;
            newgroup(row)=0;%don't use the exposure times of the newly-added group member
            groupmembers=find(newgroup);
            for ch=7:size(table,2)%loop through the channels - finding the correct exposure time for each
                exposure=nan;
                count=1;
                while isnan(exposure)
                    exposentry=char(table(groupmembers(count),ch));
                    if isempty(str2num(exposentry))==0%the entry is a number
                        exposure=exposentry;
                    end
                    count=count+1;
                end
                table(row,ch)={exposure};
            end        
        end
    end
    
end

%if there is a change to a group - need to make sure the new entry has the
%same exposure time as all other group members

%If one of the point names has been changed - check if the new name is
%unique - if not display an error dialogue and rever to previous name


set(hObject,'Data',table);
handles.acquisition.points=table;
updateDiskSpace(handles);
guidata(hObject, handles);
% hObject    handle to pointsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in deletePoint.
function deletePoint_Callback(hObject, eventdata, handles)
   sizes=size(handles.selected);
    nSelected=sizes(1);
   if nSelected~=0
    for n=1:nSelected
        row=handles.selected(n,1);
        handles.acquisition.points(row,:)=[];
    end
    set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
    guidata(hObject, handles);
   end
   updateDiskSpace(handles);
guidata(hObject, handles);
% --- Executes on button press in clearList.
function clearList_Callback(hObject, eventdata, handles)
   ButtonName = questdlg('Are you sure you want to delete all marked points', ...
                         'Delete marked points','No');
   switch ButtonName,
     case 'Yes',
      handles.acquisition.points={};
set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
     case 'No',
   end % switch
updateDiskSpace(handles);

guidata(hObject, handles);


% --- Executes on button press in visit.
function visit_Callback(hObject, eventdata, handles)

global mmc;
%confirm only one point is selected
sizes=size(handles.selected);
    nSelected=sizes(1);
if nSelected==1
    %get data for position to visit
    table=get(handles.pointsTable,'Data');
    row=handles.selected(1);
    x=table{row,2};
    y=table{row,3};
    z=table{row,4};
    pfs=table{row,5};
    %Is the PFS on
    pfsOn=handles.acquisition.microscope.Autofocus.isLocked;
    %if so switch it off for xy stage movement
    if pfsOn==1
        handles.acquisition.microscope.Autofocus.switchOff;
    end
    %move the stage
    mmc.setXYPosition('XYStage',x,y);
    mmc.waitForDevice('XYStage');
    %move Z position to set value
    mmc.setPosition(handles.acquisition.microscope.ZStage,z);
    %Switch autofocus device back on if in use
    if pfsOn==1
        handles.acquisition.microscope.Autofocus.switchOn;
        handles.acquisition.microscope.Autofocus.setOffset(pfs);
    end
    uiresume(gcbf);
    
else
    errordlg('Please select one point to visit','Visit point');
end
% --- Executes on button press in saveList.
function saveList_Callback(hObject, eventdata, handles)
savePoints(handles.acquisition);
set(handles.saveList,'Value',0);


% --- Executes on button press in loadList.
function loadList_Callback(hObject, eventdata, handles)
exptFolder=char(handles.acquisition.info{3});
[filename pathname]=uigetfile(strcat(exptFolder,'/*.txt'),'Choose points file');
handles.acquisition.points=loadList(strcat(pathname,filename));
set(handles.pointsTable,'Enable','On');
set(handles.pointsTable,'Data',handles.acquisition.points);
updateDiskSpace(handles);

guidata(hObject, handles);

% --- Executes when selected cell(s) is changed in pointsTable.
function pointsTable_CellSelectionCallback(hObject, eventdata, handles)
handles.selected=eventdata.Indices;
guidata(hObject, handles);
% hObject    handle to pointsTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function user_CreateFcn(hObject, eventdata, handles)
% hObject    handle to user (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in user.
function user_Callback(hObject, eventdata, handles)
userID=get(hObject,'Value');
[swain tyers millar]=getUsers;
users=[swain tyers millar];
userName=users(userID);
handles.acquisition.info(2)=userName;
handles.acquisition.info(3)=makeRoot(userName);
set(handles.rootName,'String',cellstr(handles.acquisition.info(3)));
guidata(hObject, handles);


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
previous=char(handles.acquisition.info(4));
handles.acquisition.info(4)=cellstr(enterDetails(previous));
guidata(hObject, handles);


% --- Executes on button press in saveSettings.
function saveSettings_Callback(hObject, eventdata, handles)
folder=uigetdir(char(handles.acquisition.info(3)),'Select or create folder to save acquisition settings');
if folder == 0 %if the user pressed cancel, then we exit this callback
    return
end
saveAcquisition(handles.acquisition,folder);

% --- Executes on button press in loadSettings.
function loadSettings_Callback(hObject, eventdata, handles)
%Get the path of the last file saved - to use as default for loading
user=getenv('USERNAME');
lastSavedPath=strcat('C:\Documents and Settings\All Users\multiDGUIfiles\',user,'lastSaved.txt');
if exist (lastSavedPath,'file')==2
fileWithPath=fopen(lastSavedPath);
acqFilePath=textscan(fileWithPath,'%s','Delimiter','');%read with empty delimiter,'' - prevents new line being started at spaces in the path name 
fclose(fileWithPath);
acqFilePath=acqFilePath{:};
defaultPath=char(acqFilePath);
else
    defaultPath='C:\AcquisitionData';
end
[filename,pathname]=uigetfile('*.txt','Choose acquisition settings file',defaultPath);
handles.acquisition=loadAcquisition(strcat(pathname,filename));
%need to initialise the experimental info here - not loaded from the
%acquisition file
user=getenv('USERNAME');
root=makeRoot(user);%this provides a root directory based on the name and date
handles.acquisition.info={'exp' user root 'Aim:   Strain:  Comments:'};%Initialise the experimental info - exp name and details may be altered later when refreshGUI is called but root and user stay the same

%then import the data from the handles.acquisition structure into the GUI:
refreshGUI(handles);
guidata(hObject, handles);


function []=refreshGUI(handles)
%code here to update the gui entries based on the data in
%handles.acquisition
%Does not update the points settings  - not written yet

%channels
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    set(handles.useCh1,'Value',0);
    set(handles.useCh2,'Value',0);
    set(handles.useCh3,'Value',0);
    set(handles.useCh4,'Value',0);        
    set(handles.useCh5,'Value',0);
    set(handles.useCh6,'Value',0);
    set(handles.useCh7,'Value',0);
useDIC=0;
useCFP=0;
useGFP=0;
useYFP=0;
usemCh=0;
usetd=0;
usecy5=0;

    for ch=1:nChannels
        chName=char(handles.acquisition.channels(ch,1));
        switch chName
            case 'DIC'
            useDIC=1;%variable to check later if DIC is used
            set(handles.expCh1,'Enable','on');  
            set(handles.useCh1,'Value',1);
            set(handles.ZsectCh1,'Enable','on');
            set(handles.starttpCh1,'Enable','on');
            set(handles.cammodeCh1,'Enable','on');
            set(handles.startgainCh1,'Enable','on');
            set(handles.voltCh1,'Enable','on');
            set(handles.expCh1,'String',num2str(cell2mat(handles.acquisition.channels(ch,2))));
            set(handles.ZsectCh1,'Value',cell2mat(handles.acquisition.channels(ch,4)));
            set(handles.starttpCh1,'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
            set(handles.cammodeCh1,'Value',cell2mat(handles.acquisition.channels(ch,6)));
            set(handles.startgainCh1,'Value',cell2mat(handles.acquisition.channels(ch,7)));
            set(handles.voltCh1,'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
            
                
            case 'CFP'
            useCFP=1;
            set(handles.expCh2,'Enable','on');  
            set(handles.useCh2,'Value',1);
            set(handles.ZsectCh2,'Enable','on');
            set(handles.starttpCh2,'Enable','on');
            set(handles.cammodeCh2,'Enable','on');
            set(handles.startgainCh2,'Enable','on');
            set(handles.voltCh2,'Enable','on');
            set(handles.expCh2,'String',num2str(cell2mat(handles.acquisition.channels(ch,2))));
            set(handles.ZsectCh2,'Value',cell2mat(handles.acquisition.channels(ch,4)));
            set(handles.starttpCh2,'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
            set(handles.cammodeCh2,'Value',cell2mat(handles.acquisition.channels(ch,6)));
            set(handles.startgainCh2,'Value',cell2mat(handles.acquisition.channels(ch,7)));
            set(handles.voltCh2,'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
            case 'GFP'
              useGFP=1;
            set(handles.expCh3,'Enable','on');  
            set(handles.useCh3,'Value',1);
            set(handles.ZsectCh3,'Enable','on');
            set(handles.starttpCh3,'Enable','on');
            set(handles.cammodeCh3,'Enable','on');
            set(handles.startgainCh3,'Enable','on');
            set(handles.voltCh3,'Enable','on');
            set(handles.expCh3,'String',num2str(cell2mat(handles.acquisition.channels(ch,2))))
            set(handles.ZsectCh3,'Value',cell2mat(handles.acquisition.channels(ch,4)));
            set(handles.starttpCh3,'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
            set(handles.cammodeCh3,'Value',cell2mat(handles.acquisition.channels(ch,6)));
            set(handles.startgainCh3,'Value',cell2mat(handles.acquisition.channels(ch,7)));
            set(handles.voltCh3,'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
            case 'YFP'
            set(handles.expCh4,'Enable','on');  
            set(handles.useCh4,'Value',1);
            set(handles.ZsectCh4,'Enable','on');
            set(handles.starttpCh4,'Enable','on');
            set(handles.cammodeCh4,'Enable','on');
            set(handles.startgainCh4,'Enable','on');
            set(handles.voltCh4,'Enable','on');
            set(handles.expCh4,'String',num2str(cell2mat(handles.acquisition.channels(ch,2))))
            set(handles.ZsectCh4,'Value',cell2mat(handles.acquisition.channels(ch,4)));
            set(handles.starttpCh4,'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
            set(handles.cammodeCh4,'Value',cell2mat(handles.acquisition.channels(ch,6)));
            set(handles.startgainCh4,'Value',cell2mat(handles.acquisition.channels(ch,7)));
            set(handles.voltCh4,'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
            case 'mCherry'
            set(handles.expCh5,'Enable','on');  
            set(handles.useCh5,'Value',1);
            set(handles.skipCh5,'Enable','on');
            set(handles.ZsectCh5,'Enable','on');
            set(handles.starttpCh5,'Enable','on');
            set(handles.cammodeCh5,'Enable','on');
            set(handles.startgainCh5,'Enable','on');
            set(handles.voltCh5,'Enable','on');
            set(handles.expCh5,'String',num2str(cell2mat(handles.acquisition.channels(ch,2))))
            set(handles.ZsectCh5,'Value',cell2mat(handles.acquisition.channels(ch,4)));
            set(handles.starttpCh5,'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
            set(handles.cammodeCh5,'Value',cell2mat(handles.acquisition.channels(ch,6)));
            set(handles.startgainCh5,'Value',cell2mat(handles.acquisition.channels(ch,7)));
            set(handles.voltCh5,'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
            case 'tdTomato'
            usetd=1;            
            set(handles.expCh6,'Enable','on');  
            set(handles.useCh6,'Value',1);
            set(handles.tdskip,'Enable','on');
            set(handles.ZsectCh6,'Enable','on');
            set(handles.starttpCh6,'Enable','on');
            set(handles.cammodeCh6,'Enable','on');
            set(handles.startgainCh6,'Enable','on');
            set(handles.voltCh6,'Enable','on');
            set(handles.expCh6,'String',num2str(cell2mat(handles.acquisition.channels(ch,2))))
            set(handles.ZsectCh6,'Value',cell2mat(handles.acquisition.channels(ch,4)));
            set(handles.starttpCh6,'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
            set(handles.cammodeCh6,'Value',cell2mat(handles.acquisition.channels(ch,6)));
            set(handles.startgainCh6,'Value',cell2mat(handles.acquisition.channels(ch,7)));
            set(handles.voltCh6,'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
            case 'cy5'
            usetd=1;            
            set(handles.expCh7,'Enable','on');  
            set(handles.useCh7,'Value',1);
            set(handles.skipCh7,'Enable','on');
            set(handles.ZsectCh7,'Enable','on');
            set(handles.starttpCh7,'Enable','on');
            set(handles.cammodeCh7,'Enable','on');
            set(handles.startgainCh7,'Enable','on');
            set(handles.voltCh7,'Enable','on');
            set(handles.expCh7,'String',num2str(cell2mat(handles.acquisition.channels(ch,2))))
            set(handles.ZsectCh7,'Value',cell2mat(handles.acquisition.channels(ch,4)));
            set(handles.starttpCh7,'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
            set(handles.cammodeCh7,'Value',cell2mat(handles.acquisition.channels(ch,6)));
            set(handles.startgainCh7,'Value',cell2mat(handles.acquisition.channels(ch,7)));
            set(handles.voltCh7,'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
        end%end of channel name switch
    end%end of loop through the channels
end%end of if statment - if number of channels isn't zero

%if any channel is not used make sure all channel options are disabled
if useDIC==0
    set(handles.expCh1,'Enable','off');  
    set(handles.skipCh1,'Enable','off');
    set(handles.ZsectCh1,'Enable','off');
    set(handles.starttpCh1,'Enable','off');
    set(handles.cammodeCh1,'Enable','off');
    set(handles.startgainCh1,'Enable','off');
    set(handles.voltCh1,'Enable','off');
end
if useCFP==0
    set(handles.expCh2,'Enable','off');  
    set(handles.skipCh2,'Enable','off');
    set(handles.ZsectCh2,'Enable','off');
    set(handles.starttpCh2,'Enable','off');
    set(handles.cammodeCh2,'Enable','off');
    set(handles.startgainCh2,'Enable','off');
    set(handles.voltCh2,'Enable','off');
end
if useGFP==0
    set(handles.expCh3,'Enable','off');  
    set(handles.skipCh3,'Enable','off');
    set(handles.ZsectCh3,'Enable','off');
    set(handles.starttpCh3,'Enable','off');
    set(handles.cammodeCh3,'Enable','off');
    set(handles.startgainCh3,'Enable','off');
    set(handles.voltCh3,'Enable','off');
end
if useYFP==0
    set(handles.expCh4,'Enable','off');  
    set(handles.skipCh4,'Enable','off');
    set(handles.ZsectCh4,'Enable','off');
    set(handles.starttpCh4,'Enable','off');
    set(handles.cammodeCh4,'Enable','off');
    set(handles.startgainCh4,'Enable','off');
    set(handles.voltCh4,'Enable','off');
end
if usemCh==0
    set(handles.expCh5,'Enable','off');  
    set(handles.skipCh5,'Enable','off');
    set(handles.ZsectCh5,'Enable','off');
    set(handles.starttpCh5,'Enable','off');   
    set(handles.cammodeCh5,'Enable','off');
    set(handles.startgainCh5,'Enable','off');
    set(handles.voltCh5,'Enable','off');
end
if usetd==0
    set(handles.expCh6,'Enable','off');  
    set(handles.skipCh6,'Enable','off');
    set(handles.ZsectCh6,'Enable','off');
    set(handles.starttpCh6,'Enable','off');
    set(handles.cammodeCh6,'Enable','off');
    set(handles.startgainCh6,'Enable','off');
    set(handles.voltCh6,'Enable','off');
end
if usecy5==0
    set(handles.expCh7,'Enable','off');  
    set(handles.skipCh7,'Enable','off');
    set(handles.ZsectCh7,'Enable','off');
    set(handles.starttpCh7,'Enable','off');
    set(handles.cammodeCh7,'Enable','off');
    set(handles.startgainCh7,'Enable','off');
    set(handles.voltCh7,'Enable','off');
end
    
% Z settings - active only if at least one channel is doing z sectioning
nSections=handles.acquisition.z(1);
set(handles.nZsections,'String',num2str(nSections));
spacing=handles.acquisition.z(2);
set(handles.zspacing,'String',num2str(spacing));
%test if any channel does z sectioning
doingZ=cell2mat(handles.acquisition.channels(:,4));
anyZ=any(doingZ);
if anyZ==1
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
else
    set(handles.nZsections,'Enable','off');
    set(handles.zspacing,'Enable','off');
end

%Time settings
timeSettings=handles.acquisition.time;
set(handles.doTimelapse,'Value',timeSettings(1));
%display interval in s if less than 2 min, in min if less than 2hr
if timeSettings(2)<120
    set(handles.interval,'String',num2str(timeSettings(2)));
    set(handles.units,'Value',1);%value 1 represents seconds
elseif timeSettings(2)<7200
    set(handles.interval,'String',num2str(timeSettings(2)/60));
    set(handles.units,'Value',2);%value 2 represents minutes
else
    set(handles.interval,'String',num2str(timeSettings(2)/3600));
    set(handles.units,'Value',3);%value 3 represents hours
end
set(handles.nTimepoints,'String',num2str(timeSettings(3)));
%display total time in s if less than 2 min, in min if less than 2hr
if timeSettings(4)<120
    set(handles.totaltime,'String',num2str(timeSettings(4)));
    set(handles.unitsTotal,'Value',1);%value 1 represents seconds
elseif timeSettings(4)<7200
    set(handles.totaltime,'String',num2str(timeSettings(4)/60));
    set(handles.unitsTotal,'Value',2);%value 2 represents minutes
else
    set(handles.totaltime,'String',num2str(timeSettings(4)/3600));
    set(handles.unitsTotal,'Value',3);%value 3 represents hours
end

if timeSettings(1)==1
    set(handles.interval,'Enable','on');
    set(handles.units,'Enable','on');
    set(handles.totaltime,'Enable','on');
    set(handles.nTimepoints,'Enable','on');
    set(handles.unitsTotal,'Enable','on');
else
     set(handles.interval,'Enable','off');
    set(handles.units,'Enable','off');
    set(handles.totaltime,'Enable','off');
    set(handles.nTimepoints,'Enable','off');
    set(handles.unitsTotal,'Enable','off');
end


%flow settings
set(handles.contentsP1,'String',char(handles.acquisition.flow(1)));
set(handles.contentsP2,'String',char(handles.acquisition.flow(2)));
if cell2mat(handles.acquisition.flow(3))==1
   set(handles.start1,'Value',1);
   set(handles.start2,'Value',0);
else
   set(handles.start1,'Value',0);
   set(handles.start2,'Value',1);   
end
%Experimental info
set(handles.exptName,'String',char(handles.acquisition.info(1)));
%user and root are set automatically in the start up script of the gui
%Experimental details can be set in the callback of the enter details
%button

function contentsP1_Callback(hObject, eventdata, handles)
contents=get(hObject,'String');
handles.acquisition.flow(1)=cellstr(contents);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function contentsP1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contentsP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function contentsP2_Callback(hObject, eventdata, handles)
contents=get(hObject,'String');
handles.acquisition.flow(2)=cellstr(contents);
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function contentsP2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contentsP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start1.
function start1_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 0
        set(handles.start2,'Value',1);
        handles.acquisition.flow{3}=2;%starting pump is pump 2
    case 1
        set(handles.start2,'Value',0);
        handles.acquisition.flow{3}=1;%starting pump is pump 1
end
guidata(hObject, handles);
updateFlowDisplay(handles);



% --- Executes on button press in start2.
function start2_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 0
        set(handles.start1,'Value',1);
        handles.acquisition.flow{3}=1;%starting pump is pump 1
    case 1
        set(handles.start1,'Value',0);
        handles.acquisition.flow(3)=num2cell(2);%starting pump is pump 2
end
guidata(hObject, handles);
updateFlowDisplay(handles);



% --- Executes on selection change in switchMethod.
function switchMethod_Callback(hObject, eventdata, handles)

contents=get(hObject,'String');
choice=contents{get(hObject,'Value')};
switch choice
    case 'Enter switch times'
        %Define a variable to check if inputs are OK
        problem=false;
        %Define default values (based on contents of the switching object)
        %Times (as comma, separated string)       
        defaults{1}=commaString(handles.acquisition.flow{5}.times);
        %Initially-dominant pump
        defaults{2}=num2str(handles.acquisition.flow{5}.initialPump);
        %Post-switch flow rates
        %Pump to switch to is the highest flow rate between the first two
        %entries in switches.flowPostSwitch
        defaults{3}=num2str(max(handles.acquisition.flow{5}.flowPostSwitch(:,1)));
        defaults{4}=num2str(min(handles.acquisition.flow{5}.flowPostSwitch(:,1)));
        %Get user input
        answers=inputdlg({'Enter switching times in min after start of timelapse (separated by commas): ','Which pump has the higher flow rate initially?','Enter flow rates (after switching) of pump to switch to (in ul/min, separated by commas)','Enter flow rates (after switching) of pump to switch from (in ul/min, separated by commas)'},'Switching parameters',1,defaults);
        %Process switching times
        times=answers{1};
        %CONVERT TO VECTOR OF DOUBLES
        txtTimes=textscan(times,'%f','Delimiter',',');
        txtTimes=cell2mat(txtTimes);
        regTimes=regexp(times,[','],'Split');
        %Initial pump
        initialPump=answers{2};
        initialPump=str2num(initialPump);
        if isempty(initialPump)
           problem=true;
           errorMessage='Initial pump must be either 1 or 2';
        else
            if ~(initialPump==2||initialPump==1)
               problem=true;
               errorMessage='Initial pump must be either 1 or 2';
            end
        end
        
        
        %Flow rates
        hFlw=answers{3};
        highFlow=textscan(hFlw,'%f','Delimiter',',');
        highFlow=cell2mat(highFlow)';
        lFlw=answers{4};
        lowFlow=textscan(lFlw,'%f','Delimiter',',');
        lowFlow=cell2mat(lowFlow)';
        if ~any(isnan([highFlow lowFlow]))
            if length(txtTimes)==length(regTimes)
                flowRates=[highFlow; lowFlow];
                if size(flowRates,2)==1
                    %A single pair of flow rates has been entered -
                    %alternate these at each switch
                    ind=logical(mod(1:length(txtTimes),2));%Logical index to the odd number entries (entry 1, 3, 5 etc).
                    oldFlow=flowRates;                   
                    flowRates=repmat(flowRates,1,length(txtTimes));
                    %Now all entries are the same - first flow input
                    %followed by second. Swap the even entries
                    
                    if initialPump==1
                        flowRates(1,ind)=oldFlow(2);%The lower flow rate - for times 1, 3, 5 etc.
                        flowRates(1,logical(1-ind))=oldFlow(1);%The higher flow rate - for times 2, 4, 6 etc.                                       
                        flowRates(2,ind)=oldFlow(1);%The higher flow rate - for times 1, 3, 5 etc
                        flowRates(2,logical(1-ind))=oldFlow(2);%The lower flow rate - for times 2, 4, 6 etc

                    else
                        %Pump 2 is dominant at the start of the experiment
                        %- 1st switch is to pump 1 - so that has the higher
                        %rate after the odd numbered switches.
                        flowRates(1,ind)=oldFlow(1);%The higher flow rate - for switches 1, 3, 5 etc.
                        flowRates(1,logical(1-ind))=oldFlow(2);%The lower flow rate - for times 2, 4, 6 etc.
                        flowRates(2,ind)=oldFlow(2);%The lower flow rate - for times 1, 3, 5 etc
                        flowRates(2,logical(1-ind))=oldFlow(1);%The higher flow rate - for times 2, 4, 6 etc

                    end
                end
                if ~problem
                    handles.acquisition.flow{5}=handles.acquisition.flow{5}.setSwitchTimes(txtTimes,flowRates,initialPump);
                end
                else
                problem=true;
                errorMessage='Answer contains invalid times';
            end
        else
            problem=true;
            errorMessage='Answer contains invalid times';
        end
    if problem
        errordlg(errorMessage);
    end
    case 'Periodic'
        defaults={'30','0',num2str(handles.acquisition.time(4)/60),'4','.4'};
        input = inputdlg({'Switch the flow every....min','Start switching at ... min','Stop switching at ... min','Flow rate of dominant pump (ul/min)','Flow rate of non-dominant pump (ul/min)'},'Periodic switching',1,defaults);
        interval=input{1};
        switchInterval=str2double(interval);
        switchStart=str2double(input{2});
        switchStop=str2double(input{3});
        highFlow=str2double(input{4});
        lowFlow=str2double(input{5});
        if ~any(isnan([switchInterval switchStart switchStop highFlow lowFlow]))
            handles.acquisition.flow{5}=handles.acquisition.flow{5}.setPeriodic(switchInterval,switchStart,switchStop,highFlow, lowFlow);
        else
            errordlg('All inputs must be numbers');
        end
        handles.period=switchInterval;

    case 'Linear Ramp'
        defaults={'1',num2str(handles.acquisition.time(4)/60),'4','.4','1','2'};
        input = inputdlg({'Start ramp at....min','End ramp at... min','Flow rate at high end of ramp (ul/min)','Flow rate at low end of ramp (ul/min)','Starting Pump High','Ending Pump High'},'Create linear flow ramp',1,defaults);
        rampStart=str2double(input{1});
        rampStop=str2double(input{2});
        highFlow=str2double(input{3});
        lowFlow=str2double(input{4});
        startPump=str2double(input{5});
        endPump=str2double(input{6});
        handles.acquisition.flow{5}=handles.acquisition.flow{5}.makeLinearRamp(rampStart,rampStop,highFlow,lowFlow,startPump,endPump);

case 'Design flow transition'
    d=transitionGUI;
  % handles.acquisition.flow{5}.times=d(:,1);
  % handles.acquisition.flow{5}.flowPostSwitch=d(:,[2 3]);
    handles.acquisition.flow{5}=handles.acquisition.flow{5}.setFlowTimes(d(:,1)', d(:,[2 3])');
    handles.acquisition.flow{5}.switchedTo=0;
    handles.acquisition.flow{5}.switchedFrom=0;

    
case 'Enter times'
        if handles.acquisition.flow{5}.times==0
            defaults={'0', '4', '.4'};
        else
        timeString='';
        pump1String='';
        pump2String='';
        for n=1:length(handles.acquisition.flow{5}.times)
            thisTimeString=num2str(handles.acquisition.flow{5}.times(n));%String made from the time entry
            charsT=length(thisTimeString);%Number of characters in the time entry for this change
            thisP1String=num2str(handles.acquisition.flow{5}.flowPostSwitch(1,n));
            charsP1=length(thisP1String);
            thisP2String=num2str(handles.acquisition.flow{5}.flowPostSwitch(2,n));
            charsP2=length(thisP2String);
            if n<length(handles.acquisition.flow{5}.times)                
                timeString(length(timeString)+1:length(timeString)+1+charsT)=[thisTimeString ','];
                
                pump1String(length(pump1String)+1:length(pump1String)+1+charsP1)=[thisP1String ','];
                pump2String(length(pump2String)+1:length(pump2String)+1+charsP2)=[thisP2String ','];

            else%This is the last change - don't add a comma
                timeString(length(timeString)+1:length(timeString)+charsT)=thisTimeString;
                pump1String(length(pump1String)+1:length(pump1String)+charsP1)=thisP1String;
                pump2String(length(pump2String)+1:length(pump2String)+charsP2)=thisP2String;

            end
        end
        defaults={timeString,pump1String,pump2String};
        end
        answers=inputdlg({'Enter flow times in min after start of timelapse (separated by commas): ','Enter flow rates of pump 1 (in ul/min, separated by commas)','Enter flow rates of pump 2 (in ul/min, separated by commas)'},'Flow parameters',1,defaults);
        times=answers{1};
        %CONVERT TO VECTOR OF DOUBLES
        txtTimes=textscan(times,'%f','Delimiter',',');
        txtTimes=cell2mat(txtTimes);
        regTimes=regexp(times,[','],'Split');
        %Flow rates
                hFlw=answers{2};
        pump1flow=textscan(hFlw,'%f','Delimiter',',');
        pump1flow=cell2mat(pump1flow)';
        lFlw=answers{3};
        pump2flow=textscan(lFlw,'%f','Delimiter',',');
        pump2flow=cell2mat(pump2flow)';
        if ~any(isnan([pump1flow pump2flow]))
            if length(txtTimes)==length(regTimes)
                flowRates=[pump1flow; pump2flow];
                if size(flowRates,2)==1
                    flowRates=repmat(flowRates,1,length(txtTimes));
                end
                handles.acquisition.flow{5}=handles.acquisition.flow{5}.setFlowTimes(txtTimes,flowRates);
            else
                errordlg('Answer contains invalid times');
            end
        else
            errordlg('Answer contains invalid times');
            
        end
end
handles.acquisition.flow{5}.displayFlowChanges;
    

guidata(hObject, handles);
updateFlowDisplay(handles);



function []=updateFlowDisplay(handles)
%Updates the gui display to show the flow and pump information contained in
%handles.acquisition
for n=1:length(handles.acquisition.flow{4})
    volString=pump.getVolString(handles.acquisition.flow{4}(n).diameter);
    set (handles.(['diameterP' num2str(n)]),'Value',find(strcmp(get(handles.(['diameterP' num2str(n)]),'String'),volString)));
    set (handles.(['contentsP' num2str(n)]),'String',num2str(handles.acquisition.flow{4}(n).contents));
    set (handles.(['directionP' num2str(n)]),'Value',find(strcmp(num2str(handles.acquisition.flow{4}(n).direction),get(handles.(['directionP' num2str(n)]),'String'))));
    set (handles.(['flowRateP' num2str(n)]),'String',num2str(handles.acquisition.flow{4}(n).currentRate));
    set (handles.(['runP' num2str(n)]),'Value',handles.acquisition.flow{4}(n).running);
end







% --- Executes during object creation, after setting all properties.
function switchMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to switchMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function updateFlowData(hObject, eventdata, handles)
    %Records information from the gui controls in the flow panel to
    %handles.acquisition.flow
    
    %If a pump control has been altered, need to know which one it was
        
    nPumps=2;
    for n=1:nPumps
        volCell=get(handles.(['diameterP' num2str(n)]),'String');
        volString=volCell{get(handles.(['diameterP' num2str(n)]),'Value')};        
        handles.acquisition.flow{4}(n).diameter=pump.getDiameter(volString);
        handles.acquisition.flow{4}(n).contents=get(handles.(['contentsP' num2str(n)]),'String');
        dirCell=get(handles.(['directionP' num2str(n)]),'String');
        dirString=dirCell{get(handles.(['directionP' num2str(n)]),'Value')}; 
        handles.acquisition.flow{4}(n).direction=dirString;
        handles.acquisition.flow{4}(n).currentRate=str2num(get(handles.(['flowRateP' num2str(n)]),'String'));
        handles.acquisition.flow{4}(n).running=get(handles.(['runP' num2str(n)]),'Value');        
        handles.acquisition.flow{4}(n).updatePumps;%sends information to the syringe pumps
        handles.acquisition.flow{5}.pumps{n}=handles.acquisition.flow{4}(n);
    end
    
    guidata(hObject, handles);

    



% --- Executes on button press in eye.
function eye_Callback(hObject, eventdata, handles)
eyepiece;

% --- Executes on button press in camera.
function camera_Callback(hObject, eventdata, handles)
camera;


% --- Executes on button press in loadConfig.
function loadConfig_Callback(hObject, eventdata, handles)
guiconfig2(handles.acquisition.microscope);
handles=handles.acquisition.microscope.setGUI(handles);
binOptions=get(handles.bin,'String');
bin=binOptions{get(handles.bin,'Value')};
handles.acquisition.microscope.setBin(bin);
set(handles.eye,'Enable','on');
set(handles.camera,'Enable','on');
set(handles.EM,'Enable','on');
set(handles.CCD,'Enable','on');

for i=1:length(handles.acquisition.flow{5}.pumps)
    try
            handles.acquisition.flow{5}.pumps{i}.openPump;   
    catch
       warndlg(['Failed to connect to pump number ' num2str(i)]);
    end
end
guidata(hObject, handles);




% --- Executes on button press in EM.
function EM_Callback(hObject, eventdata, handles)
EM;
set(handles.CCD,'Value',0);






% --- Executes on button press in CCD.
function CCD_Callback(hObject, eventdata, handles)
CCD;
set(handles.EM,'Value',0);


% --- Executes on selection change in cammodeCh1.
function cammodeChannel_Callback(hObject, eventdata, handles)
[chName tagEnd]=getChannel(hObject,handles);



value=get(hObject,'Value');
switch value
    case 1%EM_Smart mode selected
        set(handles.(['startgain' tagEnd]),'Enable','on');
        set(handles.(['volt' tagEnd]),'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),chName)==1
                handles.acquisition.channels{n,6}=value;%1=EM camera mode with correction
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.(['startgain' tagEnd]),'Enable','off');
        set(handles.(['volt' tagEnd]),'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),chName)==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end
     case 3%EM_Constant mode selected
        set(handles.(['startgain' tagEnd]),'Enable','on');
        set(handles.(['volt' tagEnd]),'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),chName)==1
                handles.acquisition.channels{n,6}=value;%3=EM constant
            end
            end
        end
    
end
guidata(hObject, handles);
 


% --- Executes during object creation, after setting all properties.
function cammodeCh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cammodeCh2.
function cammodeCh2_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 1%EM mode selected
        set(handles.startgainCh2,'Enable','on');
        set(handles.voltCh2,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'CFP')==1
                handles.acquisition.channels{n,6}=1;%1=EM camera mode
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.startgainCh2,'Enable','off');
        set(handles.voltCh2,'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'CFP')==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end       
    case 3%EM mode selected
        set(handles.startgainCh2,'Enable','on');
        set(handles.voltCh2,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'CFP')==1
                handles.acquisition.channels{n,6}=3;%3=EM constant camera mode
            end
            end
        end 
    
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cammodeCh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cammodeCh3.
function cammodeCh3_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 1%EM mode selected
        set(handles.startgainCh3,'Enable','on');
        set(handles.voltCh3,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'GFP')==1
                handles.acquisition.channels{n,6}=1;%1=EM camera mode
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.startgainCh3,'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'GFP')==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end     
        case 3%EM mode selected
        set(handles.startgainCh3,'Enable','on');
        set(handles.voltCh3,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'GFP')==1
                handles.acquisition.channels{n,6}=3;%3=EM_constant camera mode
            end
            end
        end
    
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cammodeCh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cammodeCh4.
function cammodeCh4_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 1%EM mode selected
        set(handles.startgainCh4,'Enable','on');
        set(handles.voltCh4,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'YFP')==1
                handles.acquisition.channels{n,6}=1;%1=EMCCD camera mode
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.startgainCh4,'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'YFP')==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end       
    case 3%EM mode selected
        set(handles.startgainCh4,'Enable','on');
        set(handles.voltCh4,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'YFP')==1
                handles.acquisition.channels{n,6}=3;%3=EMCCD constant camera mode
            end
            end
        end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cammodeCh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cammodeCh5.
function cammodeCh5_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 1%EM mode selected
        set(handles.startgainCh5,'Enable','on');
        set(handles.voltCh5,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'mCherry')==1
                handles.acquisition.channels{n,6}=1;%1=EM camera mode
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.startgainCh5,'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'mCherry')==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end       
     case 3%EM mode selected
        set(handles.startgainCh5,'Enable','on');
        set(handles.voltCh5,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'mCherry')==1
                handles.acquisition.channels{n,6}=3;%3=EM constant camera mode
            end
            end
        end 
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cammodeCh5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cammodeCh6.
function cammodeCh6_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 1%EM mode selected
        set(handles.startgainCh6,'Enable','on');
        set(handles.voltCh6,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'tdTomato')==1
                handles.acquisition.channels{n,6}=1;%1=EMCCD camera mode
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.startgainCh6,'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'tdTomato')==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end       
    case 3%EM mode selected
        set(handles.startgainCh6,'Enable','on');
        set(handles.voltCh6,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'tdTomato')==1
                handles.acquisition.channels{n,6}=3;%3=EMCCD constant camera mode
            end
            end
        end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cammodeCh6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainChannel_Callback(hObject, eventdata, handles)
[chName tagEnd]=getChannel(hObject,handles);

startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),chName)==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function startgainCh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainCh2_Callback(hObject, eventdata, handles)
startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),'CFP')==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function startgainCh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainCh3_Callback(hObject, eventdata, handles)
startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),'GFP')==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function startgainCh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainCh4_Callback(hObject, eventdata, handles)
startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),'YFP')==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function startgainCh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainCh5_Callback(hObject, eventdata, handles)
startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),'mCherry')==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function startgainCh5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainCh6_Callback(hObject, eventdata, handles)
startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),'tdTomato')==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function startgainCh6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in snapCh1.
function snap_Callback(hObject, eventdata, handles)

channel={};
tag=get(hObject,'Tag');
chNum=tag(end);
useTag=['useCh' num2str(chNum)];
expTag=['expCh' num2str(chNum)];
cammodeTag=['cammodeCh' num2str(chNum)];
startGainTag=['startgainCh' num2str(chNum)];
voltTag=['voltCh' num2str(chNum)];

channel(1)=cellstr(get(handles.(useTag),'String'));
channel(2)=num2cell(str2double(get(handles.(expTag),'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.(cammodeTag),'Value'));
channel(7)=num2cell(str2double(get(handles.(startGainTag),'String')));
channel(8)=num2cell(str2double(get(handles.(voltTag),'String')));

    snap(channel, handles.acquisition.microscope);
set(hObject,'Value',0);


% --- Executes on button press in snapCh2.
function snapCh2_Callback(hObject, eventdata, handles)
channel={};
channel(1)=cellstr('CFP');
channel(2)=num2cell(str2double(get(handles.expCh2,'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.cammodeCh2,'Value'));
channel(7)=num2cell(str2double(get(handles.startgainCh2,'String')));
channel(8)=num2cell(str2double(get(handles.voltCh2,'String')));

    snap(channel);
set(handles.snapCh2,'Value',0);
% --- Executes on button press in snapCh3.
function snapCh3_Callback(hObject, eventdata, handles)

channel={};
channel(1)=cellstr('GFP');
channel(2)=num2cell(str2double(get(handles.expCh3,'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.cammodeCh3,'Value'));
channel(7)=num2cell(str2double(get(handles.startgainCh3,'String')));
channel(8)=num2cell(str2double(get(handles.voltCh3,'String')));

    snap(channel);
set(handles.snapCh3,'Value',0);

% --- Executes on button press in snapCh4.
function snapCh4_Callback(hObject, eventdata, handles)
channel={};
channel(1)=cellstr('YFP');
channel(2)=num2cell(str2double(get(handles.expCh4,'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.cammodeCh4,'Value'));
channel(7)=num2cell(str2double(get(handles.startgainCh4,'String')));
channel(8)=num2cell(str2double(get(handles.voltCh4,'String')));
    snap(channel);
set(handles.snapCh4,'Value',0);

% --- Executes on button press in snapCh5.
function snapCh5_Callback(hObject, eventdata, handles)
channel={};
channel(1)=cellstr('mCherry');
channel(2)=num2cell(str2double(get(handles.expCh5,'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(str2mat((get(handles.cammodeCh5,'Value'))));
channel(7)=num2cell(str2double(get(handles.startgainCh5,'String')));
channel(8)=num2cell(str2double(get(handles.voltCh5,'String')));

    snap(channel);
    set(handles.snapCh5,'Value',0);


% --- Executes on button press in snapCh6.
function snapCh6_Callback(hObject, eventdata, handles)
channel={};
channel(1)=cellstr('tdTomato');
channel(2)=num2cell(str2double(get(handles.expCh6,'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(str2mat((get(handles.cammodeCh6,'Value'))));
channel(7)=num2cell(str2double(get(handles.startgainCh6,'String')));
channel(8)=num2cell(str2double(get(handles.voltCh6,'String')));

    snap(channel);
    set(handles.snapCh6,'Value',0);



% --- Executes during object creation, after setting all properties.
function voltCh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function voltCh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function voltCh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function voltCh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function voltCh5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function voltCh6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
cellcount60x('count',1);


% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mmc;
disp('Debug here');



function expCh7_Callback(hObject, eventdata, handles)
expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'cy5')==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function expCh7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cy5pointexp.
function cy5pointexp_Callback(hObject, eventdata, handles)
pointexpose=get(hObject,'Value');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if pointexpose==1;
   set(handles.expCh7,'Enable','off'); 

else
    set(handles.expCh7,'Enable','on');
end
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'cy5')==1
        handles.acquisition.channels{n,3}=pointexpose;
        end
    end
end
 guidata(hObject, handles);

% --- Executes on selection change in cammodeCh7.
function cammodeCh7_Callback(hObject, eventdata, handles)
value=get(hObject,'Value');
switch value
    case 1%EM mode selected
        set(handles.startgainCh7,'Enable','on');
        set(handles.voltCh7,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'cy5')==1
                handles.acquisition.channels{n,6}=1;%1=EMCCD camera mode
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.startgainCh7,'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'cy5')==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end       
    case 3%EM mode selected
        set(handles.startgainCh7,'Enable','on');
        set(handles.voltCh7,'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),'cy5')==1
                handles.acquisition.channels{n,6}=3;%3=EMCCD constant camera mode
            end
            end
        end    
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cammodeCh7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainCh7_Callback(hObject, eventdata, handles)

startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),'cy5')==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function startgainCh7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voltCh7_Callback(hObject, eventdata, handles)
% hObject    handle to voltCh7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voltCh7 as text
%        str2double(get(hObject,'String')) returns contents of voltCh7 as a double


% --- Executes during object creation, after setting all properties.
function voltCh7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ZsectCh7.
function ZsectCh7_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'cy5')==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'cy5')==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
    end
end
updateDiskSpace(handles);
  guidata(hObject, handles);



function starttpCh7_Callback(hObject, eventdata, handles)
offset=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
if isempty(get(hObject,'String'))~=1;
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),'cy5')==1
            handles.acquisition.channels(n,5)=num2cell(offset);
            end
        end
else
    set(handles.starttpCh7,'String','0');
     for n=1:sizeChannels(1)
         if strcmp(char(handles.acquisition.channels(n,1)),'cy5')==1
            handles.acquisition.channels(n,5)=num2cell(0);
            end
     end   
end
updateDiskSpace(handles);
   guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function starttpCh7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in snapCh7.
function snapCh7_Callback(hObject, eventdata, handles)

channel={};
channel(1)=cellstr('cy5');
channel(2)=num2cell(str2double(get(handles.expCh7,'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.cammodeCh7,'Value'));
channel(7)=num2cell(str2double(get(handles.startgainCh7,'String')));
channel(8)=num2cell(str2double(get(handles.voltCh7,'String')));

    snap(channel);
set(handles.snapCh7,'Value',0);

 

% --- Executes on button press in useCh7.
function useCh7_Callback(hObject, eventdata, handles)
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
     if get(handles.ZsectCh7,'Value')==1
       set(handles.nZsections,'Enable','on');
       set(handles.zspacing,'Enable','on');
     end
   set(handles.skipCh7,'Enable','on');
   set(handles.ZsectCh7,'Enable','on');
   set(handles.starttpCh7,'Enable','on');%add to others
   set(handles.snapCh7,'Enable','on');
   set(handles.cammodeCh7,'Enable','on');
    %camera settings - enable controls
   set(handles.cammodeCh7,'Enable','on');%%%%%
   if get(handles.cammodeCh7,'Value')==1%channel set to camera EM mode
       set (handles.startgainCh7,'Enable','on');%%%%%
       set (handles.voltCh7,'Enable','on');%%%%%
   end   %%%%%
   if get(handles.skipCh7,'Value')~=1
   set(handles.expCh7,'Enable','on');
   end
   handles.acquisition.channels{nChannels+1,1}='cy5';
   handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.expCh7,'String'));
   handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.skipCh7,'String'));
   handles.acquisition.channels{nChannels+1,4}=get(handles.ZsectCh7,'Value');%add to others
   handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.starttpCh7,'String'));%add to others
   %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.cammodeCh7,'Value');
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.startgainCh7,'String'));
   if isempty(handles.acquisition.channels(nChannels+1,7))
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end
      handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.voltCh7,'String')));
   %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else
    set(handles.expCh7,'Enable','off');
    set(handles.skipCh7,'Enable','off');
    set(handles.ZsectCh7,'Enable','off');%add to others
    set(handles.starttpCh7,'Enable','off');%add to others
    set(handles.snapCh7,'Enable','off');
    set(handles.cammodeCh7,'Enable','off');
    set(handles.startgainCh7,'Enable','off');%%%%%
    set(handles.voltCh7,'Enable','off');%%%%%
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it. And also records if any channel does sectioning.
            if strcmp(char(handles.acquisition.channels(n,1)),'cy5')==1
            delnumber=n;
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0%deactivate z settings choices if no channel is using z
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);


% --- Executes on button press in replace.
function replace_Callback(hObject, eventdata, handles)
global mmc;
%confirm only one point is selected
sizes=size(handles.selected);
    nSelected=sizes(1);
if nSelected==1
    ans=questdlg('Do you want to adjust all z positions?');  
    table=get(handles.pointsTable,'Data');
    row=handles.selected(1);
    if strcmp(ans,'Yes')
        oldZ=table{row,4};
    end
    table{row,2}=mmc.getXPosition('XYStage');
    table{row,3}=mmc.getYPosition('XYStage');
    table{row,4}=mmc.getPosition(handles.acquisition.microscope.ZStage);
    table{row,5}=handles.acquisition.microscope.Autofocus.getOffset;
    if strcmp(ans,'Yes')
        diff=table{row,4}-oldZ;
        for n=1:size(table,1)
            if n~=row
                table{n,4}=table{n,4}+diff;
            end
        end
    end
           
    set(handles.pointsTable,'Data',table);
    handles.acquisition.points=table;
    guidata(hObject, handles);

else
       errordlg('Please select one point to replace','Replace point');

end


% --- Executes on button press in checkPFS.
function checkPFS_Callback(hObject, eventdata, handles)
handles.acquisition.z(6)=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in LEDon.
function LEDon_Callback(hObject, eventdata, handles)
% hObject    handle to LEDon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LEDon


function handles=updatePoints(handles,deleted)
%updates the points table when changes are made to the number of channels
%imaged
%The optional input 'deleted' indicates which channel has been removed
headings=get(handles.pointsTable,'ColumnName');
if nargin==1%only the handles input is supplied. This means no channel has been deleted - a channel has been added
    numColumns=size(headings,1);
    lastChan=size(handles.acquisition.channels,1);%the index to the channel that has just been added
    defExp=handles.acquisition.channels(lastChan,2);%exposure time from channels panel - default exposure - to be used initially for all point groups but then editable
    numPoints=size(handles.acquisition.points,1);
    newcolumn=zeros(numPoints,1);
    newcolumn(:,1)=cell2mat(defExp);
    newcolumn=num2str(newcolumn);
    for pos=1:size(newcolumn,1)
        handles.acquisition.points(pos,numColumns+1)={newcolumn(pos,:)};
    end
    %Now deal with the headings of the points table.
    headings(numColumns+1)=strcat(handles.acquisition.channels(lastChan,1),'(ms)');
    else%a deleted channel number has been input
    toDelete=deleted+6;
    nameToDelete=strcat(handles.acquisition.channels(deleted,1),'(ms)');
    handles.acquisition.points(:,toDelete)=[];
    n=7;
    done=0;
    while done==0 && n<=size(headings,1)
        if strcmp(headings(n),nameToDelete)==1
            headings(n)=[];
            done=1;
        end
        n=n+1;
    end
end
set(handles.pointsTable,'ColumnName',headings);
set (handles.pointsTable,'Data',handles.acquisition.points);%update the table


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)


% --- Executes on button press in stopacq.
function stopacq_Callback(hObject, eventdata, handles)
% hObject    handle to stopacq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stop=1;
set(handles.start,'Enable','on');set(handles.stopacq,'Enable','off');

guidata(hObject,handles);



function skipChannel_Callback(hObject, eventdata, handles)

[chName tagEnd]=getChannel(hObject,handles);

skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),chName)==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function skipCh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipCh2_Callback(hObject, eventdata, handles)
skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'CFP')==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function skipCh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipCh3_Callback(hObject, eventdata, handles)
skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'GFP')==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function skipCh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipCh4_Callback(hObject, eventdata, handles)
skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'YFP')==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function skipCh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipCh5_Callback(hObject, eventdata, handles)
skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'mCherry')==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function skipCh5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipCh6_Callback(hObject, eventdata, handles)
skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'tdTomato')==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function skipCh6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function skipCh7_Callback(hObject, eventdata, handles)
skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),'cy5')==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function skipCh7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pgcount.
function pgcount_Callback(hObject, eventdata, handles)
strain=inputdlg('Enter sample details','Picogreen cell count');
picogreencellcount60x(strain,1)


% --- Executes on selection change in OmeroProjects.
function OmeroProjects_Callback(hObject, eventdata, handles)
% hObject    handle to OmeroProjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents=get(hObject,'String');
value=get(hObject,'Value');
answer=contents{get(hObject,'Value')};

if strcmp(answer,'Add a new project')
    newName = inputdlg('Enter new project name','New project',1);
    if ~isempty(newName)
        if ~isempty(newName{1})
            newName=newName{1};
            if ~any(strcmp(newName,contents))
                %The project name is a new one
                description=inputdlg('Enter a description for the new project','Project description',7);
                %Add this project name to the record of projects that
                %should be in the database - it will be added the next time
                %the upload script is run.
                handles.acquisition.omero.object.Projects(end+1).name=newName;
                handles.acquisition.omero.object.Projects(end).id=0;%This marks it as a new project to be created
                handles.acquisition.omero.object.Projects(end).description=description;
                obj2=handles.acquisition.omero.object;
                path=obj2.pcPath;
                save(path,'obj2');
                %Add the new project name to the menu
                contents{end}=newName;
                contents{end+1}='Add a new project';
                set(handles.OmeroProjects,'String',contents);
                set(handles.OmeroProjects,'Value',length(contents)-1);
                set(handles.Project,'String',newName);
                %Set the new project as the selected one
                handles.acquisition.omero.project=newName;
            else
                %There is already a project with this name
                %Set the menu value to this project
                index=find(strcmp(newName,contents));
                set(handles.OmeroProjects,'Value',index(1));
                handles.acquisition.omero.project=newName;
                set(handles.Project,'String',newName);
            end           
        end
    end
else
    %The user has selected an existing project
    handles.acquisition.omero.project=answer;
    set(handles.Project,'String',answer);

end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function OmeroProjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OmeroProjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OmeroTags.
function OmeroTags_Callback(hObject, eventdata, handles)
% hObject    handle to OmeroTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents=get(hObject,'String');
answer=contents{get(hObject,'Value')};
value=get(hObject,'Value');

if strcmp(answer,'Add a new tag')
    newName = inputdlg('Enter new tag','New tag',1);
    if ~isempty(newName)
        if ~isempty(newName{1})
            newName=newName{1};
            if ~any(strcmp(newName,contents))
                %The tag name is a new one            
                description=inputdlg('Enter a description for the new tag','Tag description',7);
                %Record the new tag in the record of tags that should be in
                %the database - it will be added the next time the upload
                %script is run.
                handles.acquisition.omero.object.Tags(end+1).name=newName;
                handles.acquisition.omero.object.Tags(end).id=0;%This marks it as a new tag to be created
                handles.acquisition.omero.object.Tags(end).description=description;
                obj2=handles.acquisition.omero.object;
                path=obj2.pcPath;
                save(path,'obj2'); 
                %Add the new tag name to the menu
                contents{end}=newName;
                contents{end+1}='Add a new tag';
                set(handles.OmeroTags,'String',contents);
                set(handles.OmeroTags,'Value',length(contents)-1);
                %Add the new tag to the list associated with this
                %experiment
                handles.acquisition.omero.tags{end+1}=newName;
                %Display the new list.
                set(handles.TagList,'String',handles.acquisition.omero.tags);         
            end
        end
    end
else
    if value<length(contents)%Last item in contents is just 'Select an omero project for your experiment...'
        if ~any(strcmp(handles.acquisition.omero.tags,answer))%If statement to avoid repeatedly adding the same tag to the list
            handles.acquisition.omero.tags{end+1}=answer;
            set(handles.TagList,'String',handles.acquisition.omero.tags);
        end
    end
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function OmeroTags_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OmeroTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TagList.
function TagList_Callback(hObject, eventdata, handles)
% hObject    handle to TagList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TagList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TagList


% --- Executes during object creation, after setting all properties.
function TagList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TagList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in removeTag.
function removeTag_Callback(hObject, eventdata, handles)
% hObject    handle to removeTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.removeTag,'Value',0);
toDelete=get(handles.TagList,'Value');
tagList=get(handles.TagList,'String');
if ~strcmp(handles.acquisition.omero.tags{toDelete},date)
    handles.acquisition.omero.tags(toDelete)=[];
    set(handles.TagList,'Value',toDelete-1);
    set(handles.TagList,'String',handles.acquisition.omero.tags);
else
    disp('You cannot delete the date tag');
end
guidata(hObject,handles);


% --- Executes on button press in makeTile.
function makeTile_Callback(hObject, eventdata, handles)
set(handles.pointsTable,'Enable','on');%Make sure the table is activated (won't be if this is the first point to be defined)

correctLens=false;
while ~correctLens
    lens=inputdlg('Enter lens magnification (10, 40 (Robin only), 60 or 100):','Tile creation: enter magnification',1,{'60'});
    if any(strcmp(lens{:},{'40', '60','100','10'}));
        correctLens=true;
    end
end
defaults={'10','10','',''};
switch lens{:}
    case '10'
        defaults{3}='824';
        defaults{4}='824';
    case '40'
        defaults{1}='15';
        defaults{2}='5';
        defaults{3}='155'; %167 to be touching
        defaults{4}='-200'; %220 to be adjacent
    case '60'
        defaults{3}='137';
        defaults{4}='137';
    case '100'
        defaults{3}='82.4';
        defaults{4}='82.4';
end
answers=inputdlg({'Number of rows (y)','Number of columns(x)','Space between rows (microns)','Space between columns (microns)'},'Tile creation: define dimensions',1,defaults);

currPosList=handles.acquisition.points;
[tiles handles]=makeTiles(str2num(answers{1}),str2num(answers{2}),str2num(answers{3}),str2num(answers{4}), handles);
tiles(1:size(currPosList,1),:)=currPosList;
set(handles.pointsTable,'Data',tiles);
handles.acquisition.points=tiles;
set(handles.pointsTable,'Enable','on');%Make sure the table is activated (won't be if this is the first point to be defined)
updateDiskSpace(handles);
guidata(hObject,handles);


% --- Executes on button press in switchParams.
function switchParams_Callback(hObject, eventdata, handles)
% hObject    handle to switchParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.acquisition.flow{5}=handles.acquisition.flow{5}.setSwitchParams;

guidata(hObject,handles);

% --- Executes on button press in runP1.
function runP1_Callback(hObject, eventdata, handles)
% hObject    handle to runP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of runP1


% --- Executes on selection change in directionP1.
function directionP1_Callback(hObject, eventdata, handles)
% hObject    handle to directionP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directionP1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directionP1


% --- Executes during object creation, after setting all properties.
function directionP1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directionP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in directionP2.
function directionP2_Callback(hObject, eventdata, handles)
% hObject    handle to directionP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directionP2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directionP2


% --- Executes during object creation, after setting all properties.
function directionP2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directionP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in diameterP1.
function diameterP1_Callback(hObject, eventdata, handles)
% hObject    handle to diameterP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns diameterP1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from diameterP1


% --- Executes during object creation, after setting all properties.
function diameterP1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diameterP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flowRateP1_Callback(hObject, eventdata, handles)
% hObject    handle to flowRateP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flowRateP1 as text
%        str2double(get(hObject,'String')) returns contents of flowRateP1 as a double


% --- Executes during object creation, after setting all properties.
function flowRateP1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flowRateP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runP2.
function runP2_Callback(hObject, eventdata, handles)
% hObject    handle to runP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of runP2


% --- Executes on selection change in diameterP2.
function diameterP2_Callback(hObject, eventdata, handles)
% hObject    handle to diameterP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns diameterP2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from diameterP2
contents = cellstr(get(hObject,'String'));
volString=contents{get(hObject,'Value')};
diameter=pump.getDiameter(volString);
pumpSerial=handles.acquisition.flow{4}(2).serial;
fprintf(pumpSerial,['DIA' num2str(diameter)]);pause(.05);


% --- Executes during object creation, after setting all properties.
function diameterP2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diameterP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flowRateP2_Callback(hObject, eventdata, handles)
% hObject    handle to flowRateP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flowRateP2 as text
%        str2double(get(hObject,'String')) returns contents of flowRateP2 as a double


% --- Executes during object creation, after setting all properties.
function flowRateP2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flowRateP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addKill.
function addKill_Callback(hObject, eventdata, handles)
% hObject    handle to addKill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pointsTable,'Enable','on');%Make sure the table is activated (won't be if this is the first point to be defined)
nPoints=size(handles.acquisition.points,1);%number of points previously defined
%define a default group (the group of the previous point +1 if there is one,
%otherwise 1)
if nPoints>0
    group=cell2mat(handles.acquisition.points(nPoints,6))+1;
else%this is the first point defined. Set group to 1 and also initialise the column headings (based on the chosen channels)
    group=1;
    headings={'Name','x (microns)','y (microns)','z (microns)', 'PFS offset', 'Group'};
    numChannels=size(handles.acquisition.channels,1);
    editable=[true true true true true true];
    for ch=1:numChannels
        headings(6+ch)=strcat(handles.acquisition.channels(ch,1),'(ms)');
        editable(6+ch)=true;
    end
    set(handles.pointsTable,'ColumnName',headings);
    set(handles.pointsTable,'ColumnEditable',editable);
end
%Generate a default name and make sure this name hasn't already been taken
number=nPoints+1;
defName=strcat('kill',num2str(number));%generate default point name
nameOK=0;
while nameOK==0
    usename=1;
    for n=1:nPoints
        name=char(handles.acquisition.points(n));
        if strcmp(name,defName)==1
            usename=0;
        end
    end
    if usename==1
        nameOK=1;
    else
        number=number+1;
        defName=strcat('kill',num2str(number));%generate default point name
    end
end

[x y z PFS]=handles.acquisition.microscope.definePoint;%call to function that gets position data from scope
handles.acquisition.points((nPoints+1),1:6)={defName,x,y,z,PFS,group};%add data to acquisition data
%The first 6 columns of the points table have been defined. The remaining
%columns are exposure times, one for each channel. Need the channels
%selected and default exposure times.
numChannels=size(handles.acquisition.channels,1);
killPresent=false;
for ch=1:numChannels
    if strcmp(handles.acquisition.channels{ch,1},'Kill')
        handles.acquisition.points(nPoints+1,6+ch)={num2str(5000)};%5s exposure for killing cells
        killPresent=true;
    else
        %Set exposure times for all other channels to zero
        handles.acquisition.points(nPoints+1,6+ch)={num2str(0)};%this has to be a string - will allow entries other than numbers - eg 'double' for a double exposure to test bleaching
    end
end
if ~killPresent
    %Add an entry to the channels array
    handles.acquisition.channels(numChannels+1,1)={'Kill'};
    handles.acquisition.channels{numChannels+1,2}=0;%default exposure time
    handles.acquisition.channels{numChannels+1,4}=0;%No z sectioning
    handles.acquisition.channels{numChannels+1,3}=1;%No timepoint skipping
    handles.acquisition.channels{numChannels+1,5}=1;%Start at tp1
    handles.acquisition.channels{numChannels+1,6}=2;%CCD camera mode
    handles.acquisition.channels{numChannels+1,7}=1;%EM gain
    handles.acquisition.channels{numChannels+1,8}=1;%EPG
    %Complete the points array
    handles=updatePoints(handles);%This will add an extra column for the kill channel
    handles.acquisition.points{nPoints+1,end}=num2str(5000);%5s exposure for killing cells
end   





set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
guidata(hObject, handles);



function expCh8_Callback(hObject, eventdata, handles)
% hObject    handle to expCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expCh8 as text
%        str2double(get(hObject,'String')) returns contents of expCh8 as a double


%This callback has been written to allow it to be used with any channel
controlName=get(hObject,'Tag');
k=strfind(controlName,'exp');
channelName=controlName(1:k-1);

expos=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),channelName)==1
        handles.acquisition.channels{n,2}=expos;
        end
    end
end
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function expCh8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cammodeCh8.
function cammodeCh8_Callback(hObject, eventdata, handles)
% hObject    handle to cammodeCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cammodeCh8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cammodeCh8


controlName=get(hObject,'Tag');
channelName=controlName(8:end);

%Define names of the tags for the other controls for this channel
zTag=[channelName 'Zsect'];
skipTag=['skip' channelName];
starttpTag=[channelName 'starttp'];
snapTag=['snap' channelName];
cammodeTag=['cammode' channelName];
startgainTag=['startgain' channelName];
epgTag=['epg' channelName];
expTag=[channelName 'exp'];





value=get(hObject,'Value');
switch value
    case 1%EM mode selected
        set(handles.(startgainTag),'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),channelName)==1
                handles.acquisition.channels{n,6}=1;%1=EM camera mode
            end
            end
        end       
    case 2%CCD mode selected
        set(handles.(startgainTag),'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),channelName)==1
                handles.acquisition.channels{n,6}=2;%2=CCD camera mode
            end
            end
        end     
        case 3%EM mode selected
        set(handles.(startgainTag),'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
            if strcmp(handles.acquisition.channels(n,1),channelName)==1
                handles.acquisition.channels{n,6}=3;%3=EM_constant camera mode
            end
            end
        end
    
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function cammodeCh8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cammodeCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startgainCh8_Callback(hObject, eventdata, handles)
% hObject    handle to startgainCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startgainCh8 as text
%        str2double(get(hObject,'String')) returns contents of startgainCh8 as a double

controlName=get(hObject,'Tag');
channelName=controlName(10:end);

startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
   if nChannels~=0
      for n=1:nChannels
           if strcmp(handles.acquisition.channels(n,1),channelName)==1
                handles.acquisition.channels{n,7}=startgain;
           end
      end
   end       
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function startgainCh8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startgainCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voltCh8_Callback(hObject, eventdata, handles)
% hObject    handle to voltCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voltCh8 as text
%        str2double(get(hObject,'String')) returns contents of voltCh8 as a double


% --- Executes during object creation, after setting all properties.
function voltCh8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ZsectCh8.
function ZsectCh8_Callback(hObject, eventdata, handles)
% hObject    handle to ZsectCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ZsectCh8


controlName=get(hObject,'Tag');
k=strfind(controlName,'Zsect');
channelName=controlName(1:k-1);

if get(hObject,'Value')==1%make sure z sectioning controls are enabled
                          %and record that z sectioning is being done for
                          %this channel in the handles.acquisition.channels cell array
                          %also get the z sectioning values from the gui
                          %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),channelName)==1
            handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),channelName)==1
            handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
            anyZ=1;
            end
        end
    end
    if anyZ==0
       set(handles.nZsections,'Enable','off');
       set(handles.zspacing,'Enable','off');
%        set(handles.nZsections,'String','1');
%        set(handles.zspacing,'String','0');
       handles.acquisition.z(1)=1;
       handles.acquisition.z(2)=0;
    end
end
updateDiskSpace(handles);
  guidata(hObject, handles);

function starttpCh8_Callback(hObject, eventdata, handles)
% hObject    handle to starttpCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of starttpCh8 as text
%        str2double(get(hObject,'String')) returns contents of starttpCh8 as a double


% --- Executes during object creation, after setting all properties.
function starttpCh8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttpCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in snapCh8.
function snapCh8_Callback(hObject, eventdata, handles)
% hObject    handle to snapCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of snapCh8
controlName=get(hObject,'Tag');
channelName=controlName(5:end);
%Define names of the tags for the other controls for this channel
zTag=[channelName 'Zsect'];
skipTag=['skip' channelName];
starttpTag=[channelName 'starttp'];
snapTag=['snap' channelName];
cammodeTag=['cammode' channelName];
startgainTag=['startgain' channelName];
epgTag=['volt' channelName];
expTag=[channelName 'exp'];

channel={};
channel(1)=cellstr(channelName);
channel(2)=num2cell(str2double(get(handles.(expTag),'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.(cammodeTag),'Value'));
channel(7)=num2cell(str2double(get(handles.(startgainTag),'String')));
channel(8)=num2cell(str2double(get(handles.(epgTag),'String')));

    snap(channel);
set(handles.(controlName),'Value',0);



% --- Executes on button press in useCh8.
function useCh8_Callback(hObject, eventdata, handles)
% hObject    handle to useCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE - this callback has been written to allow use of any channel - when
%it's tested can redirect all use channel buttons to this one - will make
%it easier to make changes and debug. Need to make sure all the tags on all
%the controls are compatible before doing that.

channelName=get(hObject,'String');
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
%Define names of the tags for the other controls for this channel
zTag=[channelName 'Zsect'];
skipTag=['skip' channelName];
starttpTag=[channelName 'starttp'];
snapTag=['snap' channelName];
cammodeTag=['cammode' channelName];
startgainTag=['startgain' channelName];
voltTag=['volt' channelName];
expTag=[channelName 'exp'];

if get(hObject,'Value')==1 
    %Button has been clicked on
    if get(handles.(zTag),'Value')==1
       set(handles.nZsections,'Enable','on');   
       set(handles.zspacing,'Enable','on');
    end
    set(handles.(skipTag),'Enable','on');
    set(handles.(voltTag),'Enable','on');
    set(handles.(zTag),'Enable','on');
    set(handles.(starttpTag),'Enable','on');
    set(handles.(snapTag),'Enable','on');
    set(handles.(cammodeTag),'Enable','on');
    %camera settings - enable controls
    set(handles.(cammodeTag),'Enable','on');
    if get(handles.(cammodeTag),'Value')==1%channel set to camera EM mode
        set (handles.(startgainTag),'Enable','on');
        set (handles.(voltTag),'Enable','on');
    end 
    set(handles.(expTag),'Enable','on');
    handles.acquisition.channels{nChannels+1,1}=channelName;
    handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.(expTag),'String'));
    handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.(skipTag),'String'));
    handles.acquisition.channels{nChannels+1,4}=get(handles.(zTag),'Value');
    handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.(starttpTag),'String'));
   %camera settings
   handles.acquisition.channels{nChannels+1,6}=get(handles.(cammodeTag),'Value');
   handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.(startgainTag),'String'));
   if isempty(handles.acquisition.channels(nChannels+1,7));
       handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
   end%
      handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.(voltTag),'String')));
   %update the points list (if there is one) - add a column for exposure times for this channel
   if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
   end
else
    %Inactivate other controls for this channel
    set(handles.(expTag),'Enable','off');
    set(handles.(skipTag),'Enable','off');
    set(handles.(zTag),'Enable','off');
    set(handles.(starttpTag),'Enable','off');
    set(handles.(snapTag),'Enable','off');
    set(handles.(cammodeTag),'Enable','off');
    set(handles.(startgainTag),'Enable','off');
    set(handles.(voltTag),'Enable','off');
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it. And also records if any channel does sectioning.
            if strcmp(char(handles.acquisition.channels(n,1)),channelName)==1
            delnumber=n;
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
    handles.acquisition.channels(delnumber,:)=[];
    if anyZ==0%deactivate z settings choices if no channel is using z
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
    end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);



function skipCh8_Callback(hObject, eventdata, handles)
% hObject    handle to skipCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skipCh8 as text
%        str2double(get(hObject,'String')) returns contents of skipCh8 as a double

controlName=get(hObject,'Tag');
channelName=controlName(5:end);

skip=str2double(get(hObject,'String'));   
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),channelName)==1
        handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function skipCh8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skipCh8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in shiftLeft.
function shiftLeft_Callback(hObject, eventdata, handles)
% hObject    handle to shiftLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shiftLeft


% --- Executes on button press in shiftRight.
function shiftRight_Callback(hObject, eventdata, handles)
% hObject    handle to shiftRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shiftRight


% --- Executes on button press in shiftUp.
function shiftUp_Callback(hObject, eventdata, handles)
% hObject    handle to shiftUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shiftUp


% --- Executes on button press in shiftDown.
function shiftDown_Callback(hObject, eventdata, handles)
% hObject    handle to shiftDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shiftDown



function distanceBox_Callback(hObject, eventdata, handles)
% hObject    handle to distanceBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distanceBox as text
%        str2double(get(hObject,'String')) returns contents of distanceBox as a double

input=str2double(get(hObject,'String'));
if ~isempty(input)
    if input<200
        handles.distance=input;
    else
        set(handles.distanceBox,'String',num2str(handles.distance));
    end
else
    %a number was not input
   set(handles.distanceBox,'String',num2str(handles.distance));
end
guidata(hObject,handles);

function nudge_Callback (hObject, eventdata, handles)
tag=get(hObject,'Tag');
global mmc
set(handles.(tag),'Value',0);%Unpress the button
switch tag
    case 'shiftLeft'
        mmc.setRelativeXYPosition('XYStage',-handles.distance,0);
    case 'shiftRight'
        mmc.setRelativeXYPosition('XYStage',handles.distance,0);
    case 'shiftUp'
        mmc.setRelativeXYPosition('XYStage',0,-handles.distance);
    case 'shiftDown'
        mmc.setRelativeXYPosition('XYStage',0,handles.distance);

end



% --- Executes during object creation, after setting all properties.
function distanceBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function changeVoltage_Callback (hObject, eventdata, handles)
%Callback for all edit boxes changing the voltage applied across the
%relevant LED for a channel

[chanName tagEnd]=getChannel(hObject,handles);
tag=get(hObject,'tag');
%Find which row represents the current channel
%cell array
channelRow=strcmp(handles.acquisition.channels,chanName);
channelRow=channelRow(:,1);
%Get the old value for the voltage - can then reset if the input is not
%usable
oldValue=handles.acquisition.channels{channelRow,8};
%Get the input value
input=get(hObject,'String');
input=str2num(input);
ok=false;
if ~isempty(input)
    if input>0 && input<=4
       ok=true;
       handles.acquisition.channels{channelRow,8}=input;
    end
end
if ~ok
   set(handles.(tag),'String', num2str(oldValue)); 
end

guidata(hObject,handles);


% --- Executes on button press in live.
function live_Callback(hObject, eventdata, handles)
% hObject    handle to live (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gui;
if gui.isLiveModeOn
gui.enableLiveMode(0);
set(handles.live,'String','Live');
set(handles.live,'BackgroundColor',[0.2 .9 0.2]);
else
gui.enableLiveMode(1);
set(handles.live,'String','Stop Live');
set(handles.live,'BackgroundColor',[.9 0.2 0.2]);
end



    
    


% --- Executes on button press in liveDIC.
function liveDIC_Callback(hObject, eventdata, handles)
%Starts the live mode of the micromanager gui running after setting
%microscope for DIC acquisition.


global gui;
global mmc;
switch handles.acquisition.microscope.Name
    case 'Batman'
        mmc.setProperty('Evolve','Port','Normal');
end
if gui.isLiveModeOn
gui.enableLiveMode(0);
set(handles.liveDIC,'String','Live');
set(handles.live,'BackgroundColor',[.15 0.23 0.37]);
else
mmc.setConfig('Channel', handles.acquisition.microscope.InitialChannel);
mmc.waitForConfig('Channel', handles.acquisition.microscope.InitialChannel);
gui.enableLiveMode(1);
set(handles.live,'String','Stop Live');
set(handles.liveDIC,'BackgroundColor',[0.2 .9 0.2]);
end



function voltCh1_Callback(hObject, eventdata, handles)
% hObject    handle to voltCh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voltCh1 as text
%        str2double(get(hObject,'String')) returns contents of voltCh1 as a double


% --- Executes on button press in selectChannels.
function selectChannels_Callback(hObject, eventdata, handles)
%Code to select channels to include when there are too many valid ones to
%fit on the screen


% --- Executes on selection change in zMethod.
function zMethod_Callback(hObject, eventdata, handles)
% hObject    handle to zMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
input=contents{get(hObject,'Value')};

switch input
    case 'PIFOC'
        handles.acquisition.z(6)=1;
    case 'PIFOC with PFS on'
         handles.acquisition.z(6)=2;
    case 'PFS'
         handles.acquisition.z(6)=3;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function zMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refreshDiskSpace.
function refreshDiskSpace_Callback(hObject, eventdata, handles)
% hObject    handle to refreshDiskSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.freeDisk=checkDiskSpace;
set(handles.GbFree,'String',num2str(handles.freeDisk));
updateDiskSpace(handles);
guidata(hObject,handles);


function bin_Callback(hObject, eventdata, handles)
%Callback for user setting the camera bin

% Hints: get(hObject,'String') returns contents of voltCh1 as text
%        str2double(get(hObject,'String')) returns contents of voltCh1 as a double
menu=get(hObject,'String');
bin=menu{get(hObject,'Value')};
handles.acquisition.imagesize=handles.acquisition.microscope.getImageSize(bin);
imSizeString=[num2str(handles.acquisition.imagesize(1)) 'x' num2str(handles.acquisition.imagesize(2))];
set(handles.imagesize,'String', imSizeString);

handles.acquisition.microscope.setBin(bin);


guidata(hObject,handles);


