function loadList_Callback(hObject, eventdata)
%

handles=guidata(hObject);
exptFolder=char(handles.acquisition.info{3});
[filename pathname]=uigetfile(strcat(exptFolder,'/*.txt'),'Choose points file');
handles.acquisition.points=loadList(strcat(pathname,filename));
set(handles.pointsTable,'Enable','On');
set(handles.pointsTable,'Data',handles.acquisition.points);
updateDiskSpace(handles);
guidata(hObject, handles)