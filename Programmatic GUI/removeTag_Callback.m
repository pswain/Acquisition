function removeTag_Callback(hObject, eventdata)
%Removes a selected Omero tag so that it is not recorded in the log file or
%added to the dataset on upload.

handles=guidata(hObject);
set(handles.removeTag,'Value',0);
toDelete=get(handles.TagList,'Value');
tagList=get(handles.TagList,'String');
if ~strcmp(handles.acquisition.omero.tags{toDelete},date)
    handles.acquisition.omero.tags(toDelete)=[];
    set(handles.TagList,'Value',toDelete-1);
    set(handles.TagList,'String',handles.acquisition.omero.tags);
else
    disp('You cannot delete the date tag');
end
guidata(hObject,handles);
guidata(hObject, handles)