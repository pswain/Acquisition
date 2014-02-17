%function to get the scope to visit a defined point in xyz
%input 1 is the log file identifier for the experiment
%input 2 is a 1d cell array with the following fields:
%1 - name
%2 - x stage position (microns)
%3 - y stage position (microns) 
%4 - microscope z drive position (microns)
%5 - PFS offset position (microns)
%6 - Exposure time for exposure by point (ms, not used here)

%Input 3  - number of slices (1 if no stack)
%Input 4 - is the interval between slices if there is a stack being captured, 0 if it's a single slice.
%Input 5 is 1 if the PFS is on and locked (or was at the start of the
%experiment, 0 if not. If this is unknown input 3=2.


function[]=visitPoint(logfile,point,numSlices,sliceInterval,PFSon)
global mmc;
%move to XY position defined in point.
x=cell2mat(point(2));
y=cell2mat(point(3));
mmc.setXYPosition('XYStage',x,y);
fprintf(logfile,'%s',strcat('Moved to X:',num2str(x),', Y:',num2str(y)));
fprintf(logfile,'\r\n');
if PFSon==2
    PFSon=strcmp('Locked',mmc.getProperty('TIPFSStatus','Status'));
end
%Z positioning.

%z positioning is different depending on whether you're doing a stack or a
%single point.

%For a single point - just go to the defined z position

%For a stack: plan is to have the user mark the centre position of the stack -
%so they can focus on that - as in Deltavisions. Then move to top
%before imaging. So need to calculate the position to move to not
%just go to the marked Z position.
%Go up by floor(Number of slices/2) multipled by the slice spacing.
%NOTE - if the number of slices is even this means you won't collect an
%image at the actual marked position but at evenly spaced intervals
%around it.


if sliceInterval>0%then this is a stack capture - go to top of stack
%Can only use one z positioning mechanism - if PFS was locked at start of
%experiment use that
    if PFSon==1;
    ZTopPosition=cell2mat(point(5))-(sliceInterval*(floor(numSlices/2)));
    mmc.setProperty('TIPFSOffset', 'Position', num2str(ZTopPosition));
    fprintf(logfile,'%s',strcat('Moved to top of stack using PFS offset:',num2str(ZTopPosition)));
    fprintf(logfile,'\r\n');
    else
    ZTopPosition=cell2mat(point(4))-(sliceInterval*(floor(numSlices/2)));
    mmc.setPosition('TIZDrive',ZTopPosition);
    fprintf(logfile,'%s',strcat('Moved to top of stack using microscope Z drive:',num2str(ZTopPosition)));
    fprintf(logfile,'\r\n');
    end
else%this is the case of a single slice - no stack - go to defined Z position
    if PFSon==1;
    ZPosition=cell2mat(point(5));
    mmc.setProperty('TIPFSOffset', 'Position', num2str(ZPosition));
    fprintf(logfile,'%s',strcat('Moved to set Z position using PFS offset:',num2str(ZPosition)));
    fprintf(logfile,'\r\n');
    else
    ZPosition=cell2mat(point(4));
    mmc.setPosition('TIZDrive',ZPosition);
    fprintf(logfile,'%s',strcat('Moved to set Z position using microscope Z drive:',num2str(ZPosition)));
    fprintf(logfile,'\r\n');
    end
end
