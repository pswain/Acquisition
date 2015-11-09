function units_Callback(hObject, eventdata)
%

handles=guidata(hObject);
content=get(hObject,'Value');%get the selected units
timeInterval=handles.acquisition.time(2);%get the total time in seconds
switch (content)
    case {1}%value 1 represents 's'
        set (handles.interval,'String',num2str(timeInterval));
    case{2}%'min'
        set (handles.interval,'String',num2str(timeInterval/60));
    case{3}%'hr'
        set (handles.interval,'String',num2str(timeInterval/3600));
end
guidata(hObject, handles)