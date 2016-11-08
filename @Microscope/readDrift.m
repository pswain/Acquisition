%Should be called with the PFS on.
%Uses the corrections made by the PFS to calculate the drift that has
%occured from an input reference z position.
%This will also set the Z drive to the input zref position.
%This is a version of the correctDrift script to be used by pfs on methods
%for z sectioning

function drift=readDrift(obj,logfile,zref,drift,PFSOffset)
global mmc;
if nargin==2
    drift=0;
end
%move the z drive to the reference position (+drift that has already occured)
if iscell(zref)
    zref=cell2mat(zref);
end
mmc.setPosition('TIZDrive',zref+drift);
pause(0.4);
%turn PFS on - will correct for any further drift that has occurred since the last
%time drift was measured.
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
    logstring=strcat('readDrift script. Reference z position is:',num2str(zref));writelog(logfile,2,logstring);
    logstring=strcat('readDrift script. Cumulative drift is:',num2str(drift));writelog(logfile,2,logstring);
end


