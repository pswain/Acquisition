function setZ(obj,z)

global mmc;
switch obj.Name
    case {'Batman','Batgirl'}
        mmc.setPosition('TIZDrive',z);
        pause(0.4);
    case 'Robin'
        mmc.setPosition('ZStage',z);
        pause(0.4);
end

end