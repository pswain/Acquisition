function doTimelapse_Callback(hObject, eventdata)
%

handles=guidata(hObject);
if get(hObject,'Value')==1%timelapse experiment selected
    %enable time lapse controls
    set(handles.interval,'Enable','on');
    set(handles.units,'Enable','on');
    set(handles.nTimepoints,'Enable','on');
    set(handles.totaltime,'Enable','on');
    set(handles.unitsTotal,'Enable','on');
    handles.acquisition.time(1)=1;
else
    set(handles.interval,'Enable','off');
    set(handles.units,'Enable','off');
    set(handles.nTimepoints,'Enable','off');
    set(handles.totaltime,'Enable','off');
    set(handles.unitsTotal,'Enable','off');
    handles.acquisition.time(1)=0;
end
updateDiskSpace(handles);
guidata(hObject, handles)