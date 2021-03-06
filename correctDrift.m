%Should be called with the PFS off.
%Uses the PFS to calculate the drift that has occured from an input
%reference z position.
%This will also set the Z drive to the input zref position.


function drift=correctDrift(logfile,zref,drift,PFSOffset)
global mmc;
if nargin==2
    drift=0;
end
%The following lines are not necessary because the PFS is automatically
%switched off when you alter the TIZDrive position - this is true on
%Batgirl - needs tested on Batman
% mmc.setProperty('TIPFSStatus','State','Off');
% pause(1);%Gives it time to switch off - is pretty slow
%move the z drive to the reference position (+drift that has already occured)
if iscell(zref)
    zref=cell2mat(zref);
end
mmc.setPosition('TIZDrive',zref+drift);
pause(0.4);
%turn PFS on - will correct for any further drift that has occurred since the last
%time drift was measured.
mmc.setProperty('TIPFSStatus','State','On');
pause(.5);

status=mmc.getProperty('TIPFSStatus','Status');

while strcmp(status,'Focusing')==1 || strcmp(status,'Activating');
    pause(.5);
    status=mmc.getProperty('TIPFSStatus','Status');
end

if strcmp(status,'Locked')==1;
    if nargin==4
        if iscell(PFSOffset)
            PFSOffset=cell2mat(PFSOffset);
        end
        mmc.setPosition('TIPFSOffset',PFSOffset);
        pause(2);%Movement of the offset is slow - need to wait for that
    end
    %get the (corrected) z drive position
    currentZ=mmc.getPosition('TIZDrive');
    newdrift=currentZ-zref;
    if abs(newdrift)-abs(drift)>4
        logstring=strcat('correctDrift script. High drift alert! Measured drift:',num2str(newdrift),'_microns. Will be ignored');writelog(logfile,2,logstring);
    else
        drift=newdrift;
        logstring=strcat('correctDrift script. Reference z position is:',num2str(zref));writelog(logfile,2,logstring);
        logstring=strcat('correctDrift script. Cumulative drift is:',num2str(drift));writelog(logfile,2,logstring);
    end
else
    logstring=strcat('correctDrift script. PFS status is: ',char(status),'. No change recorded to drift.');writelog(logfile,2,logstring);
end

end