function setZ(obj,z)
if nargin==1
    drift=0;
end
global mmc;
switch obj.Name
    case 'Batman'
        mmc.setPosition('TIZDrive',z);
        pause(0.4);
    case 'Robin'
        mmc.setPosition('ZStage',z);
        pause(0.4);
end

end