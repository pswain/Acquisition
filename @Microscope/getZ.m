function z=getZ(obj)
global mmc;
switch obj.Name
    case {'Batman'; 'Batgirl'};
        z=mmc.getPosition('TIZDrive');
    case 'Robin'
        z=mmc.getPosition('ZStage');
end

end