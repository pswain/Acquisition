function z=getZ(obj)
global mmc;
switch obj.Name
    case 'Batman'
        z=mmc.getPosition('TIZDrive');
    case 'Robin'
        z=mmc.setPosition('ZStage');
end

end