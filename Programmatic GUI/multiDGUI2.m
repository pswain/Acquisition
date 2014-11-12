handles.gui=figure('Units','normalized','Position',[0.1    0.8    0.75    0.75]);

%Set the panels
handles.experimentPanel=uipanel('Parent',handles.gui,'Title','Experiment','Position',[.019 .881 .967 .104],'FontWeight','Bold','FontSize',16);
handles.channelPanel=uipanel('Parent',handles.gui,'Title','Channels','Position',[.019 .459 .622 .421],'FontWeight','Bold','FontSize',16);
handles.pointPanel=uipanel('Parent',handles.gui,'Title','Point visiting','Position',[.019 .175 .53 .283],'FontWeight','Bold','FontSize',16);
handles.micPanel=uipanel('Parent',handles.gui,'Title','Microscope control','Position',[.019 .095 .53 .077],'FontWeight','Bold','FontSize',16);
handles.specialPanel=uipanel('Parent',handles.gui,'Title','Special tasks','Position',[.019 .027 .779 .061],'FontWeight','Bold','FontSize',16);
handles.zPanel=uipanel('Parent',handles.gui,'Title','Z sectioning','Position',[.645 .772 .206 .108],'FontWeight','Bold','FontSize',16);
handles.timePanel=uipanel('Parent',handles.gui,'Title','Time settings','Position',[.645 .464 .206 .308],'FontWeight','Bold','FontSize',16);
handles.newsPanel=uipanel('Parent',handles.gui,'Title','News','Position',[.86 .465 .126 .417],'FontWeight','Bold','FontSize',16);
handles.flowPanel=uipanel('Parent',handles.gui,'Title','Flow control','Position',[.558 .175 .427 .283],'FontWeight','Bold','FontSize',16);
handles.exptName=uicontrol('Style','edit','Parent',handles.experimentPanel,'Units','Normalized','Position',[.006 .549 .158 .288],'String','exp','BackgroundColor','w');
handles.Project=uicontrol('Style','text','Parent',handles.experimentPanel,'Units','Normalized','Position',[.62 .692 .229 .346],'String','Default project','FontWeight','Bold','FontSize',12);
handles.TagList=uicontrol('Style','listbox','Parent',handles.experimentPanel,'Units','Normalized','Position',[.621 .101 .228 .62],'String','TagList','TooltipString','List of the Omero tags that will be applied to this experiment','FontWeight','Bold','FontSize',12);

