function [stack,maxvalue]=captureStackPIFOC(obj,filename,zInfo,EM,E)
%Captures and saves a z stack on Batman using the PIFOC sectioning device.
%The focus position should be moved to the bottom of the stack before this
%function is called
global mmc;
nSlices=zInfo(1);
sliceInterval=zInfo(2);
anyZ=zInfo(4);
height=obj.ImageSize(1);
width=obj.ImageSize(2);
stack=zeros(height,width,nSlices);

startPos=mmc.getPosition('PIFOC');%starting position of the sectioning device
maxvalue=0;
%Need to multiply distances by 2 if using PIFOC because for some reason PIFOC moves 0.5microns when you tell it
%to move 1.
p=2;
%Also PIFOC can't accept negative numbers - so define an
%offset to compensate for that
%Calculate the first slice position (lowest focus position
%in the stack)
z=1;
firstSlice=startPos-((nSlices-1)*p*sliceInterval)/2+(p*((z-1)*sliceInterval));
offset=abs(firstSlice);
%make sure the PFS or other focus device is off
locked=obj.Autofocus.isLocked;
if locked
    obj.Autofocus.switchOff;
end
              
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
            