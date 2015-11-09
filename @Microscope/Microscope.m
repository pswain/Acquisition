classdef Microscope

    properties
        Name
        nameImage%Icon to display in GUI
        Config%String, path of micromanager config file
        InitialChannel%To be set when starting up
        Filters%Structure - will hold information on the filters installed
        Channels%Structure - holds information on the microscope configuration for each channel
        Autofocus%autofocus device object - provides methods to run PFS or alternative autofocus device
        cameraFormat;
        pumpComs;%structure, Com port and baud numbers for the syringe pumps
        OmeroInfoPath%string, full path to stored Omero database information
        OmeroCodePath%string, full path to local copy of the Omero code
        DataPath
        %Microscope devices
        XYStage%string, micromanager config name of the XY stage device
        ZStage;%string, micromanager config name of the Z focus device
        ImageSize;

    end
    
    methods
        function obj=Microscope()
        %Constructor function for microscope object
        %Sets default values for various properties
        %Get computer name
        [idum,hostname]= system('hostname');
        if length(hostname)<14
            hostname(length(hostname)+1:14)=' ';
        end
        %Establish which computer is running this, and therefore which microscope
        k=strfind(hostname,'SCE-BIO-C03727');
        if ~isempty(k)
            %Robin
            obj.Name='Robin';
            obj.nameImage=imread('Robin.jpg');
            obj.Config='C:\Users\Public\MM config files\LeicaConfig_3colour2.cfg';
            obj.InitialChannel='BrightField';
            obj.Autofocus=Autofocus('none');
            obj.pumpComs(1).com='COM14';%pump1
            obj.pumpComs(2).com='COM15';%pump2
            obj.pumpComs(1).baud=19200;
            obj.pumpComs(2).baud=19200;
            obj.OmeroInfoPath='C:/AcquisitionDataRobin/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
            obj.OmeroCodePath='C:/AcquisitionDataRobin\Swain Lab\OmeroCode';
            obj.DataPath='C:/AcquisitionDataRobin';
            obj.XYStage='XYStage';            
            obj.ZStage='ZStage';

        else
            l=strfind(hostname,'SCE-BIO-C03982');
            if ~isempty(l)
                %Batman
                obj.Name='Batman';      
                obj.nameImage=imread('Batman.jpg');
                obj.Config='C:\Micromanager config files\MMConfig_2cNMS.cfg';
                obj.InitialChannel='DIC';
                obj.Autofocus=Autofocus('PFS');
                obj.pumpComs(1).com='COM8';%pump1
                obj.pumpComs(2).com='COM7';%pump2
                obj.pumpComs(1).baud=19200;
                obj.pumpComs(2).baud=19200;
                obj.OmeroInfoPath='C:/AcquisitionData/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
                obj.OmeroCodePath='C:/AcquisitionData/Omero code';
                obj.DataPath='C:/AcquisitionData';
                obj.DataPath='D:/AcquisitionDataBatman';
                obj.XYStage='XYStage';
                obj.ZStage='TIZDrive';
                obj.ImageSize=[512 512];
            else
                
            l=strfind(hostname,'SCE-BIO-C04078');
            if ~isempty(l)
                %Batgirl
                obj.Name='Batgirl';      
                obj.nameImage=imread('Batgirl.jpg');
                obj.Config='C:\Micromanager config files\Batgirl14_5_15.cfg';
                obj.InitialChannel='DIC';
                obj.Autofocus=Autofocus('PFS');
                obj.pumpComs(1).com='COM5';%pump1
                obj.pumpComs(2).com='COM6';%pump2
                obj.pumpComs(1).baud=19200;
                obj.pumpComs(2).baud=19200;
                obj.OmeroInfoPath='C:/AcquisitionDataBatgirl/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
                obj.OmeroCodePath='C:/AcquisitionDataBatgirl/Omero code';
                obj.DataPath='D:/AcquisitionDataBatgirl';
                obj.XYStage='XYStage';
                obj.ZStage='TIZDrive';
            else
                
            l=strfind(hostname,'SCE-BIO-C04078');
            if ~isempty(l)
                %Batgirl
                obj.Name='Batgirl';      
                obj.nameImage=imread('Batgirl.jpg');
                obj.Config='C:\Micromanager config files\NewNikon.cfg';
                obj.InitialChannel='DIC';
                obj.Autofocus=Autofocus('PFS');
                obj.pumpComs(1).com='COM5';%pump1
                obj.pumpComs(2).com='COM6';%pump2
                obj.pumpComs(1).baud=19200;
                obj.pumpComs(2).baud=19200;
                obj.OmeroInfoPath='C:/AcquisitionDataBatgirl/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
                obj.OmeroCodePath='C:/AcquisitionDataBatgirl/Omero code';
                obj.DataPath='C:/AcquisitionDataBatgirl';
                obj.XYStage='XYStage';
                obj.ZStage='TIZDrive';

            else
               obj.Name='Demo';
               obj.nameImage=imread('Joker.jpg');
               if ismac
                obj.Config='/Applications/Micro-Manager1.4/MMConfig_demo.cfg';
                obj.InitialChannel='DIC';
                obj.OmeroCodePath='Volumes/AcquisitionData/Omero code master copy';%Change this when local copy set up
                obj.OmeroInfoPath='Volumes/AcquisitionData/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';

               else
                   %Insert path to demo config file etc. here
               end

                
            end
            end
            
        end

        end
        end
        function loadConfig(obj)
           global mmc;
           mmc.loadSystemConfiguration(obj.Config);
        end
        
        function setInitialChannel(obj)
            global mmc;
            mmc.setConfig('Channel',obj.InitialChannel);
        end
        
        function Initialize(obj)
        %Sets initial property values
        global mmc
        switch obj.Name
            case('Batman')
                mmc.setShutterDevice('DTOL-Shutter');
                mmc.setProperty('Evolve', 'Gain', '1');
                mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
                mmc.setProperty('Evolve','MultiplierGain','270');%starting gain
                %next 2 lines are specific for QUANT version of scripts
                mmc.setProperty('Evolve','PP  2   ENABLED','Yes');%Enable quant view - output in photoelectrons
                mmc.setProperty('Evolve','PP  4   (e)','1');%one grey level per pixel
                mmc.setProperty('TILightPath','Label','2-Left100');%all light should go to the camera
                mmc.setAutoShutter(1);
            case 'Robin'
                mmc.setProperty('Myo','ReadoutRate','10MHz 14bit');
                mmc.setProperty('Myo','Binning',2);
                mmc.setAutoShutter(1);
            case('Batgirl')
                mmc.setProperty('Evolve', 'Gain', '1');
                mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
                mmc.setProperty('Evolve','MultiplierGain','270');%starting gain
                mmc.setProperty('Evolve','PP  2   ENABLED','Yes');%Enable quant view - output in photoelectrons
                mmc.setProperty('Evolve','PP  2   (E)','1');%one grey level per pixel
                mmc.setProperty('Evolve','Port','Normal');
                mmc.setProperty('TILightPath','Label','2-Left100');%all light should go to the camera
                mmc.setAutoShutter(1);
        end
            
        
        end
        function handles=setGUI(obj, handles)
               %Modifies the multiDGUI for use with this microscope
               %Show the microscope name icon (Batman or Robin)
               %Also records the configurations used for each channel in
               %obj.Channels and activates or inactivates relevant GUI
               %controls
              
               axes(handles.micNameIcon)
               imshow(handles.acquisition.microscope.nameImage);
               
               
               %Get channel names
               global mmc;
               chList=mmc.getAvailableConfigs('Channel');
               %Loop through the channels - applying each to a set of
               %controls               
               chControl=1;               
               for ch=0:chList.size-1
                      chName=chList.get(ch);
                      chName=char(chName);
                  if chControl<9 %Only 8 slots for channels in the GUI
                      if ~strcmp(chName,'Kill') && ~strcmp(chName,'Picogreen')
                          useTagName=['useCh' num2str(chControl)];
                          set(handles.(useTagName),'String',chName);
                          %Activate controls for this channel
                          expTagName=['expCh' num2str(chControl)];
                          skipTagName=['skipCh' num2str(chControl)];
                          camModeTagName=['cammodeCh' num2str(chControl)];
                          startGainTagName=['startgainCh' num2str(chControl)];
                          voltTagName=['voltCh' num2str(chControl)];
                          zTagName=['ZsectCh' num2str(chControl)];
                          startTpTagName=['starttpCh' num2str(chControl)];
                          snapTagName=['snapCh' num2str(chControl)]; 
                          set(handles.(useTagName),'Enable','On');            
                          set(handles.(expTagName),'Enable','On');            
                          set(handles.(skipTagName),'Enable','On');
                          set(handles.(zTagName),'Enable','On');
                          set(handles.(startTpTagName),'Enable','On');
                          set(handles.(snapTagName),'Enable','On');
                          set(handles.(startGainTagName),'Enable','Off');
                          set(handles.(camModeTagName),'Value',2);
                          switch(obj.Name)
                              case 'Batman'
                                  set(handles.(camModeTagName),'Enable','On');
                                  set(handles.(voltTagName),'Enable','off');
                              case 'Batgirl'
                                  set(handles.(camModeTagName),'Enable','On');
                                  set(handles.(voltTagName),'Enable','off');
                              case 'Robin'
                                  set(handles.(camModeTagName),'Enable','Off');
                                  set(handles.(voltTagName),'Enable','off');
                          end
                          %Set button colours based on the channel names
                          chColour=getChColour(chName);
                          set(handles.(useTagName),'BackgroundColor',chColour);
                          set(handles.(snapTagName),'BackgroundColor',chColour);
                          chControl=chControl+1;
                      end
                  else
                      disp (['Channel ' chName ' not added - no room in GUI']);
                  end
               end
               numChannels=chControl-1;
               %Deactivate the controls for any unused channels
               if chControl<9
                   for chControl=chControl:8
                      useTagName=['useCh' num2str(chControl)];
                      %Deactivate controls for this channel
                      expTagName=['expCh' num2str(chControl)];
                      skipTagName=['skipCh' num2str(chControl)];
                      camModeTagName=['cammodeCh' num2str(chControl)];
                      startGainTagName=['startgainCh' num2str(chControl)];
                      voltTagName=['voltCh' num2str(chControl)];
                      zTagName=['ZsectCh' num2str(chControl)];
                      startTpTagName=['starttpCh' num2str(chControl)];
                      snapTagName=['snapCh' num2str(chControl)];
                      set(handles.(useTagName),'Enable','Off');            
                      set(handles.(expTagName),'Enable','Off');            
                      set(handles.(skipTagName),'Enable','Off');
                      set(handles.(zTagName),'Enable','Off');
                      set(handles.(startTpTagName),'Enable','Off');
                      set(handles.(snapTagName),'Enable','Off');
                      set(handles.(startGainTagName),'Enable','Off');
                      set(handles.(camModeTagName),'Enable','Off');
                      set(handles.(voltTagName),'Enable','Off');
                   end
               end
               %Set the tooltipstrings - based on the filter info in config
               %file
               %Get the filter configurations for the current config file
               try
                   obj=obj.getFilters;
                   for ch=1:min(numChannels,8)
                       chName=get(handles.(['useCh' num2str(ch)]),'String');
                       filterConfig=obj.Filters.(chName);
                       %Convert to a string
                       res = cellfun(@(x) [x '. '], filterConfig, 'UniformOutput', false);
                       res = cell2mat(res');
                       res(end-1:end) = [];
                       filterConfig=res;                     
                       set(handles.(['useCh' num2str(ch)]),'TooltipString',filterConfig);
                       obj.Channels(ch).name=chName;
                       obj.Channels(ch).config=filterConfig;
                   end
               catch
                   disp('Failed to get filter configuration from the config file');
               end
               
               %Active/deactivate relevant controls               
               switch obj.Name
                   case ('Batman')
                       set(handles.eye,'Enable','on');
                       set(handles.camera,'Enable','on');
                       set(handles.EM,'Enable','on');
                       set(handles.CCD,'Enable','on');
                       handles.acquisition.omero.tags{length(handles.acquisition.omero.tags)+1}='Batman';
                       set(handles.bin,'enable','on');
                   case ('Robin')
                       set(handles.eye,'Enable','off');
                       set(handles.camera,'Enable','off');
                       set(handles.EM,'Enable','off');
                       set(handles.CCD,'Enable','off');
                       set(handles.zMethod,'Enable','off');
                       handles.acquisition.omero.tags{length(handles.acquisition.omero.tags)+1}='Robin';
                       set(handles.bin,'enable','on');
                   case 'Batgirl'
                       set(handles.eye,'Enable','on');
                       set(handles.camera,'Enable','on');
                       set(handles.EM,'Enable','on');
                       set(handles.CCD,'Enable','on');
                       handles.acquisition.omero.tags{length(handles.acquisition.omero.tags)+1}='Batgirl';
                       set(handles.bin,'enable','on');
                       set(handles.zMethod,'Enable','off');
               end
               
               %Set the News text
               
               switch obj.Name
                   case 'Batman'
                       batText='You are running the new programmatic GUI. This is not fully tested on Batman. Z sectioning will not work. You should go to the folder: Users/Public/Microscope control_old_multiDGUI and run multiDGUI to run the old version.';
                   case 'Robin'
                       batText='New programmatic GUI running on Robin. Ask Ivan (07748450511, ivan.clark@ed.ac.uk) if there are any problems.';
                   case 'Batgirl'
                       batText='New programmatic GUI running on Batgirl. Ask Ivan (07748450511, ivan.clark@ed.ac.uk) if there are any problems. Recent bug fixes: Camera mode should be set properly when snapping, and EM images should be flipped to the correct orientation.';
               end
               set(handles.news,'String',batText);
               
               %Set the disk size text
               set(set(handles.freeSpaceText,'String',['Free space (Gb, drive ' obj.DataPath(1) ')']));
               set(handles.TagList,'String', handles.acquisition.omero.tags);
               %Define the correct image size
               %Get the image size and set in handles.imageSize
               binOptions=get(handles.bin,'String');
               bin=binOptions{get(handles.bin,'Value')};
               handles.acquisition.imagesize=handles.acquisition.microscope.getImageSize(bin);
               imSizeString=[num2str(handles.acquisition.imagesize(1)) 'x' num2str(handles.acquisition.imagesize(2))];
               set(handles.imagesize,'String', imSizeString);
                
        end
        function lightToCamera(obj)
           switch obj.Name 

               case {'Batman','Batgirl'}
                   global mmc
                   mmc.setProperty('TILightPath', 'Label','2-Left100');%send light to the camera
           end
            
        end
        
        
        function setLEDVoltage(obj, voltage)
           switch obj.Name 
               case('Batman')
                   global mmc
                   LED=mmc.getProperty('DTOL-Switch','State');
                   switch(str2num(LED))
                        case 1
                            dac=[];
                        case 2%The CFP LED - adjust DAC-1
                            dac='DTOL-DAC-1';
                        case 4%The GFP/YFP LED - adjust DAC-1
                            dac='DTOL-DAC-2';
                        case 8%The mCherry/cy5/tdTomato LED - adjust DAC-1
                            dac='DTOL-DAC-3';
                    end
                    if ~isempty(dac)
                    mmc.setProperty(dac,'Volts', voltage);
                    end
           end
        end
            
        function figTitle=setCamMode(obj, mode,figTitle,EMgain)
        global mmc
        switch (obj.Name)
            case 'Batman'
                switch mode
                    case 1
                        mmc.setProperty ('Evolve','Port','Multiplication Gain');
                        mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                        figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
                    case 3
                        mmc.setProperty ('Evolve','Port','Multiplication Gain');
                        mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                        figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
                    case 2
                        mmc.setProperty ('Evolve','Port','Normal');
                        figTitle=strcat(figTitle,'. CCD');
                end
                mmc.waitForDevice('Evolve');
            case 'Batgirl'
                switch mode
                    case 1
                        mmc.setProperty ('Evolve','Port','Multiplication Gain');
                        mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                        figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
                    case 3
                        mmc.setProperty ('Evolve','Port','Multiplication Gain');
                        mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                        figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
                    case 2
                        mmc.setProperty ('Evolve','Port','Normal');
                        figTitle=strcat(figTitle,'. CCD');
                end
                mmc.waitForDevice('Evolve');
            end
        end

        function obj=getFilters(obj)
        %Parses the config file to extract filter information
        confFile=fopen(obj.Config);
        confData=textscan(confFile,'%s','Delimiter','#');
        confData=confData{:};
        %Find the channel presets:
        presets=strfind(confData,'Preset: ');
        presets=find(~cellfun(@isempty,presets));
        presets(end+1)=length(confData);
        for ch=1:length(presets)-1
            %Find the lines that define the preset properties
           chName= confData{presets(ch)}
           chName=chName(9:end);
           chName(~isstrprop(chName,'alphanum'))=[];
           thisCh=strfind(confData,chName);
           thisCh=find(~cellfun(@isempty,thisCh));
           %Loop through the properties of this preset
           props=thisCh(thisCh>presets(ch)&thisCh<presets(ch+1));
           for p=1:length(props)
               line=confData{props(p)};
               line=textscan(line,'%s','Delimiter',',');
               line=line{:};
               %line {4} is the device, line{5}, the property and line{6} the value
               obj.Channels.(chName)(p).device=line{4};
               obj.Channels.(chName)(p).property=line{5};
               obj.Channels.(chName)(p).value=line{6};
               
               
           end
        end
        %Loop through the channels, defining the filters
        chNames=fields(obj.Channels)
        for ch=1:length(chNames)
            chName=chNames{ch};
            obj.Filters.(chName)=cell(length(obj.Channels.(chName)),1);
            for n=1:length(obj.Channels.(chName))
                device=obj.Channels.(chName)(n).device;
                property=obj.Channels.(chName)(n).property;
                value=obj.Channels.(chName)(n).value;
                %Find device name/description
                target=['@' device '. "'];
                deviceLine=strfind(confData,target);
                deviceLine=find(~cellfun(@isempty,deviceLine));
                if ~isempty(deviceLine)
                    deviceLine=confData{deviceLine};
                    deviceLine=textscan(deviceLine,'%s','Delimiter','"');
                    deviceLine=deviceLine{:};
                    %Find the lines with the current property and value
                    target=['@' device ',' property ',' value];
                    valueLine=strfind(confData,target);
                    valueLine=find(~cellfun(@isempty,valueLine));
                    if ~isempty(valueLine)
                        valueLine=confData{valueLine};
                        valueLine=textscan(valueLine,'%s','Delimiter','"');
                        valueLine=textscan(valueLine,'%s','BufSize',20000,'Delimiter','"');
                        valueLine=valueLine{:};
                        obj.Filters.(chName){n,1}=[deviceLine{2} valueLine{2}];
                    end
                end
            end
            obj.Filters.(chName)(cellfun(@isempty,obj.Filters.(chName)))=[];
        end
        
        
        
        end
        function [x, y, z, AF]=definePoint(obj)
            %Defines a saved XYZ position based on the current state of the
            %microscope
            global mmc;
            switch obj.Name
                case {'Batman', 'Batgirl'}
                    %get position data from the microscope
                    x=mmc.getXPosition('XYStage');
                    y=mmc.getYPosition('XYStage');
                    z=mmc.getPosition('TIZDrive');
                    AF=mmc.getProperty('TIPFSOffset','Position');
                    if ~isnumeric(AF)
                        AF=str2double(char(AF));
                    end
                case 'Robin'
                    x=mmc.getXPosition('XYStage');
                    y=mmc.getYPosition('XYStage');
                    z=mmc.getPosition('ZStage');
                    AF=0;
                    
            end
            
        end
        function status=getAutofocusStatus(obj,logfile)
        %Called by runAcquisition among others. Returns true if the the AF devide is usable
        % otherwise false
        %2nd input is optional - will write to the input logfile if it's
        %there (ie if this is run during acquisition)
        global mmc;
        switch (obj.Autofocus.Type)
            case 'PFS'
                if strcmp('Locked in focus',mmc.getProperty('TIPFSStatus','Status'))==1
                    status=true;
                    if nargin==2
                        fprintf(logfile,'%s','PFS is locked');
                        fprintf(logfile,'\r\n');
                    end
                else
                    
                    status=mmc.getProperty('TIPFSStatus','Status');
                    if nargin==2
                        fprintf(logfile,'%s',strcat('PFS status:',char(status),'- will not be used'));
                        fprintf(logfile,'\r\n');
                    end
                    status=false;
                end
            case 'none'
                status=false;
                if nargin==2
                    fprintf(logfile,'No autofocus device installed');
                    fprintf(logfile,'\r\n');
                end
        end
        end
        function gain=getEMGain(obj)
            global mmc;
        switch obj.Name
            case {'Batman','Batgirl'}
                gain=str2double(mmc.getProperty('Evolve','MultiplierGain'));
            case 'Robin'
                gain=0;
        end
        end
        function LED=getLED(obj)
        global mmc;
        switch obj.Name
            case'Batman'
                LED=mmc.getProperty('DTOL-Switch','State');
            case 'Robin'
                LED=0;
        end
        end


        function setPort(obj, channel,CHsets, logfile)
           %Sets the appropriate camera port (or any other channel-specific camera setting) for the input channel
           global mmc;
           switch obj.Name
               case 'Batman'
                   port=mmc.getProperty('Evolve','Port');
                   if cell2mat(channel(6))==2%if this channel uses the normal (CCD) port
                        if strcmp(port,'Normal')~=1%set port to normal if it's not set already
                            mmc.setProperty('Evolve','Port','Normal');
                            logstring=strcat('Camera port changed to normal:',datestr(clock));A=writelog(logfile,1,logstring);
                        end
                   else%if this channel doesn't use the normal port
                        if strcmp(port,'EM')~=1%if it isn't EM already then set port to EM 
                            mmc.setProperty('Evolve','Port','Multiplication Gain');
                            logstring=strcat('Camera port changed to EM:',datestr(clock));A=writelog(logfile,1,logstring);
                        end

                        %EM camera mode only - do camera settings need to be changed?
                        if CHsets.values(ch,1,gp)~=EMgain %check if gain for this channel needs to be changed
                           %change the camera settings here - if altering E don't forget to multiply the data by this number. 
                           mmc.setProperty('Evolve','MultiplierGain',num2str(CHsets.values(ch,1,gp)));
                           logstring=strcat('EM gain changed to:',num2str(CHsets.values(ch,1,gp)),datestr(clock));A=writelog(logfile,1,logstring);
                           EMgain=CHsets.values(ch,1,gp);

                        end
                  end
                       
               case 'Batgirl'
                   port=mmc.getProperty('Evolve','Port');
                   if cell2mat(channel(6))==2%if this channel uses the normal (CCD) port
                        if strcmp(port,'Normal')~=1%set port to normal if it's not set already
                            mmc.setProperty('Evolve','Port','Normal');
                            logstring=strcat('Camera port changed to normal:',datestr(clock));A=writelog(logfile,1,logstring);
                        end
                   else%if this channel doesn't use the normal port
                        if strcmp(port,'EM')~=1%if it isn't EM already then set port to EM 
                            mmc.setProperty('Evolve','Port','Multiplication Gain');
                            logstring=strcat('Camera port changed to EM:',datestr(clock));A=writelog(logfile,1,logstring);
                        end
                   end
            end
        end
        
        function [stack,maxvalue]=captureStack(obj,filename,thisZ,zInfo,offset,EM,E,height,width)
            %Captures and saves a Z stack using the current microscope. Z
            %position is moved using the appropriate device for this
            %microscope. If Batman is in use then there are 3 alternative
            %methods for moving in Z, determined by zInfo(6).
            
            %Before calling this function:
            %1. Imaging configuration (LED, exposure time, filter positions etc) must
            %   be set
            %2. If any channel in the acquisition does z sectioning the z position
            %should be moved to the top of the stack before calling this.
            %If not, the focus should be positioned at the desired focal position.

            %Arguments:
            %1. filename - complete path for a directory to save the files into. Note - a
            %slice number is added to this filename when each image is saved
            %2. thisZ - 1 if this is a stack
            %3. acqData.z - with the z sectioning information for this experiment -
            %nSlices and interval
            %4. offset value - to position stack in a non standard place
            %5. EM - 1 if this channel uses the EM mode of the camera (ie image should
            %be flipped)
            %6. E - a scalar to multiply the data by (if in the EM mode) - useful for
            %correcting for any changes in exposure time that have occured to avoid
            %saturation in the data.
            global mmc;
            nSlices=zInfo(1);
            sliceInterval=zInfo(2);
            anyZ=zInfo(4);           
            fprintf('no longer uses passed height/width\n');
            height=obj.ImageSize(1);
            width=obj.ImageSize(2);
            stack=zeros(height,width,nSlices);
            %Set the device used for sectioning
            switch obj.Name
                case 'Batman'
                    switch zInfo(6)
                        case 1
                            sectDevice='PIFOC';
                        case 2
                            sectDevice='PIFOC';
                        case 3
                            sectDevice='PFS';
                    end
                case 'Robin'
                    sectDevice='ZStage';
                case 'Batgirl'
                    sectDevice='ZStage';                    
            end
            %Wait until the device is ready before getting position (not
            %convinced this line does anything, hence the pause for Robin
            %next.
            mmc.waitForDevice(sectDevice);
            %Pause to make sure that the stage has finished moving before
            %getting the start position
            %if strcmp(obj.Name, 'Robin')
             %   pause(.5);
            %end
            startPos=mmc.getPosition(sectDevice);%starting position of the sectioning device (microns)

            maxvalue=0;
            %Need to multiply distances by 2 if using PIFOC because for some reason PIFOC moves 0.5microns when you tell it
            %to move 1.
            if strcmp(sectDevice,'PIFOC')
                p=2;
            else
                p=1;
            end
            if thisZ==1%this is a stack acquisition
                %make sure the PFS or other focus device is off
                locked=obj.Autofocus.isLocked;
                if locked
                    obj.Autofocus.switchOff;
                end
                for z=1:nSlices%start of z sectioning loop 
                    %Position of current slice
                    slicePosition=startPos-((nSlices-1)*p*sliceInterval)/2+(p*((z-1)*sliceInterval));                    
                    mmc.setPosition(sectDevice,slicePosition+offset);
                    mmc.waitForDevice(sectDevice);
                    if strcmp(obj.Name, 'Robin')
                        pause(.01);
                    end
                    pause(0.2);
                    mmc.snapImage();
                    img=mmc.getImage;
                    img2=typecast(img,'uint16');
                    %need to record the maximum measured value to return
                    %This is done before any correction for changes in exposure time
                    maxthisz=max(img2);
                    maxvalue=max([maxthisz maxvalue]);
                    img2=reshape(img2,[height,width]);
                    sliceFileName=strcat(filename,'_',sprintf('%03d',z),'.png');
                    if EM==1 || EM==3
                        img2=flipud(img2);
                    end    
                    img2=E.*img2;
                    stack(:,:,z)=img2;
                    imwrite(img2,char(sliceFileName));
                 end
                 %Restore z position
                 mmc.setPosition(sectDevice,startPos);
                 if strcmp(obj.Name, 'Robin')
                     pause(.02);
                 end

            else%single section acquisition
                %If any of the channels in this acquisition do z sectioning then need
                %to use the sectioning device to position focus to the middle of the stack. If not
                %then just capture an image.
                if ~strcmp(obj.Name, 'Robin')
                    if anyZ==1
                        z=nSlices/2;
                        slicePosition=startPos+(p*((z-1)*sliceInterval));
                        mmc.setPosition(sectDevice,slicePosition+offset);
                        pause(0.05);
                    end
                if anyZ==1
                   z=nSlices/2;
                   slicePosition=startPos+(p*((z-1)*sliceInterval));
                   mmc.setPosition(sectDevice,slicePosition+offset);
                   pause(0.5);
                end
                mmc.snapImage();
                img=mmc.getImage;
                img2=typecast(img,'uint16');
                maxvalue=max(img2);%need to record the maximum measured value
                img2=E.*img2;
                img2=reshape(img2,[height,width]);
                stack(:,:,1)=img2;
                sliceFileName=strcat(filename,'_',sprintf('%03d'),'.png');
                if EM==1
                    img2=flipud(img2);
                end
                imwrite(img2,char(sliceFileName));
                %imshow(img2,[]);
                %drawnow;
                if ~strcmp(obj.Name, 'Robin')
                    mmc.setPosition(sectDevice,startPos);
                    if strcmp(obj.Name, 'Robin')
                        pause(.02);
                    end
                end
            end
        end
                              
                mmc.setPosition(sectDevice,startPos);

        end
            
        
        
        function imageSize=getImageSize(obj,bin)
            %Returns a 2-element vector specifying the size of the images
            %for a given camera bin setting. Input is a string, either 1,
            %2x2 or 4x4
            switch obj.Name
                case 'Robin'
                    switch bin
                        case '1'
                            imageSize=[1940 1460];
                        case '2x2'
                            imageSize=[970 730];
                        case '4x4'
                            imageSize=[485 365];
                    end
                case 'Batman'
                    switch bin
                        case '1'
                            imageSize=[512 512];
                        case '2x2'
                            imageSize=[256 256];
                        case '4x4'
                            imageSize=[128 128];
                    end
                 case 'Batgirl'
                    switch bin
                        case '1'
                            imageSize=[512 512];
                        case '2x2'
                            imageSize=[256 256];
                        case '4x4'
                            imageSize=[128 128];
                    end
            end
            obj.ImageSize=imageSize;

        end
         
        function setBin(obj,bin)
           %Sets the bin on the camera
           %input is a string, the first character of which is the binning
           %number (eg '2x2')
           obj.getImageSize(bin);
           bin=str2mat(bin(1));
           global mmc
           switch obj.Name
               case 'Robin'
                   mmc.setProperty('Myo','Binning',bin);              
               case {'Batman','Batgirl'}
                   mmc.setProperty('Evolve','Binning',bin);
           end
            
            
            
        end
        
       
            
            
      end
            
        

end
