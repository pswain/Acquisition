%Snaps and displays an image (on the current figure/axes) based on input
%channel information. DOES NOT TAKE OFFSET INTO ACCOUNT.

%channel cell array:

%Column 1 - name of channel
%Columnn 2 - exposure time in ms
%Column 3 - 1 if exposing by point, 0 if using time in col 2 for all points
%Column 4 - 1 if using Z sectioning, 0 if not
%Column 5 - z offset in microns
%Column 6 - Camera mode. 1 if EM, 2 if CCD
%Column 7 - Starting EM gain (not used if camera in CCD mode, default 270).
%Column 8 - LED voltage
%mode, default 1).
function [image]=snap(channel, microscope)
satFactor=729531;
satPower=-1.001;

global mmc;

mmc.stopSequenceAcquisition;
mmc.setExposure(cell2mat((channel(2))));
mmc.setConfig('Channel', char(channel(1)));
mmc.waitForConfig('Channel', char(channel(1)));
microscope.lightToCamera;
title=strcat(char(channel(1)),'.  ',num2str(cell2mat(channel(2))),'ms');

%Also set LED voltage based on information in acqData.channels
microscope.setLEDVoltage(channel{8});
%Camera mode
title=microscope.setCamMode(channel{6},title,channel{7});

mmc.snapImage;
img=mmc.getImage; 
width=mmc.getImageWidth; 
height=mmc.getImageHeight; 
img2=typecast(img,'uint16'); 
image=reshape(img2,[width,height]);
%Process the image if it was read from the EM port
%Flip vertically
%Work out the saturation value
switch cell2mat(channel(6))
    case 1 %EM port
        EMgain=channel{7};
        image=flipud(image);
        satLevelE1=satFactor.*(EMgain.^satPower);%saturation level for this gain if electrons per grey level is set to 1
        %saturation=floor(1/epg*satLevelE1);%Saturation level taking EPG into account
        saturation=satLevelE1;
    case 3
        EMgain=channel{7};
        image=flipud(image);
        satLevelE1=satFactor.*(EMgain.^satPower);%saturation level for this gain if electrons per grey level is set to 1
        %saturation=floor(1/epg*satLevelE1);%Saturation level taking EPG into account
        saturation=satLevelE1;
    case 2%normal port - saturation level is the 16 bit limit
        saturation=2^16;
end

%Get the highest pixel value in the image for display:
highest=max(image(:));


figure;
set(gcf,'NumberTitle','off');
set(gcf,'Name',title);
imshow(image,[]);
text(7,15,strcat('Maximum value:',num2str(highest),'. Saturation at: ',num2str(saturation)),'Color','y');
if highest>=saturation
    warndlg('There are saturation (maximum values) in your image. Results will not be quantitative. Adjust gain or exposure down or EPG up','!! Saturation Warning !!');
end
