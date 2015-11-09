disp('Matlab close function is running');
global mmc;
if ~isempty(mmc)
    mmc.unloadAllDevices;
    pause(1);
end
%Close all com ports
delete(instrfindall)