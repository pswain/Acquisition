function closeGUIFucntion(hObject, eventdata, handles)

disp('multiDGUI close request function is running');
global mmc;
if ~isempty(mmc)
mmc.unloadAllDevices;
end
%Close all com ports
delete(instrfindall)
delete(hObject);



