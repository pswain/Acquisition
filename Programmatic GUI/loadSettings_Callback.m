function loadSettings_Callback(hObject, eventdata)
%

handles=guidata(hObject);
%Get the path of the last file saved - to use as default for loading
user=getenv('USERNAME');
lastSavedPath=strcat('C:\Documents and Settings\All Users\multiDGUIfiles\',user,'lastSaved.txt');
if exist (lastSavedPath,'file')==2
    fileWithPath=fopen(lastSavedPath);
    acqFilePath=textscan(fileWithPath,'%s','Delimiter','');%read with empty delimiter,'' - prevents new line being started at spaces in the path name
    fclose(fileWithPath);
    acqFilePath=acqFilePath{:};
    defaultPath=char(acqFilePath);
else
    defaultPath=handles.acquisition.microscope.DataPath;
end
[filename,pathname]=uigetfile('*.txt','Choose acquisition settings file',defaultPath);
handles.acquisition=loadAcquisition(handles.acquisition,strcat(pathname,filename));

%then import the data from the handles.acquisition structure into the GUI:
refreshGUI(handles);
guidata(hObject, handles)