function lightToCamera(obj)
%Directs 100% of light to the camera (where light path is automated)
switch obj.Name
    
    case {'Batman','Batgirl'}
        global mmc
        mmc.setProperty('TILightPath', 'Label','2-Left100');%send light to the camera
        mmc.waitForDevice('TILightPath');
    case 'Robin'
        disp('Ensure light path slider is in the correct position');
end

end