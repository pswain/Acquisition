function zspacing_Callback(hObject, eventdata)
%

handles=guidata(hObject);
handles.acquisition.z(2)=str2double(get(hObject,'String'));
guidata(hObject, handles)