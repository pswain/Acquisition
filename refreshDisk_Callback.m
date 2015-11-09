function refreshDisk_Callback(hObject, eventdata)
%

handles=guidata(hObject);
handles.freeDisk=checkDiskSpace;
set(handles.GbFree,'String',num2str(handles.freeDisk));
updateDiskSpace(handles);
guidata(hObject, handles)