%Controls in experiment panel
handles.exptName=uicontrol('Style','edit','Parent',handles.experimentPanel,'Units','Normalized','Position',[.006 .549 .158 .288],'String','exp','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('exptName_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter experiment name');
handles.pushbutton10=uicontrol('Style','pushbutton','Parent',handles.experimentPanel,'Units','Normalized','Position',[.007 .088 .157 .418],'String','Enter details','BackgroundColor','w','TooltipString','Record details of you experiment - eg aim, strain used etc. Entries will be written into the log file.','Callback',@(hObject,eventdata)multiDGUI('pushbutton10_Callback',hObject,eventdata,guidata(hObject)));
handles.text1=uicontrol('Style','text','Parent',handles.experimentPanel,'Units','Normalized','Position',[.177 .838 .135 .202],'String','Files will be saved in:');
handles.OmeroProjects=uicontrol('Style','popupmenu','Parent',handles.experimentPanel,'Units','Normalized','Position',[.172 .059 .184 .361],'String','Project menu','TooltipString','Choose an Omero project for your experiment','Callback',@(hObject,eventdata)multiDGUI('OmeroProjects_Callback',hObject,eventdata,guidata(hObject)));
handles.OmeroTags=uicontrol('Style','popupmenu','Parent',handles.experimentPanel,'Units','Normalized','Position',[.358 .059 .184 .361],'String','Tags menu','TooltipString','Choose Omero Tags for your experiment','Callback',@(hObject,eventdata)multiDGUI('OmeroTags_Callback',hObject,eventdata,guidata(hObject)));
handles.removeTag=uicontrol('Style','pushbutton','Parent',handles.experimentPanel,'Units','Normalized','Position',[.546 .102 .071 .32],'String','Remove tag','TooltipString','Click to remove selected tag from your experiment','Callback',@(hObject,eventdata)multiDGUI('removeTag_Callback',hObject,eventdata,guidata(hObject)),'BackgroundColor','w');
handles.TagList=uicontrol('Style','listbox','Parent',handles.experimentPanel,'Units','Normalized','Position',[.621 .101 .228 .62],'String','TagList','TooltipString','List of the Omero tags that will be applied to this experiment','FontWeight','Bold','FontSize',12,'BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('TagList_Callback',hObject,eventdata,guidata(hObject)));
handles.micNameIcon=axes('Parent', handles.experimentPanel,'Units','Normalized','Position',[.902 .101 .069 .923]);

%Controls in channels panel
%Text headings
handles.text11=uicontrol('Style','text','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .894 .12 .099],'String','Exposure(ms)','FontSize',10,'HorizontalAlignment','Center');
handles.text13=uicontrol('Style','text','Parent',handles.channelPanel,'Units','Normalized','Position',[.258 .894 .142 .099],'String','Skip','FontSize',10,'HorizontalAlignment','Center');
handles.text42=uicontrol('Style','text','Parent',handles.channelPanel,'Units','Normalized','Position',[.395 .873 .096 .12],'String','Camera mode','FontSize',10,'HorizontalAlignment','Center');
handles.text43=uicontrol('Style','text','Parent',handles.channelPanel,'Units','Normalized','Position',[.52 .873 .096 .12],'String','Starting gain','FontSize',10,'HorizontalAlignment','Center');
handles.text44=uicontrol('Style','text','Parent',handles.channelPanel,'Units','Normalized','Position',[.622 .873 .096 .12],'String','LED Voltage','FontSize',10,'HorizontalAlignment','Center');
handles.text25=uicontrol('Style','text','Parent',handles.channelPanel,'Units','Normalized','Position',[.7 .873 .096 .108],'String','Z stack?','FontSize',10,'HorizontalAlignment','Center');
handles.text26=uicontrol('Style','text','Parent',handles.channelPanel,'Units','Normalized','Position',[.779 .873 .12 .108],'String','Starting timepoint','FontSize',10,'HorizontalAlignment','Center');
%Use channel buttons
handles.useCh1=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .80 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
handles.useCh2=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .6926 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
handles.useCh3=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .5855 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
handles.useCh4=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .4784 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
handles.useCh5=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .3713 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
handles.useCh6=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .2642 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
handles.useCh7=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .1571 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
handles.useCh8=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.01 .05 .13 .08],'String','Use Channel','Callback',@(hObject,eventdata)multiDGUI('useChannel_Callback',hObject,eventdata,guidata(hObject)));
%Exposure times
handles.expCh1=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .80 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh2=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .6926 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh3=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .5855 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh4=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .4784 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh5=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .3713 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh6=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .2642 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh7=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .1571 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
handles.expCh8=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.156 .05 .1 .08],'String','30','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('expChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Exposure time in milliseconds');
%Skip
handles.skipCh1=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .80 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh2=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .6926 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh3=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .5855 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh4=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .4784 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh5=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .3713 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh6=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .2642 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh7=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .1571 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
handles.skipCh8=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.304 .05 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('skipChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Enter number of timepoints to skip. eg if you enter 4 an image will be taken in this channel only 1 in every 4 timepoints');
%Camera mode menu
handles.cammodeCh1=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .81 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh2=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .6926 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh3=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .5852 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh4=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .4778 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh5=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .3704 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh6=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .2630 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh7=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .1556 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
handles.cammodeCh8=uicontrol('Style','popupmenu','Parent',handles.channelPanel,'Units','Normalized','Position',[.381 .0482 .12 .08],'String',{'EM_Smart';'CCD';'EM_Constant'},'FontWeight','Bold','FontSize',12,'Callback',@(hObject,eventdata)multiDGUI('cammodeChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','When using Evolve camera only - choose camera mode. CCD - lowest noise but least sensitive. EM constant - gain and exposure set for whole experiment. EM Smart - gain and exposure vary based on previous measurements. Used to remain in linear range in experiments with large variation in signal, eg Gal inductions');
%Starting gain
handles.startgainCh1=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .80 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh2=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .6926 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh3=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .5855 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh4=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .4784 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh5=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .3713 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh6=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .2642 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh7=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .1571 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
handles.startgainCh8=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.529 .05 .078 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('startgainChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Only in EM camera mode. EM gain at start of experiment (EM_Smart mode) or for whole experiment (EM_Constant mode)');
%LED voltage
handles.voltCh1=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .80 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
handles.voltCh2=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .6926 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
handles.voltCh3=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .5855 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
handles.voltCh4=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .4784 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
handles.voltCh5=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .3713 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
handles.voltCh6=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .2642 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
handles.voltCh7=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .1571 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
handles.voltCh8=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.631 .05 .048 .08],'String','270','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('changeVoltage_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Voltage applied to LED during exposure');
%Z section
handles.ZsectCh1=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .808 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh2=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .7006 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh3=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .5932 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh4=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .4858 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh5=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .3784 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh6=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .2710 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh7=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .1636 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
handles.ZsectCh8=uicontrol('Style','checkbox','Parent',handles.channelPanel,'Units','Normalized','Position',[.73 .0562 .024 .067],'Callback',@(hObject,eventdata)multiDGUI('ZsectChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Select if you want this channel to do Z sectioning');
%Starting timepoint
handles.starttpCh1=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .80 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
handles.starttpCh2=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .6926 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
handles.starttpCh3=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .5855 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
handles.starttpCh4=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .4784 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
handles.starttpCh5=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .3713 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
handles.starttpCh6=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .2642 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
handles.starttpCh7=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .1571 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
handles.starttpCh8=uicontrol('Style','edit','Parent',handles.channelPanel,'Units','Normalized','Position',[.79 .05 .048 .08],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('starttpChannel_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Timepoint to start imaging');
%Snap buttons
handles.snapCh1=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .80 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));
handles.snapCh2=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .6926 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));
handles.snapCh3=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .5855 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));
handles.snapCh4=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .4784 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));
handles.snapCh5=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .3713 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));
handles.snapCh6=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .2642 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));
handles.snapCh7=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .1571 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));
handles.snapCh8=uicontrol('Style','togglebutton','Parent',handles.channelPanel,'Units','Normalized','Position',[.91 .05 .065 .061],'String','Snap','Callback',@(hObject,eventdata)multiDGUI('snap_Callback',hObject,eventdata,guidata(hObject)));

