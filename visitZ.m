%positions the plane of focus using Nikon Ti Z drive

%can be called with or without a "point" cell array.
%With a point: (logfile,zinfo,point)
%Input 1 - logfile
%Input 2  - zinfo (nslices, interval, PFSon, anyz, drift (in microns - recorded by the PFS))
%Input 3 - point cell array with the following columns:
%1 - name
%2 - x stage position (microns)
%3 - y stage position (microns) 
%4 - microscope z drive position (microns)
%5 - PFS offset position (microns)
%6 - Exposure time for exposure by point (ms, not used here)

%Without a point: Only the first 4 of the inputs above

%If anyz==1 (ie at least one channel does z sectioning) then the focus is
%moved to the bottom of the stack, taking either the input z position (if
%nargin>3) or the starting position of the z drive (if nargin==3) as the
%centre of the stack.

%If anyz==0 the focus is moved to the set position if input, corrected for the drift.


function[startingZ]=visitZ(varargin)
global mmc;
logfile=cell2mat(varargin(1));
zinfo=varargin{2};
numSlices=zinfo(1);
sliceInterval=zinfo(2);
pfsOn=zinfo(3);
anyZ=zinfo(4);
drift=zinfo(5);
if nargin>2
    logtext=varargin{3};
end
if nargin>3
point=varargin{4};
point=cell2mat(point(2:6));
end
logstring='visitZ script';writelog(logfile,logtext,logstring);
pause(0.5);
startingZ=mmc.getPosition('TIZDrive');
logstring=strcat('VisitZ script. Starting Z drive position is:',num2str(startingZ));writelog(logfile,logtext,logstring);
%Define the set Z position - either from a supplied point or just use
%starting Z.
if nargin>3%a defined point has been supplied
    setZ=point(3)+drift;
    logstring=strcat('Defined Z drive position from point:',num2str(point(3)));writelog(logfile,logtext,logstring);
else%no point supplied
    setZ=startingZ;
    logstring=strcat('No point input to visitZ. startingZ taken as set position.');writelog(logfile,logtext,logstring);
end
 
%Define the target Z position - either the bottom of the stack or just the set
%position
if anyZ==1%at least one channel does Z sectioning - need to move to the bottom of the stack.
    %calculate position at the top of the stack
    targetZ=setZ-(sliceInterval*(floor((numSlices-1)/2)));
    logstring=strcat('At least one channel does Z sectioning. Top of stack target position:',num2str(targetZ));writelog(logfile,logtext,logstring);
else%no points do Z sectioning. Move stage only to set position.
    targetZ=setZ;
    logstring=strcat('No points do Z sectioning. Use set Z position');writelog(logfile,logtext,logstring);
end
  
mmc.setPosition('TIZDrive',targetZ);
mmc.waitForDevice('TIZDrive');
logstring=strcat('Z drift:',num2str(drift));writelog(logfile,logtext,logstring);
logstring=strcat('Z drive moved to position:',num2str(targetZ));writelog(logfile,logtext,logstring);
