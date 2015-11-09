function exptName_Callback(hObject, eventdata)
handles=guidata(gcf);
handles.acquisition.info(1)=cellstr(get(hObject,'String'));
guidata(hObject, handles);