%Initializing script for the programmatic GUI.

addpath(genpath('./Programmatic GUI'));

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

%Add necessary folders to path
addpath(['.' filesep 'transitionGUI']);



%Make sure micromanager files are on the path
if ismac
   disp('Initializing micromanager path for mac');
   macMMPath;
else
   fprintf('<a href=""> Initializing micromanager path for pc... </a>\n')
   pcMMPath;
end
 
%Show warning if running from the shared, public folder
if strcmp(pwd,'C:\Users\Public\Microscope Control');
    msgbox('MultiDGUI is running from the shared Microscope Control folder - please do not edit this version of the software!','Running shared software','Warn');
end

%Find out if an mmc and gui object have been initialised - if so can
%activate the eyepiece and camera buttons and inactivate the launch
%micromanager button
isthereagui=exist ('gui','var');
global gui;
if isthereagui~=1
    fprintf('<a href=""> Starting Micro-manager. Ignore TextCanvas error message </a>\n')
    fprintf('<a href=""> Select (none) when asked to choose configuration file </a>\n')


    guiconfig;
end
    fprintf('<a href=""> Creating the GUI... </a>\n')
%Create the GUI
handles=multiDGUI2;
%Get computer name
[idum,hostname]= system('hostname');
%Create microscope object - details will depend on which computer is
%running this
handles.acquisition.microscope=chooseScope;

%Get free disk space
handles.freeDisk=checkDiskSpace(handles.acquisition.microscope.DataPath(1:2));
set(handles.GbFree,'String',num2str(handles.freeDisk));

%If there is a last saved acquisition file then load the acquisition
%settings from that. Points are not loaded.
%First get the file name of the last saved acquisition:
user=getenv('USERNAME');
[root user]=makeRoot(user, handles.acquisition.microscope);%this provides a root directory based on the name and date
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
        p1=pump(handles.acquisition.microscope.pumpComs(1).com,handles.acquisition.microscope.pumpComs(1).baud);p2=pump(handles.acquisition.microscope.pumpComs(2).com,handles.acquisition.microscope.pumpComs(2).baud);
        handles.acquisition.flow={'2% raffinose in SC' '2% galactose in SC' 1 [p1 p2],flowChanges({p1, p2})};
        %info entry is already initialised above
    end
else%If there is no file containing the path of a last saved acquisition the initialise with defaults
handles.acquisition.channels={};
handles.acquisition.z=[1 0 0 0 0 2]; 
handles.acquisition.time=[0 300 180 54000];
p1=pump(handles.acquisition.microscope.pumpComs(1).com,handles.acquisition.microscope.pumpComs(1).baud);p2=pump(handles.acquisition.microscope.pumpComs(2).com,handles.acquisition.microscope.pumpComs(2).baud);
handles.acquisition.flow={'2% raffinose in SC' '2% galactose in SC' 1 [p1 p2],flowChanges({p1, p2})};
%info entry is already initialised above
end
set(handles.live,'BackgroundColor',[0.2 .9 0.2]);
%Open serial ports of the pumps
for i=1:length(handles.acquisition.flow{5}.pumps)
    try
    fopen(handles.acquisition.flow{5}.pumps{i}.serial);
    catch
        errordlg(['Failed to connect to pump' num2str(i) '. This pump must be manually controlled if in use'],'Pump connection');
    end
end
%Initialise the list of points. This is not retrieved from the last saved
%acquisition
handles.acquisition.points={};



%Initialise the user list - only need to edit the getUsers.m function when
%a new user is added
[swain tyers millar]=getUsers;
users=[swain tyers millar];

%Initialize the Omero projects and tags lists
%First get Omero info and set path
addpath(genpath(handles.acquisition.microscope.OmeroCodePath));
load([handles.acquisition.microscope.OmeroInfoPath 'dbInfoSkye.mat']);

handles.aquisition.omero=struct('project',{}, 'tags',{}, 'object',{});
handles.acquisition.omero.object=obj2;


%Display the projects
proj=handles.acquisition.omero.object.getProjectNames;
%Sort alphabetically (case insensitive, hence use of upper)
[sorted, indices]=sort(upper(proj));
proj=proj(indices);
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
%Sort alphabetically (case insensitive, hence use of upper)
[sorted, indices]=sort(upper(tags));
tags=tags(indices);
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
set(handles.gui, 'Name', ['Swain Lab Microscope: Multi Dimensional Acquisition ' b]);
set(handles.gui, 'NumberTitle','off');

set(handles.rootName,'String',handles.acquisition.info(3));
set(handles.pointsTable,'Data',handles.acquisition.points);



% Update handles structure
guidata(handles.gui, handles);
