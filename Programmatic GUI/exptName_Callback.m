function exptName_Callback(hObject, eventdata)
handles=guidata(gcf);
handles.acquisition.info(1)=cellstr(get(hObject,'String'));
%When name is changed the user should be encouraged to rewrite the
%experiment details so set the descriptionWritten flag to false.
handles.descriptionWritten=false;

guidata(hObject, handles);