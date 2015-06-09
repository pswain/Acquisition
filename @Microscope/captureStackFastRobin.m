function [stack,maxvalue]=captureStackFastRobin(obj,chInfo,zInfo,acqData)
%Captures and saves a Z stack using the current microscope. Z
%position is moved using the appropriate device for this
%microscope. If Batman is in use then there are 3 alternative
%methods for moving in Z, determined by zInfo(6).

%Before calling this function:
%1. Imaging configuration (LED, exposure time, filter positions etc) must
%   be set
%2. If any channel in the acquisition does z sectioning the z position
%should be moved to the top of the stack before calling this.
%If not, the focus should be positioned at the desired focal position.

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
global mmc;
fprintf('no longer uses passed height/width\n');
height=obj.ImageSize(1);
width=obj.ImageSize(2);

stack=zeros(height,width,length(zInfo.zNumInt));
%Set the device used for sectioning
switch obj.Name
    case 'Batman'
        switch zInfo(6)
            case 1
                sectDevice='PIFOC';
            case 2
                sectDevice='PIFOC';
            case 3
                sectDevice='PFS';
        end
    case 'Robin'
        sectDevice='ZStage';
    case 'Batgirl'
        sectDevice='ZStage';
end

maxvalue=0;
%Need to multiply distances by 2 if using PIFOC because for some reason PIFOC moves 0.5microns when you tell it
%to move 1.
if strcmp(sectDevice,'PIFOC')
    p=2;
else
    p=1;
end
for zInd=1:length(zInfo.slicePosition)
    if zInd>1
        mmc.setPosition(sectDevice,zInfo.slicePosition(zInd));
        mmc.waitForDevice(sectDevice);
    end
    for chIndex=1:length(chInfo)
        if chInfo{chIndex}.chSlicesToTakePic(zInd)
            %set exposure and dye configuration (filters and LEDs)
            mmc.setExposure(chInfo{chIndex}.expos);
            mmc.setConfig('Channel', chInfo{chIndex}.chName);
            pause(.1);
%             mmc.waitForConfig('Channel', chInfo{chIndex}.chName);
            %Set LED voltage based on information in acqData.channels
            acqData.microscope.setLEDVoltage(acqData.channels{chIndex,8});
            acqData.microscope.setPort(acqData.channels(chIndex,:),chInfo{chIndex}.CHsets);
            
            logstring=strcat('Channel:',chInfo{chIndex}.chName,' set at:',datestr(clock));A=writelog(chInfo{chIndex}.logfile,1,logstring);
            logstring=strcat('Exposure time:',num2str(chInfo{chIndex}.expos),'ms');A=writelog(chInfo{chIndex}.logfile,1,logstring);
            %Need to calculate E - correction factor for any changes in exposure
            %time that may have occured during the timelapse due to the threat of
            %approaching saturation
            
            mmc.snapImage();
            img=mmc.getImage;
            img2=typecast(img,'uint16');
            %need to record the maximum measured value to return
            %This is done before any correction for changes in exposure time
            maxthisz=max(img2);
            maxvalue=max([maxthisz maxvalue]);
            img2=reshape(img2,[height,width]);
            sliceFileName=strcat(chInfo{chIndex}.filename,'_',sprintf('%03d',zInfo.zNumInt(zInd)),'.png');
            if chInfo{chIndex}.EM==1 || chInfo{chIndex}.EM==3
                img2=flipud(img2);
            end
            img2=chInfo{chIndex}.E.*img2;
            stack(:,:,zInfo.zNumInt(zInd))=img2;
            imwrite(img2,char(sliceFileName));
        end
    end
end