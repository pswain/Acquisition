%Captures and saves a Z stack. Z position is moved using the PIFOC
%Before calling this function:
%1. Imaging configuration (LED, exposure time, filter positions etc) must
%   be set
%2. If any channel in the acquisition does z sectioning the z position
%should be moved to the top of the stack. If not the focus should be
%positioned at the desired focal position

%Arguments:
%1. filename - complete path for a directory to save the files into. Note - a
%slice number is added to this filename when each image is saved
%2. thisZ - 1 if this is a stack
%3. acqData.z - with the z sectioning information for this experiment -
%nSlices and interval
%4. offset value - to position stack in a non standard place
%5. EM - 1 if this channel uses the EM mode of the camera (ie image should
%be flipped)
%6. E - a scalar to multiply the data by (if in the EM mode) - useful for
%correcting for any changes in exposure time that have occured to avoid
%saturation in the data.

function [stack maxvalue]=captureStack(filename,thisZ, zinfo, offset, EM, E)
global mmc;
height=512;
width=512;
nSlices=zinfo(1);
sliceInterval=zinfo(2);
anyZ=zinfo(4);
stack=zeros(height,width,nSlices);
pifPos=mmc.getPosition('PIFOC');%starting position of the PIFOC 
maxvalue=0;


    
    
if thisZ==1%this is a stack acquisition
    %make sure the PFS is off
PFSLocked=strcmp(mmc.getProperty('TIPFSStatus','Status'),'Locked');
if PFSLocked==1
    mmc.setProperty('TIPFSStatus','State','Off');
    pause (0.4);
end
    for z=1:nSlices%start of z sectioning loop 
        %PIFOC movement
        slicePosition=pifPos+(2*((z-1)*sliceInterval));
        %2nd term will be zero if no z sectioning
        %2* because for some reason PIFOC moves 0.5microns when you tell it
        %to move 1.
        mmc.setPosition('PIFOC',slicePosition+offset);
        pause(0.1);
        mmc.snapImage();
        img=mmc.getImage;
        img2=typecast(img,'uint16');
        %need to record the maximum measured value to return
        %This is done before any correction for changes in exposure time
        maxthisz=max(img2);
        maxvalue=max([maxthisz maxvalue]);
        img2=reshape(img2,[height,width]);
        sliceFileName=strcat(filename,'_',sprintf('%03d',z),'.png');
        if EM==1 || EM==3
            img2=flipud(img2);
        end    
        img2=E.*img2;
        stack(:,:,z)=img2;
        imwrite(img2,char(sliceFileName));
    end
        
        %display the middle slice
        %cla;
        %imshow(stack(:,:,floor(nSlices/2)),[]);
        %drawnow;
        %Restore z position of PIFOC
mmc.setPosition('PIFOC',pifPos);
else%single section acquisition
    %If any of the channels in this acquisition do z sectioning then need
    %to use the PIFOC to position focus to the middle of the stack. If not
    %then just capture an image.
    if anyZ==1
       z=nSlices/2;
       slicePosition=pifPos+(2*((z-1)*sliceInterval));
       mmc.setPosition('PIFOC',slicePosition+offset);
       pause(0.5);
    end
    mmc.snapImage();
    img=mmc.getImage;
    img2=typecast(img,'uint16');
    maxvalue=max(img2);%need to record the maximum measured value
    img2=E.*img2;
    img2=reshape(img2,[height,width]);
    stack(:,:,1)=img2;
    sliceFileName=strcat(filename,'_',sprintf('%03d'),'.png');
    if EM==1
        img2=flipud(img2);
    end
    imwrite(img2,char(sliceFileName));
    %imshow(img2,[]);
    %drawnow;
    mmc.setPosition('PIFOC',pifPos);

end

    


end
