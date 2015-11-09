function deletePoint_Callback (hObject, eventdata)
%

handles=guidata(hObject);
sizes=size(handles.selected);
nSelected=sizes(1);
if nSelected~=0
    for n=1:nSelected
        row=handles.selected(n,1);
        handles.acquisition.points(row,:)=[];
    end
    set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
    guidata(hObject, handles);
end
updateDiskSpace(handles);
guidata(hObject, handles);
% --- Executes on button press in clearList.
function clearList_Callback(hObject, eventdata, handles)
ButtonName = questdlg('Are you sure you want to delete all marked points', ...
    'Delete marked points','No');
switch ButtonName,
    case 'Yes',
        handles.acquisition.points={};
        set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
    case 'No',
end % switch
updateDiskSpace(handles);
guidata(hObject, handles)