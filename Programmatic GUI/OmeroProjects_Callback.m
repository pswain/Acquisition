function OmeroProjects_Callback(hObject, eventdata)
%Allows the user to choose an existing Omero project for this experiment or
%to create a new one. Information input is recorded in the log file and
%will be used by the Omero upload function
handles=guidata(hObject);
contents=get(hObject,'String');
value=get(hObject,'Value');
answer=contents{get(hObject,'Value')};

if strcmp(answer,'Add a new project')
    newName = inputdlg('Enter new project name','New project',1);
    if ~isempty(newName)
        if ~isempty(newName{1})
            newName=newName{1};
            if ~any(strcmp(newName,contents))
                %The project name is a new one
                description=inputdlg('Enter a description for the new project','Project description',7);
                %Add this project name to the record of projects that
                %should be in the database - it will be added the next time
                %the upload script is run.
                handles.acquisition.omero.object.Projects(end+1).name=newName;
                handles.acquisition.omero.object.Projects(end).id=0;%This marks it as a new project to be created
                handles.acquisition.omero.object.Projects(end).description=description;
                obj2=handles.acquisition.omero.object;
                path=[handles.acquisition.microscope.OmeroInfoPath 'dbInfoSkye.mat'];
                save(path,'obj2');
                %Add the new project name to the menu
                contents{end}=newName;
                contents{end+1}='Add a new project';
                set(handles.OmeroProjects,'String',contents);
                set(handles.OmeroProjects,'Value',length(contents)-1);
                set(handles.Project,'String',newName);
                %Set the new project as the selected one
                handles.acquisition.omero.project=newName;
            else
                %There is already a project with this name
                %Set the menu value to this project
                index=find(strcmp(newName,contents));
                set(handles.OmeroProjects,'Value',index(1));
                handles.acquisition.omero.project=newName;
                set(handles.Project,'String',newName);
            end
        end
    end
else
    %The user has selected an existing project
    handles.acquisition.omero.project=answer;
    set(handles.Project,'String',answer);
    
end

guidata(hObject, handles)