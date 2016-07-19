function enterDetails_Callback(hObject,~)
%User input of experiment details to be recorded in the log file
handles=guidata(hObject);
previous=char(handles.acquisition.info(4));

str = sprintf('%s',previous);
input = inputdlg('Enter experimental details here:','Enter experimental details',10,{str});

%Make into an array including the line breaks that are there:
if ~isempty(input)
    input=strjoin(cellstr(input{:}),'\n');
else
    input=previous;
end

handles.acquisition.info(4)=cellstr(input);
handles.descriptionWritten=true;
guidata(hObject, handles);