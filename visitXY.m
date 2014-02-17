%function to get the scope to visit a defined point in xy
%input 1 is the log file identifier for the experiment
%input 2 is a 1d cell array with the following fields:
%1 - name
%2 - x stage position (microns)
%3 - y stage position (microns) 
%4 - microscope z drive position (not used)
%5 - PFS offset position (not used)
%6 - Exposure time for exposure by point (not used)
%input 3 is a 1 if the PFS is to be used in this experiment and a 0 if it
%isn't


function[]=visitXY(logfile,point,pfsOn,texthandle)

global mmc;


%move to XY position defined in point input.
x=cell2mat(point(2));
y=cell2mat(point(3));
mmc.setXYPosition('XYStage',x,y);
mmc.waitForDevice('XYStage');
logstring=strcat('Moved to X:',num2str(x),', Y:',num2str(y));writelog(logfile,texthandle,logstring);


%this makes sure the Z drive is focused at the new point (through
%adjustments by the PFS)
if pfsOn==1
    status=mmc.getProperty('TIPFSStatus','Status');
    while strcmp(status,'Focusing')==1;
        pause(.2);
        status=mmc.getProperty('TIPFSStatus','Status');
    end
end

