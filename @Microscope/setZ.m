function setZ(obj,z)

global mmc;
switch obj.Name
    case {'Batman','Batgirl'}
        mmc.setPosition('TIZDrive',z);
        logstring=['TI ZDrive position set to: ' num2str(z) '. ' datestr(clock)];A=writelog(obj.LogFile,1,logstring);
        pause(0.4);
    case 'Robin'
        mmc.setPosition('ZStage',z);
        pause(0.4);
        logstring=['ZStage position set to: ' num2str(z) '. ' datestr(clock)];A=writelog(obj.LogFile,1,logstring);

end

end