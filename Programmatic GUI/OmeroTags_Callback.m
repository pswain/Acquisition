function OmeroTags_Callback(hObject,eventdata)
%Runs a dialogue allowing the user to add tags for the experiment. 
%Information input is recorded in the log file and will be used by the
%Omero upload function
handles=guidata(hObject);
handles.acquisition=addTagGUI(handles.acquisition.omero.object,handles.acquisition);
set(handles.TagList,'String', handles.acquisition.omero.tags);
handles.tagsChanged=true;
guidata(hObject,handles);