%Controls in Z sectioning panel
%Text headings
handles.text23=uicontrol('Style','text','Parent',handles.zPanel,'Units','Normalized','Position',[.044 .413 .486 .358],'String','Number of sections','FontSize',10,'HorizontalAlignment','Center');
handles.text22=uicontrol('Style','text','Parent',handles.zPanel,'Units','Normalized','Position',[.534 .413 .437 .358],'String','Section spacing','FontSize',10,'HorizontalAlignment','Center');
handles.text32=uicontrol('Style','text','Parent',handles.zPanel,'Units','Normalized','Position',[.838 .179 .112 .193],'String','m','FontSize',10,'FontName','Symbol','HorizontalAlignment','Center');
handles.text33=uicontrol('Style','text','Parent',handles.zPanel,'Units','Normalized','Position',[.879 .152 .097 .193],'String','m','FontSize',10,'FontName','Helvetica','HorizontalAlignment','Center');
%Controls
handles.nZsections=uicontrol('Style','edit','Parent',handles.zPanel,'Units','Normalized','Position',[.141 .178 .238 .276],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('nZsections_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Number of sections');
handles.zspacing=uicontrol('Style','edit','Parent',handles.zPanel,'Units','Normalized','Position',[.602 .178 .238 .276],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('zspacing_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Spacing between sections in micrometres');

%Time settings panel
handles.doTimelapse=uicontrol('Style','radiobutton','Parent',handles.timePanel,'Units','Normalized','Position',[.098 .862 .732 .094],'String','Time lapse?','FontSize',10,'HorizontalAlignment','Center');
handles.text18=uicontrol('Style','text','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .732 .298 .106],'String','Time interval','FontSize',10,'HorizontalAlignment','Left');
handles.interval=uicontrol('Style','edit','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .691 .332 .081],'String','5','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('interval_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Interval between time points');
handles.units=uicontrol('Style','popupmenu','Parent',handles.timePanel,'Units','Normalized','Position',[.429 .691 .3 .081],'String',{'s';'min';'hr'},'FontSize',10,'Callback',@(hObject,eventdata)multiDGUI('units_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Set units for time interval');
handles.text20=uicontrol('Style','text','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .512 .561 .106],'String','Number of time points','FontSize',10,'HorizontalAlignment','Left');
handles.nTimepoints=uicontrol('Style','edit','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .472 .332 .081],'String','1','BackgroundColor','w','Callback',@(hObject,eventdata)multiDGUI('nTimepoints_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Number of time points');
handles.text21=uicontrol('Style','text','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .338 .561 .106],'String','Total time','FontSize',10,'HorizontalAlignment','Left');
handles.totaltime=uicontrol('Style','text','Parent',handles.timePanel,'Units','Normalized','Position',[.088 .297 .332 .081],'String','1','FontSize',10,'HorizontalAlignment','Left','BackgroundColor','w');
handles.unitsTotal=uicontrol('Style','popupmenu','Parent',handles.timePanel,'Units','Normalized','Position',[.429 .297 .3 .081],'String',{'s';'min';'hr'},'FontSize',10,'Callback',@(hObject,eventdata)multiDGUI('unitsTotal_Callback',hObject,eventdata,guidata(hObject)),'TooltipString','Set units for time interval');

%News panel
news='This is the new programmatic GUI!';
handles.news=uicontrol('Style','text','Parent',handles.newsPanel,'Units','Normalized','Position',[.056 .024 .872 .956],'String',news,'FontSize',10,'HorizontalAlignment','Center','BackgroundColor','w');

%Point visiting panel
columnEditable=[1 1 1 1 1 1 0];
columnName={'Name';'x (microns)';'y (microns), ';'z drive position (microns)';'PFS Offset';'Group';''};
columnWidth={80,65,65,'auto','auto', 'auto', 'auto'};
handles.pointsTable=uitable('Parent',handles.pointPanel,'ColumnName',columnName,'ColumnEditable',columnEditable,'ColumnWidth',columnWidth,'Units','Normalized','Position',[.013 .236 .955 .713],'FontSize',10,'TooltipString','NB: If using the PFS make sure it is on and set the focus (z) position using the PFS offset wheel (not the microscope focus wheel) before marking the point. For a double exposure to monitor bleaching type "double" in the exposure field and add this point to the group to which it refers.','CellEditCallback',@(hObject,eventdata)multiDGUI('pointsTable_CellEditCallback',hObject,eventdata,guidata(hObject)),'CellSelectionCallback',@(hObject,eventdata)multiDGUI('pointsTable_CellSelectionCallback',hObject,eventdata,guidata(hObject)));
