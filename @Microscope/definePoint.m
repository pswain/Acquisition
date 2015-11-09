function [x, y, z, AF]=definePoint(obj)
%Defines a saved XYZ position based on the current state of the
%microscope
global mmc;
switch obj.Name
    case {'Batman', 'Batgirl'}
        %get position data from the microscope
        x=mmc.getXPosition('XYStage');
        y=mmc.getYPosition('XYStage');
        z=mmc.getPosition('TIZDrive');
        AF=mmc.getProperty('TIPFSOffset','Position');
        if ~isnumeric(AF)
            AF=str2double(char(AF));
        end
    case 'Robin'
        x=mmc.getXPosition('XYStage');
        y=mmc.getYPosition('XYStage');
        z=mmc.getPosition('ZStage');
        AF=0;
        
end

end
