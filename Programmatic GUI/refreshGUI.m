
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