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
function [image]=snap(channel)
satFactor=729531;
satPower=-1.001;

global mmc;

mmc.stopSequenceAcquisition;
mmc.setExposure(cell2mat((channel(2))));
mmc.setConfig('Channel', char(channel(1)));
mmc.waitForConfig('Channel', char(channel(1)));
mmc.setProperty('TILightPath', 'Label','2-Left100');%send light to the camera
title=strcat(char(channel(1)),'.  ',num2str(cell2mat(channel(2))),'ms');

%Also set LED voltage based on information in acqData.channels
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
if ~isempty(dac)
mmc.setProperty(dac,'Volts', channel{8});
end
switch cell2mat(channel(6))
    case 1
        mmc.setProperty ('Evolve','Port','Multiplication Gain');
        gain=cell2mat(channel(7));
        epg=cell2mat(channel(8));
        mmc.setProperty ('Evolve','MultiplierGain',num2str(gain));
%        mmc.setProperty('Evolve', 'PP2 QUANT-VIEW (E)',num2str(epg));
        title=strcat(title,'. EMCCD, gain:',num2str(gain),'. EPG:',num2str(epg));
    case 3
         mmc.setProperty ('Evolve','Port','Multiplication Gain');
        gain=cell2mat(channel(7));
        epg=cell2mat(channel(8));
        mmc.setProperty ('Evolve','MultiplierGain',num2str(gain));
%        mmc.setProperty('Evolve', 'PP2 QUANT-VIEW (E)',num2str(epg));
        title=strcat(title,'. EMCCD, gain:',num2str(gain),'. EPG:',num2str(epg));
    case 2
        mmc.setProperty ('Evolve','Port','Normal');
        title=strcat(title,'. CCD');
end
mmc.waitForDevice('Evolve');
mmc.snapImage; 
img=mmc.getImage; 
width=mmc.getImageWidth; 
height=mmc.getImageHeight; 
img2=typecast(img,'uint16'); 
image=reshape(img2,[height,width]);
%Process the image if it was read from the EM port
%Flip vertically
%Work out the saturation value
switch cell2mat(channel(6))
    case 1 %EM port
        image=flipud(image);
        satLevelE1=satFactor.*(gain.^satPower);%saturation level for this gain if electrons per grey level is set to 1
        %saturation=floor(1/epg*satLevelE1);%Saturation level taking EPG into account
        saturation=satLevelE1;
    case 3
        image=flipud(image);
        satLevelE1=satFactor.*(gain.^satPower);%saturation level for this gain if electrons per grey level is set to 1
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
