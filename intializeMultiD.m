%Prepares the microscope for a multidimensional acquisition.
%No input arguments but global variables gui, acq and mmc must be
%present
%
%Output arguments:
%logfile - for recording details of the acquisition

function [root,logfile, height, width]=intializeMultiD()
global mmc;
global gui;
global acq;
%clear all previous acquisitions and close figure windows
gui.closeAllAcquisitions();
gui.clearMessageWindow();
mmc.stopSequenceAcquisition;
close all;

%Initialisation functions: setting evolve gain and any
%others - setting the initial state of the TTL switch also - set to zero.
%Triggering events for the pump will occur on a falling edge at digital 4 -
%to trigger set to 00010000 (32) then down to zero again

mmc.setShutterDevice('TTL Shutter (DT)');
mmc.setProperty('Evolve', 'Gain', '2');
mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
mmc.setProperty('TTL Switch (DT)','State', '0');
mmc.setProperty('LightPath','Label','Left100');%all light should go to the camera
pause on;
today=date;
root=strcat('C:\AcquisitionData\Swain Lab\Ivan\RAW DATA\',today(8:11),'\',today(4:6),'\', date);
disp('Acquisition in progress: press ctrl+C to abort acquisition');
logfile=fopen(strcat(root,'\',acqName),'w');%Then can write to logfile
%later using fprintf(logfile,'string goes here');
height=mmc.getImageHeight;
width=mmc.getImageWidth;


end
