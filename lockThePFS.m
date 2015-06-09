%To be run if the PFS has failed to lock prior to taking an image or stack
%Moves the Z drive to try to find a position at which the PFS will lock.
%First down - to a total of 60um.
%then up - to a total of 30um - afraid of going too far and cracking the
%cover slip.
%If no lock is found returns success=0
%If the PFS does lock then success=1


function [success]=lockThePFS(varargin)
global mmc;
if nargin==1
    logfile=varargin{:};
end
zPosition=mmc.getPosition('ZDrive');
status=char(mmc.getProperty('PFSStatus','Status'));
if nargin==1
fprintf(logfile,'%s','Running lock the PFS script');
fprintf(logfile,'\r\n');
fprintf(logfile,'%s',strcat('PFS status is: ',status));
fprintf(logfile,'\r\n');
end
%make sure we really know if it's locked or not - ie it's finished
%activating
activating=strcmp(status,'Activating');
if activating==1
   while activating==1
    pause(0.2);
    status=char(mmc.getProperty('PFSStatus','Status'));
    activating=strcmp(status,'Activating');
   end
end
success=strcmp(status,'Locked');
if success==1
   if nargin==1
       fprintf(logfile,'%s',strcat('Lock found at Z drive position',num2str(ZPosition)));
       fprintf(logfile,'\r\n'); 
   end
   return
end
if strcmp(status,'Lock Failed')==1 
%move z drive down 60 um to try to find a lock
    for n=1:6
        newPosition=zPosition-n*10;
        mmc.setPosition('ZDrive',newPosition);
        if nargin==1
        fprintf(logfile,'%s',strcat('Moved Z drive down to:',num2str(newPosition)));
        fprintf(logfile,'\r\n'); 
        end
        pause(0.6);
        status=char(mmc.getProperty('PFSStatus','Status'));
        success=strcmp(status,'Locked');
        if success==1
            if nargin==1
            fprintf(logfile,'%s','Lock found.');
            fprintf(logfile,'\r\n'); 
            end
            return
        end
    end
%Moving z drive down hasn't worked - try moving up - but not too far - only
%30um in 5um increments
    for n=1:6
        newPosition=zPosition+n*5;
        mmc.setPosition('ZDrive',newPosition);
        if nargin==1
            fprintf(logfile,'%s',strcat('Moved Z drive up to:',num2str(newPosition)));
            fprintf(logfile,'\r\n'); 
        end
        pause(0.6);
        status=char(mmc.getProperty('PFSStatus','Status'));
        success=strcmp(status,'Locked');
        if success==1
            if nargin==1
                fprintf(logfile,'%s','Lock found.');
                fprintf(logfile,'\r\n'); 
            end
            return
        end
    end
%Lock has failed - write error message here
    if nargin==1
        fprintf(logfile,'%s','Failed to find lock.');
        fprintf(logfile,'\r\n'); 
    end
else
    
    if nargin==1
        fprintf(logfile,'%s',strcat('PFS status is:',status,'. Cannot find lock'));
        fprintf(logfile,'\r\n'); 
    end
    return%write error message - status is neither locked nor lock failed
end



