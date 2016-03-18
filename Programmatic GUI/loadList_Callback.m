function loadList_Callback(hObject, eventdata)
%Loads a saved point list from a pos file.

handles=guidata(hObject);
exptFolder=char(handles.acquisition.info{3});
if exist(exptFolder,'dir')==7
    startFolder=exptFolder;
else
    k=strfind(exptFolder,'/');
    if exist(exptFolder(1:k(end)),'dir')==7
        startFolder=exptFolder(1:k(end));
    else if exist(exptFolder(1:k(end-1)),'dir')==7
        startFolder=exptFolder(1:k(end-1));
        else if exist(exptFolder(1:k(end-2)))==7
                startFolder=exptFolder(1:k(end-2));
            end
        end
    end
    
end
[filename pathname]=uigetfile(strcat(startFolder,'/*.txt'),'Choose points file');
handles.acquisition.points=loadList(strcat(pathname,filename));
set(handles.pointsTable,'Enable','On');
set(handles.pointsTable,'Data',handles.acquisition.points);
updateDiskSpace(handles);
guidata(hObject, handles)