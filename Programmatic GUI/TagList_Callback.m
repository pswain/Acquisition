function TagList_Callback(hObject, eventdata)
%Callback for selection of items on the list of Omero tags. Doesn't do
%anything currently

handles=guidata(hObject);

guidata(hObject, handles)