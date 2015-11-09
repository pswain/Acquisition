function saveList_Callback(hObject, eventdata)
%

handles=guidata(hObject);
savePoints(handles.acquisition);
set(handles.saveList,'Value',0);
guidata(hObject, handles)