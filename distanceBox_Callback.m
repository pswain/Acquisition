function distanceBox_Callback(hObject, eventdata)
%

handles=guidata(hObject);
input=str2double(get(hObject,'String'));
if ~isempty(input)
    if input<200
        handles.distance=input;
    else
        set(handles.distanceBox,'String',num2str(handles.distance));
    end
else
    %a number was not input
    set(handles.distanceBox,'String',num2str(handles.distance));
end
guidata(hObject, handles)