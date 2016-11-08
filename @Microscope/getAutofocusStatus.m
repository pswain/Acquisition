function status=getAutofocusStatus(obj,logfile)
%Called by runAcquisition among others. Returns true if the the AF device is usable
%otherwise false
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