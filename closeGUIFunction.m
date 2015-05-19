function closeGUIFucntion(hObject, eventdata, handles)

disp('multiDGUI close request function is running');

%Close all com ports
delete(instrfindall)
delete(hObject);



