function stopacq_Callback(hObject, eventdata)
%

handles=guidata(hObject);
handles.stop=1;
set(handles.start,'Enable','on');set(handles.stopacq,'Enable','off');

guidata(hObject, handles)