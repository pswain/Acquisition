function nZsections_Callback (hObject, eventdata)
%

handles=guidata(hObject);
handles.acquisition.z(1)=str2double(get(hObject,'String'));
updateDiskSpace(handles);
guidata(hObject, handles)