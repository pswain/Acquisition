function obj=correctDrift(obj,logfile, zref, offset)
%Uses the autofocus device to calculate the drift that has occured from an input
%reference z position.
%This will also set the Z drive to the input zref position.
global mmc;

%Switch off the autofocus device
obj.Autofocus.switchOff;
pause(1);%Gives enough time for a PFS to switch off - is pretty slow

%move the z drive to the reference position (+drift that has already occured)
if iscell(zref)
    zref=cell2mat(zref);
end
obj.setZ(zref+obj.Autofocus.Drift);

%turn autofocus device on - will correct for any further drift that has occurred since the last
%time drift was measured.
obj.Autofocus.switchOn(true);
obj.Autofocus.Status=obj.Autofocus.getStatus;
if strcmp(obj.Autofocus.Status,'Locked')==1;
    if nargin==4
        if iscell(offset)
            offset=cell2mat(offset);
        end
        obj.setOffset(offset);
        pause(2);%Movement of the offset is slow - need to wait for that
    end
    %get the (corrected) z drive position
    currentZ=obj.getZ;
    newdrift=currentZ-zref;
    if abs(newdrift)-abs(drift)>4
        logstring=strcat('correctDrift script. High drift alert! Measured drift:',num2str(newdrift),'_microns. Will be ignored');writelog(logfile,2,logstring);
    else
        obj.Autofocus.drift=newdrift;
        logstring=strcat('correctDrift script. Reference z position is:',num2str(zref));writelog(logfile,2,logstring);
        logstring=strcat('correctDrift script. Cumulative drift is:',num2str(drift));writelog(logfile,2,logstring);
    end
else
    logstring=strcat('correctDrift script. Autofocus device status is: ',char(obj.Autofocus.Status),'. No change recorded to drift.');writelog(logfile,2,logstring);
end

end