
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
 
    for ch=1:nChannels
        chName=char(handles.acquisition.channels(ch,1));
        %Need to work out which set of channel controls refers to this
        %channel
        for chControl=1:8
           if strcmp(get(handles.(['useCh' num2str(chControl)]),'String'),chName)
               chTagString=['Ch' num2str(chControl)];
           end
        end
        set(handles.(['exp' chTagString]),'Enable','on');
        set(handles.(['use' chTagString]),'Value',1);
        set(handles.(['Zsect' chTagString]),'Enable','on');
        set(handles.(['starttp' chTagString]),'Enable','on');
        set(handles.(['skip' chTagString]),'Enable','on');
        set(handles.(['snap' chTagString]),'Enable','on');
        %Enable camera mode and gain control on microscopes with EM cameras
        if ~strcmp(handles.acquisition.microscope.Name,'Robin')
            set(handles.(['cammode' chTagString]),'Enable','on');
            set(handles.(['startgain' chTagString]),'Enable','on');
        end
        %Enable volt control for channels in which brightness can
        %be controlled
        %Use getLED with verbose output of config object to determine this
        global mmc;
        config=mmc.getConfigData('Channel',chName);
        verbose=config.getVerbose;
        LED=handles.acquisition.microscope.getLED(verbose);
        if ~isempty(LED)
            [device, voltProp]=handles.acquisition.microscope.getLEDVoltProp(LED);
        end
        if ~isempty(device)
            set(handles.(['volt' chTagString]),'Enable','on');
        end
        %Set values for the controls       
        set(handles.(['exp' chTagString]),'String',num2str(cell2mat(handles.acquisition.channels(ch,2))));
        set(handles.(['Zsect' chTagString]),'Value',cell2mat(handles.acquisition.channels(ch,4)));
        set(handles.(['starttp' chTagString]),'String',num2str(cell2mat(handles.acquisition.channels(ch,5))));
        set(handles.(['cammode' chTagString]),'Value',cell2mat(handles.acquisition.channels(ch,6)));
        set(handles.(['startgain' chTagString]),'Value',cell2mat(handles.acquisition.channels(ch,7)));
        set(handles.(['volt' chTagString]),'String',num2str(cell2mat(handles.acquisition.channels(ch,8))));
        set(handles.(['skip' chTagString]),'String',num2str(cell2mat(handles.acquisition.channels(ch,3))));
    end%end of loop through the channels
end%end of if statment - if number of channels isn't zero

%if any channel is not used make sure all channel options are disabled and
%the use button is unclicked
if nChannels<8
    for n=nChannels+1:8
        set(handles.(['expCh' num2str(n)]),'Enable','off');
        set(handles.(['skipCh' num2str(n)]),'Enable','off');
        set(handles.(['ZsectCh' num2str(n)]),'Enable','off');
        set(handles.(['starttpCh' num2str(n)]),'Enable','off');
        set(handles.(['cammodeCh' num2str(n)]),'Enable','off');
        set(handles.(['startgainCh' num2str(n)]),'Enable','off');
        set(handles.(['voltCh'  num2str(n)]),'Enable','off');
        set(handles.(['useCh'  num2str(n)]),'Value',0);
        set(handles.(['snapCh'  num2str(n)]),'Enable','off');
    end
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


%Flow settings
%Update the gui controls
for p=1:length(handles.acquisition.flow{4})
    set(handles.(['contentsP' num2str(p)]),'String',char(handles.acquisition.flow{4}(p).contents));
    set(handles.(['diameterP' num2str(p)]),'String',pump.getVolString(handles.acquisition.flow{4}(p).diameter));
    set(handles.(['flowRateP' num2str(p)]),'String',num2str((handles.acquisition.flow{4}(p).currentRate)));
%    set(handles.(['runP'
%    num2str(p)]),'Value',num2str((handles.acquisition.flow{4}(p).running)));
%    No point in doing this - would have to check if pump is running for it
%    to make sense but that is slow.
end

%Points
set(handles.pointsTable,'Data',handles.acquisition.points);
columnName={'Name','x (microns)','y (microns)','z drive position (microns)','PFS Offset','Group'};
columnName=[columnName handles.acquisition.channels(:,1)'];
set(handles.pointsTable,'ColumnName',columnName);
msgbox('Note: saved Z positions are not loaded into the positions table (to avoid potential lens crashes through the coverslip). Look at the pos.txt file for original Z positions.');


%Experimental info
set(handles.exptName,'String',char(handles.acquisition.info(1)));
%user and root are set automatically in the start up script of the gui
%Experimental details can be set in the callback of the enter details