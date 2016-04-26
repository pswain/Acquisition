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
        set(handles.zMethod,'Enable','on');
end

%Set the News text

switch obj.Name
    case 'Batman'
        batText='You are running the new programmatic GUI. This is not fully tested on Batman. Z sectioning will not work. You should go to the folder: Users/Public/Microscope control_old_multiDGUI and run multiDGUI to run the old version.';
    case 'Robin'
        batText='New programmatic GUI running on Robin. Ask Ivan (07748450511, ivan.clark@ed.ac.uk) if there are any problems.';
    case 'Batgirl'
        batText='tdTomato is now available on Batgirl, YFP not. Ask Ivan (07748450511, ivan.clark@ed.ac.uk) if there are any problems/bug reports/feature requests.';
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

%Set relevant default values
switch obj.Name
    case ('Batman')
        
    case ('Robin')
        set(handles.bin,'Value',2);%Default bin value
    case 'Batgirl'
        %The following is a quick fix - better to query the
        %channel name in a for loop then have a switch statement. Also
        %add explanation in the tooltip.
        set(handles.voltCh1,'String','1');
        set(handles.voltCh2,'String','4');
        set(handles.voltCh3,'String','1');
        set(handles.voltCh4,'String','19');
        set(handles.voltCh5,'String','10');
        set(handles.voltCh6,'String','18');
        set(handles.voltCh7,'String','18');
        set(handles.voltCh8,'String','2');
        
end

end