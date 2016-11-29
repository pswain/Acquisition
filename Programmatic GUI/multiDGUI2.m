function handles=multiDGUI2
%Code to make programmatic gui figure for multiDGUI


%Set up a structure to hold the acquisition parameters.
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
%Column 4 - total time (54000s (15hr) defaulted)

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
%Column 6 - 1 if pumps are to be switched off at the end of the experiment, 0 if not.


%Experimental information
%info. Cell array
%Column 1 - experiment name
%Column 2 - user name
%Column 3 - root for folder to save files
%Column 4 - Experiment description/aims
%Column 5 - object of class switches



%GUI height should be relatively larger on Robin and Batgirl, which have lower resolution monitors.
pix_ss=get(0,'screensize');
if pix_ss(3)<1700
    figPos=[0.2444 0.0700 0.7175 0.8144];
else
    figPos=[0.2444 0.1700 0.7175 0.7144];
end

handles.gui=figure('Units','normalized','Position',figPos,'CloseRequestFcn',@closeGUIFunction,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Swain lab multi dimensional acquisition software');

%Set the panels
handles.experimentPanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','Experiment','Position',[.005 .885 .967 .114],'FontWeight','Bold','FontSize',16);
handles.channelPanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','Channels','Position',[0.005    0.4590    0.6220    0.4210],'FontWeight','Bold','FontSize',16);
handles.pointPanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','Point visiting','Position',[.005 .175 .53 .283],'FontWeight','Bold','FontSize',16);
handles.micPanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','Microscope control','Position',[.005 .027 .53 .145],'FontWeight','Bold','FontSize',16);
%handles.specialPanel=uipanel('Parent',handles.gui,'Title','Special tasks','Position',[.019 .027 .779 .061],'FontWeight','Bold','FontSize',16);
handles.zPanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','Z sectioning','Position',[.645 .772 .206 .108],'FontWeight','Bold','FontSize',16);
handles.timePanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','Time settings','Position',[.645 .464 .206 .308],'FontWeight','Bold','FontSize',16);
handles.newsPanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','News','Position',[.86 .465 .126 .417],'FontWeight','Bold','FontSize',16);
handles.flowPanel=uipanel('Parent',handles.gui,'BackgroundColor',[0.8 0.8 0.8],'Title','Flow control','Position',[.558 .175 .427 .283],'FontWeight','Bold','FontSize',16);

%Controls in experiment panel
handles.exptName=uicontrol('Style','edit','Parent',handles.experimentPanel,'Units','Normalized','Position',[.006 .65 .158 .288],'String','exp','BackgroundColor','w','Callback',@exptName_Callback,'TooltipString','Enter experiment name');
handles.enterDetails=uicontrol('Style','pushbutton','Parent',handles.experimentPanel,'Units','Normalized','Position',[.007 .088 .157 .418],'String','Enter details','BackgroundColor','w','TooltipString','Record details of you experiment - eg aim, strain used etc. Entries will be written into the log file.','Callback',@enterDetails_Callback);
handles.text1=uicontrol('Style','text','Parent',handles.experimentPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.177 .85 .135 .202],'String','Files will be saved in:');
handles.OmeroProjects=uicontrol('Style','popupmenu','Parent',handles.experimentPanel,'Units','Normalized','Position',[.172 .059 .184 .361],'String','Project menu','TooltipString','Choose an Omero project for your experiment','Callback',@OmeroProjects_Callback);
handles.OmeroTags=uicontrol('Style','pushbutton','Parent',handles.experimentPanel,'Units','Normalized','Position',[.358 .059 .184 .361],'String','Tags dialog','TooltipString','Choose Omero Tags for your experiment','Callback',@OmeroTags_Callback);
handles.removeTag=uicontrol('Style','pushbutton','Parent',handles.experimentPanel,'Units','Normalized','Position',[.546 .102 .071 .32],'String','Remove tag','TooltipString','Click to remove selected tag from your experiment','Callback',@removeTag_Callback,'BackgroundColor','w');
handles.TagList=uicontrol('Style','listbox','Parent',handles.experimentPanel,'Units','Normalized','Position',[.621 .101 .228 .62],'String','TagList','TooltipString','List of the Omero tags that will be applied to this experiment','FontWeight','Bold','FontSize',10,'BackgroundColor','w','Callback',@TagList_Callback);
handles.micNameIcon=axes('Parent', handles.experimentPanel,'Units','Normalized','Position',[.902 .101 .069 .923]);
handles.Project=uicontrol('Style','text','Parent',handles.experimentPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.62 .692 .229 .346],'String','Default project','FontWeight','Bold','FontSize',10);
handles.TagList=uicontrol('Style','listbox','Parent',handles.experimentPanel,'Units','Normalized','FontSize',8,'Position',[.621 .101 .228 .62],'String','TagList','TooltipString','List of the Omero tags that will be applied to this experiment','FontWeight','Bold','FontSize',10);
handles.rootName=uicontrol('Style','text','Parent',handles.experimentPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.185 .6 .4 .202],'String','Save path goes here');

