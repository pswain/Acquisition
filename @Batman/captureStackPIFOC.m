function [stack,maxvalue]=captureStackPIFOC(obj,filename,zInfo,EM,E)
%Captures and saves a z stack on Batman using the PIFOC sectioning device (with the PFS switched off).
%% Initialize variables
global mmc;
nSlices=zInfo(1);
sliceInterval=zInfo(2);
height=obj.ImageSize(1);
width=obj.ImageSize(2);
stack=zeros(height,width,nSlices);
maxvalue=0;

%% make sure the PFS or other focus device is off
locked=obj.Autofocus.isLocked;
if locked
    obj.Autofocus.switchOff;
end

logstring=['captureStackPIFOC (Batman). Z drive position before stack capture is: ' num2str(mmc.getPosition('TIZDrive')) '. ' datestr(clock)];A=writelog(obj.LogFile,1,logstring);


%% Move the focus position to the bottom of the stack (using the microscope Z
%drive
startZDrivePos=obj.getZ;%Z drive position - centre of stack
nSlices=zInfo(1);
firstSlice=startZDrivePos-((nSlices-1)/2*sliceInterval);
obj.setZ(firstSlice);

%% Prepare PIFOC positioning 
startPos=mmc.getPosition('PIFOC');%starting position of the sectioning device (will be 0 for the PIFOC)
%Need to multiply distances by 2 if using PIFOC because for some reason PIFOC moves 0.5microns when you tell it
%to move 1.
p=2;
%Also PIFOC can't accept negative numbers - so define an
%offset to compensate for that
%Calculate the first slice position (lowest focus position
%in the stack)
z=1;
firstSlice=p*(startPos-((nSlices-1)/2*sliceInterval));
%firstSlice=startPos-((nSlices-1)*p*sliceInterval)/2+(p*((z-1)*sliceInterval));
offset=abs(firstSlice);

%% Loop through the sections, taking and saving images
for z=1:nSlices%start of z sectioning loop
    %Position of current slice    
    slicePosition=startPos-((nSlices-1)*p*sliceInterval)/2+(p*((z-1)*sliceInterval));
    mmc.setPosition('PIFOC',slicePosition+offset);
    pause(.01);
    mmc.snapImage();
    img=mmc.getImage;
    img2=typecast(img,'uint16');
    %need to record the maximum measured value to return
    %This is done before any correction for changes in exposure time
    maxthisz=max(img2);
    maxvalue=max([maxthisz maxvalue]);
    img2=reshape(img2,[height,width]);
    if EM==1 || EM==3
        img2=flipud(img2);
    end
    img2=E.*img2;
    
    stack(:,:,z)=img2;
    if ~isempty(filename)
        sliceFileName=strcat(filename,'_',sprintf('%03d',z),'.png');
        imwrite(img2,char(sliceFileName));
    end
end

%Restore z position
mmc.setPosition('PIFOC',startPos);
obj.setZ(startZDrivePos);

            