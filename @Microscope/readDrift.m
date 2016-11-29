%Should be called with the PFS on.
%Uses the corrections made by the PFS to calculate the drift that has
%occured from an input reference z position.
%This will also set the Z drive to the input zref position.
%This is a version of the correctDrift script to be used by methods for z
%sectioning in which the PFS is left on

function obj=readDrift(obj,logfile,zref,PFSOffset)
global mmc;

if iscell(zref)
    zref=cell2mat(zref);
end

%Set the PFS offset if input before reading the drift value.
if nargin==4
    if iscell(PFSOffset)
        PFSOffset=cell2mat(PFSOffset);
    end
    %Set the offset only if the input offset is not already set - this will
    %save time in most cases
    currentOffset=mmc.getPosition('TIPFSOffset');
    if PFSOffset~=currentOffset
        logstring=strcat('Setting PFS offset to :',num2str(PFSOffset));writelog(logfile,2,logstring);
        mmc.setPosition('TIPFSOffset',PFSOffset);
    end
end

%get the (corrected) z drive position
currentZ=mmc.getPosition('TIZDrive');
newdrift=currentZ-zref;
drift=newdrift;
if abs(newdrift)-abs(drift)>4
    logstring=strcat('correctDrift script. High drift alert! Measured drift:',num2str(newdrift),'_microns. Will be ignored');writelog(logfile,2,logstring);
else
    logstring=strcat('readDrift script. Reference z position is:',num2str(zref));writelog(logfile,2,logstring);
    logstring=strcat('readDrift script. Cumulative drift is:',num2str(drift));writelog(logfile,2,logstring);
end

obj.Autofocus.Drift=drift;

%Finally wait until the PFS has completed refocusing the z drive - this may
%take some time if the PFSOffset has been changed
status=char(mmc.getProperty('TIPFSStatus','Status'));
while ~strcmp(status,'Locked in focus')
pause(0.05);
status=char(mmc.getProperty('TIPFSStatus','Status'));
end

