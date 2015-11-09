function clearList_Callback(hObject, eventdata)
%

handles=guidata(hObject);
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