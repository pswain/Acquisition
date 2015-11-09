function interval_Callback(hObject, eventdata)
%

handles=guidata(hObject);
intervalEntered=str2double(get(hObject,'String'));%get the time interval
intUnits=get(handles.units,'Value');%get the units

%define the time interval in s, depending on the units
%also update the total time based on this interval
switch (intUnits)
    case {1}%value 1 represents 's'
        handles.acquisition.time(2)=intervalEntered;
    case{2}%'min'
        handles.acquisition.time(2)=intervalEntered*60;
    case{3}%'hr'
        handles.acquisition.time(2)=intervalEntered*3600;
end
%update the total time based on the new interval
timepoints=handles.acquisition.time(3);%get the number of timepoints
newInterval=handles.acquisition.time(2);
totalS=(timepoints*newInterval);%Work out total time in seconds - n timepoints * interval
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
guidata(hObject, handles)