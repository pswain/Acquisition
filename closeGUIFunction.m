function closeGUIFucntion(hObject, eventdata, handles)

disp('multiDGUI close request function is running');
global mmc;
mmc.unloadAllDevices;
%Close all com ports
delete(instrfindall)
delete(hObject);



