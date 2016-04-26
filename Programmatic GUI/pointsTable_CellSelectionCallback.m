function pointsTable_CellSelectionCallback(hObject, eventdata, handles)
handles=guidata(hObject);
handles.selected=eventdata.Indices;
guidata(hObject, handles);