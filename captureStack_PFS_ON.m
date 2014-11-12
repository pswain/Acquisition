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

function [stack maxvalue]=captureStack_PFS_ON(filename,thisZ, zinfo, offset, EM, E)
global mmc;
height=512;
width=512;
nSlices=zinfo(1);
sliceInterval=zinfo(2);
anyZ=zinfo(4);
stack=zeros(height,width,nSlices,'uint16');
pifPos=mmc.getPosition('PIFOC');%starting position of the PIFOC
if pifPos~= 50
    mmc.setPosition('PIFOC',50);
    pause(1);
    pifPos=mmc.getPosition('PIFOC');%starting position of the PIFOC
end
maxvalue=0;

LED=mmc.getProperty('DTOL-Switch','State');
switch(str2num(LED))
    case 1
        dac=[];
    case 2%The CFP LED - adjust DAC-1
        dac='DTOL-DAC-1';
    case 4%The GFP/YFP LED - adjust DAC-1
        dac='DTOL-DAC-2';
    case 8%The mCherry/cy5/tdTomato LED - adjust DAC-1
        dac='DTOL-DAC-3';
end

if (str2num(LED))==4
    expos=mmc.getExposure;
    mmc.setExposure(1);
    volts=mmc.getProperty(dac,'Volts');
    mmc.setProperty(dac,'Volts',0.1);
    mmc.snapImage();
    mmc.getImage;
    mmc.setProperty(dac,'Volts',volts);
    mmc.setExposure(expos);
end

if thisZ==1%this is a stack acquisition
    zStep=-floor(nSlices/2)+[0:nSlices-1];
    zStep=zStep*2*sliceInterval;
    [b index]=sort(abs(zStep));
    for zIndex=1:nSlices%start of z sectioning loop
        %PIFOC movement
%         zMov=2*sliceInterval*(-floor(nSlices/2)+z);
        zMov=zStep(index(zIndex));
        slicePosition=pifPos+zMov;
        %2nd term will be zero if no z sectioning
        %2* because for some reason PIFOC moves 0.5microns when you tell it
        %to move 1.
        mmc.setPosition('PIFOC',slicePosition);
        if zIndex>1;
            pause(.05);
        end
        mmc.snapImage();
        pause(.01);
        mmc.setPosition('PIFOC',pifPos);
        
        img=mmc.getImage;
        if abs(zMov)>6
            pause(.3);
        elseif abs(zMov)>4
            pause(.2);
        elseif abs(zMov>1)
            pause(.1);
        end
        
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
        %         stack(:,:,z+floor(nSlices/2)+1)=img2;
        stack(:,:,index(zIndex))=img2;
        
    end
    %Restore z position of PIFOC

    for z=1:nSlices
        sliceFileName=strcat(filename,'_',sprintf('%03d',z),'.png');
        imwrite(stack(:,:,z),char(sliceFileName));
    end
    
    %display the middle slice
    %cla;
    %imshow(stack(:,:,floor(nSlices/2)),[]);
    %drawnow;
else%single section acquisition
    %If any of the channels in this acquisition do z sectioning then need
    %to use the PIFOC to position focus to the middle of the stack. If not
    %then just capture an image.
    if anyZ==1
        z=nSlices/2;
        slicePosition=pifPos+(2*((z-1)*sliceInterval));
        mmc.setPosition('PIFOC',slicePosition+offset);
        pause(0.1);
    end
    mmc.snapImage();
    img=mmc.getImage;
    img2=typecast(img,'uint16');
    maxvalue=max(img2);%need to record the maximum measured value
    img2=E.*img2;
    img2=reshape(img2,[height,width]);
    stack(:,:,1)=img2;
    sliceFileName=strcat(filename,'_',sprintf('%03d'),'.png');
    if EM==1 || EM==3
        img2=flipud(img2);
    end
    imwrite(img2,char(sliceFileName));
    %imshow(img2,[]);
    %drawnow;
    mmc.setPosition('PIFOC',pifPos);
    
end




end
