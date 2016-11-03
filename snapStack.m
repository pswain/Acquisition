%Snaps and displays a stack (using the stack display GUI) based on input
%channel information.

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

%z vector:
%1. number of sections
%2. spacing in microns
%3. PFS on (1 or 0 - only added on start of experiment)
%4. anyZ (1 if any channel does z sectioning, 0 if not, only added at start of experiment
%5. drift - the drift in the z plane, recorded during a timlapse by querying the position of the z drive after the pfs has corrected it.
%6. method - method of z sectioning. 1. 'PIFOC' or 2. 'PIFOC_PFSON' or 3. 'PFS'


function [imageStack]=snapStack(channel, handles)
global mmc;
microscope=handles.acquisition.microscope;
z=handles.acquisition.z;

mmc.stopSequenceAcquisition;
mmc.setExposure(cell2mat((channel(2))));
mmc.setConfig('Channel', char(channel(1)));
mmc.waitForConfig('Channel', char(channel(1)));
microscope.lightToCamera;
title=strcat(char(channel(1)),'.  ',num2str(cell2mat(channel(2))),'ms');
%Set LED voltage based on information in acqData.channels
microscope.setLEDVoltage(channel{8});
%Camera mode
microscope.setPort(channel,[],[]);
%Set the EM gain
if channel{6}==1 || channel{6}==3
    microscope.setEMGain(channel{7});
end
pfsOn=microscope.getAutofocusStatus;
[imageStack maxValue]= microscope.captureStack([],channel{4},z,[],channel{6},1);

displayStackGUI=displayStack(imageStack);

% %Get the highest pixel value in the image for display:
% highest=max(image(:));
% 
% 
% figure;
% set(gcf,'NumberTitle','off');
% set(gcf,'Name',title);
% imshow(image,[]);
% text(7,15,strcat('Maximum value:',num2str(highest),'. Saturation at: ',num2str(saturation)),'Color','y');
% if highest>=saturation
%     warndlg('There are saturation (maximum values) in your image. Results will not be quantitative. Adjust gain or exposure down or EPG up','!! Saturation Warning !!');
% end
