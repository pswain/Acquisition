function saveSettings_Callback(hObject, eventdata)
%

handles=guidata(hObject);
folder=uigetdir(char(handles.acquisition.info(3)),'Select or create folder to save acquisition settings');
if folder == 0 %if the user pressed cancel, then we exit this callback
    return
end
saveAcquisition(handles.acquisition,folder);
guidata(hObject, handles)