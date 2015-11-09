function unitsTotal_Callback(hObject, eventdata)
%

handles=guidata(hObject);
content=get(hObject,'Value');%get the selected units
totalTime=handles.acquisition.time(4);%get the total time in seconds
switch (content)
    case {1}%value 1 represents 's'
        set (handles.totaltime,'String',num2str(totalTime));
    case{2}%'min'
        set (handles.totaltime,'String',num2str(totalTime/60));
    case{3}%'hr'
        set (handles.totaltime,'String',num2str(totalTime/3600));
end
guidata(hObject, handles)