function enterDetails_Callback(hObject,eventdata)
%User input of experiment details to be recorded in the log file
handles=guidata(hObject);
previous=char(handles.acquisition.info(4));
handles.acquisition.info(4)=cellstr(enterDetails(previous));
handles.descriptionWritten=true;
guidata(hObject, handles);