function setAutofocusOffset(obj,offset)

global mmc;
switch obj.Name
    case {'Batman','Batgirl'}
        mmc.setPosition('TIPFSOffset',offset);
        pause(0.4);

end

end