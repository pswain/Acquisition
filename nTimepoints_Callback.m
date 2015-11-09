function nTimepoints_Callback(hObject, eventdata)
%

handles=guidata(hObject);
timepoints=str2double(get(hObject,'String'));
handles.acquisition.time(3)=timepoints;%set number of timepoints in acquisition data
totalS=(timepoints*handles.acquisition.time(2));%Work out total time in seconds - n timepoints * interval
handles.acquisition.time(4)=totalS;%set total time in acquisition data
%Update total time in the GUI - depends on the units.
totalUnits=get(handles.unitsTotal,'Value');
switch (totalUnits)
    case {1}%value 1 represents 's'
        set(handles.totaltime,'String',num2str(totalS));
    case{2}%'min'
        set(handles.totaltime,'String',num2str(totalS/60));
    case{3}%'hr'
        set(handles.totaltime,'String',num2str(totalS/3600));
end
%need to update flow switching settings based on the new total number of
%timepoints.
sizeFlow=size(handles.acquisition.flow{4});
nFlowTimepoints=sizeFlow(1);
updateDiskSpace(handles);
guidata(hObject, handles)