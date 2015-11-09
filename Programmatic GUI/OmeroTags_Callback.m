function OmeroTags_Callback(hObject,eventdata)
%Allows the user to choose an existing Omero tag for this experiment or
%to create a new one. Information input is recorded in the log file and
%will be used by the Omero upload function
handles=guidata(hObject)
contents=get(hObject,'String');
answer=contents{get(hObject,'Value')};
value=get(hObject,'Value');

if strcmp(answer,'Add a new tag')
    newName = inputdlg('Enter new tag','New tag',1);
    if ~isempty(newName)
        if ~isempty(newName{1})
            newName=newName{1};
            if ~any(strcmp(newName,contents))
                %The tag name is a new one
                description=inputdlg('Enter a description for the new tag','Tag description',7);
                %Record the new tag in the record of tags that should be in
                %the database - it will be added the next time the upload
                %script is run.
                handles.acquisition.omero.object.Tags(end+1).name=newName;
                handles.acquisition.omero.object.Tags(end).id=0;%This marks it as a new tag to be created
                handles.acquisition.omero.object.Tags(end).description=description;
                obj2=handles.acquisition.omero.object;
                path=[handles.acquisition.microscope.OmeroInfoPath 'dbInfoSkye.mat'];
                save(path,'obj2');
                %Add the new tag name to the menu
                contents{end}=newName;
                contents{end+1}='Add a new tag';
                set(handles.OmeroTags,'String',contents);
                set(handles.OmeroTags,'Value',length(contents)-1);
                %Add the new tag to the list associated with this
                %experiment
                handles.acquisition.omero.tags{end+1}=newName;
                %Display the new list.
                set(handles.TagList,'String',handles.acquisition.omero.tags);
            end
        end
    end
else
    if value<length(contents)%Last item in contents is just 'Select an omero project for your experiment...'
        if ~any(strcmp(handles.acquisition.omero.tags,answer))%If statement to avoid repeatedly adding the same tag to the list
            handles.acquisition.omero.tags{end+1}=answer;
            set(handles.TagList,'String',handles.acquisition.omero.tags);
        end
    end
end
guidata(hObject,handles);