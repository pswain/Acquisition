classdef Microscope
    properties
        Name
        nameImage%Icon to display in GUI
        Config%String, path of micromanager config file
        InitialChannel%To be set when starting up
        Filters%Structure - will hold information on the filters installed
        Channels%Structure - holds information on the microscope configuration for each channel
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
            obj.Config='C:\Users\Public\MM config files\LeicaConfig.cfg';
            obj.InitialChannel='BrightField';
        else
            l=strfind(hostname,'SCE-BIO-C02471');
            if ~isempty(l)
                %Batman
                obj.Name='Batman';      
                obj.nameImage=imread('Batman.jpg');
                obj.Config='C:\Micromanager config files\MMConfig_NOFILTERWHEEL2.cfg';
                obj.InitialChannel='DIC';
            else
               obj.Name='Demo';
               obj.nameImage=imread('Joker.jpg');
               if ismac
                obj.Config='/Applications/Micro-Manager1.4/MMConfig_demo.cfg';
                obj.InitialChannel='DIC';
               else
                   %Insert path to demo config file here
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
                mmc.setProperty('Evolve', 'Gain', '2');
                mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
                mmc.setProperty('Evolve','MultiplierGain','270');%starting gain
                %next 2 lines are specific for QUANT version of scripts
                mmc.setProperty('Evolve','PP  4   ENABLED','Yes');%Enable quant view - output in photoelectrons
                mmc.setProperty('Evolve','PP  4   (e)','1');%one grey level per pixel
                mmc.setProperty('DTOL-Shutter','OnOff', '0');
                mmc.setProperty('DTOL-DAC-1','Volts', '4');
                mmc.setProperty('TILightPath','Label','2-Left100');%all light should go to the camera
                mmc.setAutoShutter(1);
            case 'Robin'
                mmc.setProperty('Myo','ReadoutRate','10MHz 14bit');
        end
            
        
        end
        function setGUI(obj, handles)
               %Modifies the multiDGUI for use with this microscope
               %Show the microscope name icon (Batman or Robin)
               %Also records the configurations used for each channel in
               %obj.Channels
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
                              case 'Robin'
                                  set(handles.(camModeTagName),'Enable','Off');
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
               
               
               
               switch obj.Name
                   case ('Batman')
                       set(handles.eye,'Enable','on');
                       set(handles.camera,'Enable','on');
                       set(handles.EM,'Enable','on');
                       set(handles.CCD,'Enable','on');
                       handles.acquisition.omero.tags{length(handles.acquisition.omero.tags)+1}='Batman';
                   case ('Robin')
                       handles.acquisition.omero.tags{length(handles.acquisition.omero.tags)+1}='Robin';
               end
               set(handles.TagList,'String', handles.acquisition.omero.tags);
                
        end
        function lightToCamera(obj)
           switch obj.Name 
               case('Batman')
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
            case('Batman')
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
        confData=textscan(confFile,'%s','BufSize',20000,'Delimiter','#');
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
               line=textscan(line,'%s','BufSize',20000,'Delimiter',',');
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
                    deviceLine=textscan(deviceLine,'%s','BufSize',20000,'Delimiter','"');
                    deviceLine=deviceLine{:};
                    %Find the lines with the current property and value
                    target=['@' device ',' property ',' value];
                    valueLine=strfind(confData,target);
                    valueLine=find(~cellfun(@isempty,valueLine));
                    if ~isempty(valueLine)
                        valueLine=confData{valueLine};
                        valueLine=textscan(valueLine,'%s','BufSize',20000,'Delimiter','"');
                        valueLine=valueLine{:};
                        obj.Filters.(chName){n,1}=[deviceLine{2} valueLine{2}];
                    end
                end
            end
            obj.Filters.(chName)(cellfun(@isempty,obj.Filters.(chName)))=[];
        end
        
        
        end
    end
end