%Controls in channels panel
%Text headings
handles.text11=uicontrol('Style','text','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.156 .894 .12 .099],'String','Exposure(ms)','FontSize',10,'HorizontalAlignment','Center');
handles.text13=uicontrol('Style','text','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.258 .894 .142 .099],'String','Skip','FontSize',10,'HorizontalAlignment','Center');
handles.text42=uicontrol('Style','text','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.395 .873 .096 .12],'String','Camera mode','FontSize',10,'HorizontalAlignment','Center');
handles.text43=uicontrol('Style','text','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.52 .873 .096 .12],'String','Starting gain','FontSize',10,'HorizontalAlignment','Center');
handles.text44=uicontrol('Style','text','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.622 .873 .096 .12],'String','LED Voltage','FontSize',10,'HorizontalAlignment','Center');
handles.text25=uicontrol('Style','text','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.7 .873 .096 .108],'String','Z stack?','FontSize',10,'HorizontalAlignment','Center');
handles.text26=uicontrol('Style','text','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.779 .873 .12 .108],'String','Starting timepoint','FontSize',10,'HorizontalAlignment','Center');
%Use channel buttons
handles.useCh1=uicontrol('Tag','useCh1','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .80 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
handles.useCh2=uicontrol('Tag','useCh2','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .6926 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
handles.useCh3=uicontrol('Tag','useCh3','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .5855 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
handles.useCh4=uicontrol('Tag','useCh4','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .4784 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
handles.useCh5=uicontrol('Tag','useCh5','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .3713 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
handles.useCh6=uicontrol('Tag','useCh6','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .2642 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
handles.useCh7=uicontrol('Tag','useCh7','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .1571 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
handles.useCh8=uicontrol('Tag','useCh8','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .05 .13 .08],'String','Use Channel','Callback',@useChannel_Callback);
%Exposure times
handles.expCh1=uicontrol('Tag','expCh1','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .80 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh2=uicontrol('Tag','expCh2','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .6926 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh3=uicontrol('Tag','expCh3','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .5855 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh4=uicontrol('Tag','expCh4','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .4784 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh5=uicontrol('Tag','expCh5','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .3713 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh6=uicontrol('Tag','expCh6','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .2642 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh7=uicontrol('Tag','expCh7','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .1571 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh8=uicontrol('Tag','expCh8','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .05 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
%Skip
handles.skipCh1=uicontrol('Tag','skipCh1','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .80 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh2=uicontrol('Tag','skipCh2','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .6926 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh3=uicontrol('Tag','skipCh3','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .5855 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh4=uicontrol('Tag','skipCh4','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .4784 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh5=uicontrol('Tag','skipCh5','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .3713 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh6=uicontrol('Tag','skipCh6','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .2642 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh7=uicontrol('Tag','skipCh7','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .1571 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh8=uicontrol('Tag','skipCh8','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .05 .048 .08],'String','1','BackgroundColor','w','Callback',@skipChannel_Callback,'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
%Camera mode menu
handles.cammodeCh1=uicontrol('Tag','cammodeCh1','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .81 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh2=uicontrol('Tag','cammodeCh2','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .6926 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh3=uicontrol('Tag','cammodeCh3','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .5852 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh4=uicontrol('Tag','cammodeCh4','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .4778 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh5=uicontrol('Tag','cammodeCh5','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .3704 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh6=uicontrol('Tag','cammodeCh6','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .2630 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh7=uicontrol('Tag','cammodeCh7','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .1556 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh8=uicontrol('Tag','cammodeCh8','Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .0482 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',8,'Callback',@cammodeChannel_Callback,'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
%Starting gain
handles.startgainCh1=uicontrol('Tag','startgainCh1','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .80 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh2=uicontrol('Tag','startgainCh2','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .6926 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh3=uicontrol('Tag','startgainCh3','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .5855 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh4=uicontrol('Tag','startgainCh4','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .4784 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh5=uicontrol('Tag','startgainCh5','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .3713 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh6=uicontrol('Tag','startgainCh6','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .2642 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh7=uicontrol('Tag','startgainCh7','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .1571 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh8=uicontrol('Tag','startgainCh8','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .05 .078 .08],'String','270','BackgroundColor','w','Callback',@startgainChannel_Callback,'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
%LED voltage
handles.voltCh1=uicontrol('Tag','voltCh1','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .80 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');
handles.voltCh2=uicontrol('Tag','voltCh2','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .6926 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');
handles.voltCh3=uicontrol('Tag','voltCh3','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .5855 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');
handles.voltCh4=uicontrol('Tag','voltCh4','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .4784 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');
handles.voltCh5=uicontrol('Tag','voltCh5','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .3713 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');
handles.voltCh6=uicontrol('Tag','voltCh6','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .2642 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');
handles.voltCh7=uicontrol('Tag','voltCh7','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .1571 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');
handles.voltCh8=uicontrol('Tag','voltCh8','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .05 .048 .08],'String','1','BackgroundColor','w','Callback',@changeVoltage_Callback,'TooltipString','Voltage applied to LED during exposure');

%Z section
handles.ZsectCh1=uicontrol('Tag','ZsectCh1','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .808 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh2=uicontrol('Tag','ZsectCh2','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .7006 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh3=uicontrol('Tag','ZsectCh3','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .5932 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh4=uicontrol('Tag','ZsectCh4','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .4858 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh5=uicontrol('Tag','ZsectCh5','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .3784 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh6=uicontrol('Tag','ZsectCh6','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .2710 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh7=uicontrol('Tag','ZsectCh7','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .1636 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh8=uicontrol('Tag','ZsectCh8','Style','checkbox','Parent',handles.channelPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.73 .0562 .024 .067],'Callback',@ZsectChannel_Callback,'TooltipString','Select if you want this channel to do Z sectioning');
%Starting timepoint
handles.starttpCh1=uicontrol('Tag','starttpCh1','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .80 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
handles.starttpCh2=uicontrol('Tag','starttpCh2','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .6926 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
handles.starttpCh3=uicontrol('Tag','starttpCh3','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .5855 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
handles.starttpCh4=uicontrol('Tag','starttpCh4','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .4784 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
handles.starttpCh5=uicontrol('Tag','starttpCh6','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .3713 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
handles.starttpCh6=uicontrol('Tag','starttpCh7','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .2642 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
handles.starttpCh7=uicontrol('Tag','starttpCh8','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .1571 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
handles.starttpCh8=uicontrol('Tag','starttpCh9','Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .05 .048 .08],'String','1','BackgroundColor','w','Callback',@starttpChannel_Callback,'TooltipString','Timepoint to start imaging');
%Snap buttons
handles.snapCh1=uicontrol('Tag','snapCh1','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .80 .065 .061],'String','Snap','Callback',@snap_Callback);
handles.snapCh2=uicontrol('Tag','snapCh2','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .6926 .065 .061],'String','Snap','Callback',@snap_Callback);
handles.snapCh3=uicontrol('Tag','snapCh3','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .5855 .065 .061],'String','Snap','Callback',@snap_Callback);
handles.snapCh4=uicontrol('Tag','snapCh4','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .4784 .065 .061],'String','Snap','Callback',@snap_Callback);
handles.snapCh5=uicontrol('Tag','snapCh5','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .3713 .065 .061],'String','Snap','Callback',@snap_Callback);
handles.snapCh6=uicontrol('Tag','snapCh6','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .2642 .065 .061],'String','Snap','Callback',@snap_Callback);
handles.snapCh7=uicontrol('Tag','snapCh7','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .1571 .065 .061],'String','Snap','Callback',@snap_Callback);
handles.snapCh8=uicontrol('Tag','snapCh8','Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .05 .065 .061],'String','Snap','Callback',@snap_Callback);

%Controls in Z sectioning panel
%Text headings
handles.text23=uicontrol('Style','text','Parent',handles.zPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[0.400 0.5000 0.300 0.3580],'String','Num sections','FontSize',8,'HorizontalAlignment','Center');
handles.text22=uicontrol('Style','text','Parent',handles.zPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.72 .5 .2 .358],'String','z spacing','FontSize',8,'HorizontalAlignment','Center');
handles.text32=uicontrol('Style','text','Parent',handles.zPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.93 .179 .04 .193],'String','m','FontSize',8,'FontName','Symbol','HorizontalAlignment','Center');
handles.text33=uicontrol('Style','text','Parent',handles.zPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.96 .179 .04 .193],'String','m','FontSize',8,'FontName','Helvetica','HorizontalAlignment','Center');
handles.text2=uicontrol('Style','text','Parent',handles.zPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.02 .5 .4 .358],'String','Sectioning method','FontSize',8,'HorizontalAlignment','Center');
%Controls
handles.nZsections=uicontrol('Style','edit','Parent',handles.zPanel,'Units','Normalized','Position',[0.425    0.2    .238   0.276],'String','1','BackgroundColor','w','Callback',@nZsections_Callback,'TooltipString','Number of sections');
handles.zspacing=uicontrol('Style','edit','Parent',handles.zPanel,'Units','Normalized','Position',[0.700    0.2    .238   0.276],'String','1','BackgroundColor','w','Callback',@zspacing_Callback,'TooltipString','Spacing between sections in micrometres');
handles.zMethod=uicontrol('Style','popupmenu','Parent',handles.zPanel,'Units','Normalized','Position',[0.0400    0.3000    0.35000    0.2],'String',{'PIFOC';'PIFOC with PFS on'},'FontSize',8,'Callback',@zMethod_Callback,'TooltipString','Batman only: Choose method used for Z sectioning - note exact Z positions will not be known with PIFOC with PFS on method');

%Time settings panel
handles.doTimelapse=uicontrol('Style','radiobutton','Value',1,'BackgroundColor',[0.8 0.8 0.8],'Parent',handles.timePanel,'Units','Normalized','Position',[.098 .862 .732 .094],'String','Time lapse?','FontSize',10,'HorizontalAlignment','Center','Callback',@doTimelapse_Callback);
handles.text18=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.088 .732 .298 .106],'String','Time interval','FontSize',10,'HorizontalAlignment','Left');
handles.interval=uicontrol('Style','edit','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .691 .332 .081],'String','5','BackgroundColor','w','Callback',@interval_Callback,'TooltipString','Interval between time points');
handles.units=uicontrol('Style','popupmenu','Parent',handles.timePanel,'Units','Normalized','Position',[.429 .691 .3 .081],'String',{'s';'min';'hr'},'Value',2,'FontSize',10,'Callback',@units_Callback,'TooltipString','Set units for time interval');
handles.text20=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.088 .512 .561 .106],'String','Number of time points','FontSize',10,'HorizontalAlignment','Left');
handles.nTimepoints=uicontrol('Style','edit','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .472 .332 .081],'String','1','BackgroundColor','w','Callback',@nTimepoints_Callback,'TooltipString','Number of time points');
handles.text21=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.088 .338 .561 .106],'String','Total time','FontSize',10,'HorizontalAlignment','Left');
handles.totaltime=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.088 .297 .332 .081],'String','0','FontSize',10,'HorizontalAlignment','Left','BackgroundColor','w');
handles.unitsTotal=uicontrol('Style','popupmenu','Parent',handles.timePanel,'Units','Normalized','Position',[.429 .297 .3 .081],'String',{'s';'min';'hr'},'FontSize',10,'Callback',@unitsTotal_Callback,'TooltipString','Set units for time interval','Value',3);
handles.GbFree=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.15 0.05 .254 .107],'String','Free space','FontSize',10,'HorizontalAlignment','Left','FontWeight','Bold');
handles.freeSpaceText=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[0.014 0.187 0.45 0.057],'String','Free space (Gb)');
handles.text56=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.493 .187 .41 .057],'String','Space needed (Gb)');
handles.GbReqd=uicontrol('Style','text','Parent',handles.timePanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[0.520 0.0500 0.4 0.1070],'String','Space needed','FontSize',10,'HorizontalAlignment','Left','FontWeight','Bold');
handles.refreshDisk=uicontrol('Tag','useCh1','Style','pushbutton','Parent',handles.timePanel,'Units','Normalized','Position',[.5 .86 .4 .08],'String','Refresh free space','Callback',@refreshDisk_Callback);



%News panel
news='Check microscope-specific news after you click Start microscope.';
handles.news=uicontrol('Style','text','Parent',handles.newsPanel,'Units','Normalized','Position',[.056 .024 .872 .956],'String',news,'FontSize',10,'HorizontalAlignment','Center','BackgroundColor','w');

%Point visiting panel
columnEditable=logical([1 1 1 1 1 1 0]);
columnName={'Name';'x (microns)';'y (microns), ';'z drive position (microns)';'PFS Offset';'Group';''};
columnWidth={80,65,65,'auto','auto', 'auto', 'auto'};
handles.pointsTable=uitable('Parent',handles.pointPanel,'ColumnName',columnName,'ColumnWidth',columnWidth,'Units','Normalized','Position',[.013 .236 .955 .713],'FontSize',10,'TooltipString','NB: If using the PFS make sure it is on and set the focus (z) position using the PFS offset wheel (not the microscope focus wheel) before marking the point. For a double exposure to monitor bleaching type "double" in the exposure field and add this point to the group to which it refers.','CellEditCallback',@pointsTable_CellEditCallback,'CellSelectionCallback',@pointsTable_CellSelectionCallback);
handles.markPoint=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.011 .071 .138 .147],'String','Mark point','TooltipString','Click to add current position to the points list','Callback',@markPoint_Callback);
handles.deletePoint=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.159 .071 .138 .147],'String','Delete point','TooltipString','Click to delete selected point','Callback',@deletePoint_Callback);
handles.clearList=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.307 .071 .138 .147],'String','Clear list','TooltipString','Click to delete all marked points','Callback',@clearList_Callback);
handles.visit=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.454 .071 .092 .147],'String','Visit','TooltipString','Click to visit selected point','Callback',@visit_Callback);
handles.replace=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.551 .071 .107 .147],'String','Replace','TooltipString','Click to replace selected point with the current position','Callback',@replace_Callback);
handles.makeTile=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.669 .071 .107 .147],'String','Tile','TooltipString','Click to define a regular rectangular array of points','Callback',@makeTile_Callback);
handles.saveList=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.798 .071 .093 .147],'String','Save','TooltipString','Click to save current points list','Callback',@saveList_Callback);
handles.loadList=uicontrol('Style','pushbutton','Parent',handles.pointPanel,'Units','Normalized','Position',[.895 .071 .093 .147],'String','Load','TooltipString','Click to load a points list','Callback',@loadList_Callback);
%Microscope control panel
handles.loadConfig=uicontrol('Style','pushbutton','Parent',handles.micPanel,'Units','Normalized','Position',[.019 .5 .193 .35],'String','Start microscope','TooltipString','Click to initialize microscope','Callback',{@loadConfig_Callback});
handles.eye=uicontrol('Style','pushbutton','Parent',handles.micPanel,'Units','Normalized','Position',[.33 .5 .193 .35],'String','Eyepiece','TooltipString','Switch light path to eyepiece and turn on white light','Callback',@eye_Callback);
handles.camera=uicontrol('Style','pushbutton','Parent',handles.micPanel,'Units','Normalized','Position',[.534 .5 .193 .35],'String','Camera','TooltipString','Switch light path to camera and turn off LEDs','Callback',@camera_Callback);
handles.EM=uicontrol('Style','pushbutton','Parent',handles.micPanel,'Units','Normalized','Position',[.752 .5 .076 .35],'String','EM','TooltipString','Set Evolve camera to EM mode','Callback',@EM_Callback);
handles.CCD=uicontrol('Style','pushbutton','Parent',handles.micPanel,'Units','Normalized','Position',[.852 .5 .076 .35],'String','CCD','TooltipString','Set Evolve camera to CCD mode','Callback',@CCD_Callback);
handles.shiftLeft=uicontrol('Style','pushbutton','Tag','shiftLeft','Parent',handles.micPanel,'Units','Normalized','Position',[.019 .1 .076 .35],'String','Left','TooltipString','Move stage to the left','Callback',@nudge_Callback);
handles.shiftRight=uicontrol('Style','pushbutton','Tag','shiftRight','Parent',handles.micPanel,'Units','Normalized','Position',[.119 .1 .076 .35],'String','Right','TooltipString','Move stage to the right','Callback',@nudge_Callback);
handles.shiftUp=uicontrol('Style','pushbutton','Tag','shiftUp','Parent',handles.micPanel,'Units','Normalized','Position',[.219 .1 .076 .35],'String','Up','TooltipString','Move stage up','Callback',@nudge_Callback);
handles.shiftDown=uicontrol('Style','pushbutton','Tag','shiftDown','Parent',handles.micPanel,'Units','Normalized','Position',[.319 .1 .076 .35],'String','Down','TooltipString','Move stage down','Callback',@nudge_Callback);
handles.distanceBox=uicontrol('Style','edit','Parent',handles.micPanel,'Units','Normalized','Position',[.419 .1 .076 .35],'String','10','BackgroundColor','w','Callback',@distanceBox_Callback,'TooltipString','Distance to shift in microns');
handles.bin=uicontrol('Style','popupmenu','Enable','off','Parent',handles.gui,'Units','Normalized','Position',[0.33    0.045    .05   0.0260],'String',{'1';'2x2';'4x4'},'FontSize',8,'Callback',@bin_Callback,'TooltipString','Set camera bin. If set at >1 the camera will use the signal from a group of pixels to determine the intensity of a single pixel in the image. Gives less resolution but brighter and less noisy images and smaller files.');
handles.bintext=uicontrol('Style','text','Parent',handles.gui,'Units','Normalized','Position',[0.28    0.041    .05   0.0260],'BackgroundColor',[.8 .8 .8],'String','Bin:','FontSize',8);
handles.imagesize=uicontrol('Style','text','Parent',handles.gui,'Units','Normalized','Position',[0.38    0.041    .07   0.0260],'BackgroundColor',[.8 .8 .8],'String','512x512','FontSize',8);


%Pump control panel
handles.text47=uicontrol('Style','text','Parent',handles.flowPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.03 .887 .205 .062],'String','Pump contents','FontSize',10,'HorizontalAlignment','Center','FontWeight','Bold');
handles.text49=uicontrol('Style','text','Parent',handles.flowPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[0.3850    0.8870    0.2050    0.0620],'String','Syringe vol','FontSize',10,'HorizontalAlignment','Center','FontWeight','Bold');
handles.text50=uicontrol('Style','text','Parent',handles.flowPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.598 .887 .18 .062],'String','Rate (ul/min)','FontSize',10,'HorizontalAlignment','Center','FontWeight','Bold');
handles.text51=uicontrol('Style','text','Parent',handles.flowPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.77 .887 .205 .062],'String','Run','FontSize',10,'HorizontalAlignment','Center','FontWeight','Bold');
handles.contentsP1=uicontrol('Style','edit','Parent',handles.flowPanel,'Units','Normalized','Position',[.021 .771 .35 .098],'String','2% raffinose in SC','BackgroundColor','w','Callback',@updateFlowData_Callback,'TooltipString','Enter details of pump 1 media. Will be recorded in experiment log file');
handles.contentsP2=uicontrol('Style','edit','Parent',handles.flowPanel,'Units','Normalized','Position',[.021 .629 .35 .098],'String','2% galactose in SC','BackgroundColor','w','Callback',@updateFlowData_Callback,'TooltipString','Enter details of pump 2 media. Will be recorded in experiment log file');
handles.diameterP1=uicontrol('Style','popupmenu','Parent',handles.flowPanel,'Units','Normalized','Position',[.42 .776 .15 .089],'String',{'3ml';'5ml';'10ml';'20ml';'60ml'},'FontSize',10,'Callback',@diameterP1_Callback,'TooltipString','Select syringe volume. This is essential to ensure the correct flow rate');
handles.diameterP2=uicontrol('Style','popupmenu','Parent',handles.flowPanel,'Units','Normalized','Position',[.42 .638 .15 .089],'String',{'3ml';'5ml';'10ml';'20ml';'60ml'},'FontSize',10,'Callback',@diameterP2_Callback,'TooltipString','Select syringe volume. This is essential to ensure the correct flow rate');
handles.flowRateP1=uicontrol('Style','edit','Parent',handles.flowPanel,'Units','Normalized','Position',[.64 .771 .119 .098],'String','4','BackgroundColor','w','Callback',@updateFlowData_Callback,'TooltipString','Rate of infusion or withdrawal from pump 1');
handles.flowRateP2=uicontrol('Style','edit','Parent',handles.flowPanel,'Units','Normalized','Position',[.64 .629 .119 .098],'String','4','BackgroundColor','w','Callback',@updateFlowData_Callback,'TooltipString','Rate of infusion or withdrawal from pump 2');
handles.runP1=uicontrol('Style','radiobutton','BackgroundColor',[0.8 0.8 0.8],'Parent',handles.flowPanel,'Units','Normalized','Position',[.82 .767 .149 .103],'String','Pump 1','FontSize',10,'HorizontalAlignment','Center','Callback',@updateFlowData_Callback,'TooltipString','Start or stop pump 1');
handles.runP2=uicontrol('Style','radiobutton','BackgroundColor',[0.8 0.8 0.8],'Parent',handles.flowPanel,'Units','Normalized','Position',[.82 .637 .149 .103],'String','Pump 2','FontSize',10,'HorizontalAlignment','Center','Callback',@updateFlowData_Callback,'TooltipString','Start or stop pump 2');
handles.text40=uicontrol('Style','text','Parent',handles.flowPanel,'BackgroundColor',[0.8 0.8 0.8],'Units','Normalized','Position',[.012 .169 .298 .111],'String','Dynamic flow','FontSize',13,'HorizontalAlignment','Center','FontWeight','Bold');
handles.switchMethod=uicontrol('Style','popupmenu','Parent',handles.flowPanel,'Units','Normalized','Position',[.033 .058 .298 .089],'String',{'Enter switch times';'Periodic';'Linear Ramp';'Enter times';'Design flow transition';'Switch Pinch Valves'},'FontSize',10,'Callback',@switchMethod_Callback,'TooltipString','Select method for defining flow changes');
handles.switchParams=uicontrol('Style','pushbutton','Parent',handles.flowPanel,'Units','Normalized','Position',[.347 .058 .253 .098],'String','Switch parameters','TooltipString','Click to change the parameters used by the pumps during media switching','Callback',@switchParams_Callback);
handles.stoppumps=uicontrol('Style','radiobutton','BackgroundColor',[0.8 0.8 0.8],'Parent',handles.flowPanel,'Units','Normalized','Position',[.62 .058 .4 .103],'String','Stop pumps on completion','Value',1,'FontSize',10,'HorizontalAlignment','Center','Callback',@updateFlowData_Callback,'TooltipString','Select to stop all pumps when experiment is completed');
handles.refreshpumpinfo=uicontrol('Style','pushbutton','BackgroundColor',[0.8 0.8 0.8],'Parent',handles.flowPanel,'Units','Normalized','Position',[.62 .2 .13 .103],'String','Refresh','Value',1,'FontSize',10,'HorizontalAlignment','Center','Callback',@refreshPumpInfo_Callback,'TooltipString','Click to refresh the information shown using the actual state of the pumps');
handles.logpumps=uicontrol('Style','radiobutton','BackgroundColor',[0.8 0.8 0.8],'Parent',handles.flowPanel,'Units','Normalized','Position',[.78 .2 .25 .103],'String','Log pump info','Value',1,'FontSize',10,'HorizontalAlignment','Center','Callback',@logPumpInfo_Callback,'Value',0,'TooltipString','Select to log real info about the state of the pumps during the acquisition. If selected this feature will email you if one of the pumps stalls during the experiment. This will slow each timepoint down by around 10s.');

%Controls outside the panels
handles.saveSettings=uicontrol('Style','pushbutton','Parent',handles.gui,'Units','Normalized','Position',[.558 .141 .104 .026],'String','Save settings','TooltipString','Save experiment acquisition settings','Callback',@saveSettings_Callback);
handles.loadSettings=uicontrol('Style','pushbutton','Parent',handles.gui,'Units','Normalized','Position',[.558 .109 .104 .026],'String','Load settings','TooltipString','Load experiment acquisition settings','Callback',@loadSettings_Callback);
handles.live=uicontrol('Style','pushbutton','Parent',handles.gui,'Units','Normalized','Position',[.689 .141 .088 .028],'String','Live','TooltipString','Show live feed from the camera','BackgroundColor',[0.2 0.9 0.2],'Callback',@live_Callback);
handles.liveDIC=uicontrol('Style','pushbutton','Parent',handles.gui,'Units','Normalized','Position',[.689 .106 .088 .028],'String','Live DIC','TooltipString','Set microscope for DIC then show live feed from the camera','BackgroundColor',[0.1529    0.2275    0.3725],'ForegroundColor',[1 1 1],'Callback',@liveDIC_Callback);
handles.start=uicontrol('Style','pushbutton','Parent',handles.gui,'Units','Normalized','Position',[.805 .106 .179 .059],'String','Start acquisition','TooltipString','Click to start experiment','ForegroundColor',[0 .498039 0],'FontSize',16,'Callback',@start_Callback);
handles.stopacq=uicontrol('Style','pushbutton','Parent',handles.gui,'Units','Normalized','Position',[.805 .038 .179 .059],'String','Stop acquisition','TooltipString','Click to stop experiment','ForegroundColor',[1 0 0],'FontSize',16,'Callback',@stopacq_Callback);
handles.debug=uicontrol('Style','pushbutton','Parent',handles.gui,'Units','Normalized','Position',[0.5580    0.03    .05   0.0260],'String','Debug','Callback',@debug_Callback);

