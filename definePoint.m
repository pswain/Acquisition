%This script gets positional information from the microscope and returns
%it. Used to define points for visiting.

%Needs the micromanager core (mmc) as an input

function [x y z PFS]=definePoint()
global mmc;
%get position data from the microscope
x=mmc.getXPosition('XYStage');
y=mmc.getYPosition('XYStage');
z=mmc.getPosition('TIZDrive');
PFS=mmc.getProperty('TIPFSOffset','Position');
if ~isnumeric(PFS)
    PFS=str2double(char(PFS));
end
PFS=str2double(char(PFS));


