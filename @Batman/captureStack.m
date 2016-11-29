function [stack,maxValue]=captureStack(obj,filename,thisZ,zInfo,offset,EM,E,point)
%Captures and saves a Z stack on Batman. There are 3
%alternative methods for moving in Z, determined by zInfo(6).

%Before calling this function:
%1. Imaging configuration (LED, exposure time, filter positions etc) must
%   be set
%2. If any channel in the acquisition does z sectioning the z position
%should be moved to the bottom of the stack using the
%microscope Z drive. If not, the focus should be positioned at
%the desired focal position.

%Arguments:
%1. filename - complete path for a directory to save the files into. Note - a
%slice number is added to this filename when each image is saved
%2. thisZ - 1 if this is a stack
%3. acqData.z - with the z sectioning information for this experiment -
%nSlices and interval
%4. offset value - INPUT OFFSET IS NOT USED - NOW USED TO
%CONTROL THE VALUES SENT TO THE PIFOC
%5. EM - 1 if this channel uses the EM mode of the camera (ie image should
%be flipped)
%6. E - a scalar to multiply the data by (if in the EM mode) - useful for
%correcting for any changes in exposure time that have occured to avoid
%saturation in the data.
%7. Point - row of the acqData.points cell array that refers to
%the current position.
global mmc;
nSlices=zInfo(1);
sliceInterval=zInfo(2);
anyZ=zInfo(4);
height=obj.ImageSize(1);
width=obj.ImageSize(2);
stack=zeros(height,width,nSlices);
%Set the device used for sectioning and determine if PFS should
%be kept on


%Image capture code. First determine if this is a stack
%acquisition
if thisZ==0
    %If any of the channels in this acquisition do z sectioning then the
    %focus should have been positioned at the bottom of the stack before
    %captureStack is called. In this case you need to use the PIFOC to
    %return to the middle of the stack. This only applies if the PFS
    %is off (ie z sectioning method 1)
    if zInfo(6)==1
        startPos=mmc.getPosition('PIFOC');
        if anyZ==1
            z=nSlices/2;
            slicePosition=startPos+(2*((z-1)*sliceInterval));%Multiplied by 2 because PIFOC divides all distances sent to it in half.
            mmc.setPosition('PIFOC',slicePosition);
            pause(0.005);
        end
        mmc.setPosition('PIFOC',startPos);
    end
    mmc.snapImage();
    img=mmc.getImage;
    img2=typecast(img,'uint16');
    maxValue=max(img2);%need to record the maximum measured value
    img2=E.*img2;
    img2=reshape(img2,[height,width]);
    if EM==1 || EM==3
        img2=flipud(img2);
    end
    stack(:,:,1)=img2;
    %Save the image if a filename was input
    if ~isempty(filename)
        sliceFileName=strcat(filename,'_',sprintf('%03d'),'.png');
        imwrite(img2,char(sliceFileName));
    end
else
    %Z stack code is different for the different sectioning methods
    %Split into different methods to keep code simpler
    switch zInfo(6)
        case 1
            [stack, maxValue]=obj.captureStackPIFOC(filename,zInfo,EM,E);
        case 2
            [stack, maxValue]=obj.captureStackPFSOn(filename,zInfo,EM,E);
    end
end

end
