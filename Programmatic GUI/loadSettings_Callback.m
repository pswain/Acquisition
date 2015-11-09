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
    defaultPath='C:\AcquisitionData';
end
[filename,pathname]=uigetfile('*.txt','Choose acquisition settings file',defaultPath);
handles.acquisition=loadAcquisition(strcat(pathname,filename));
%need to initialise the experimental info here - not loaded from the
%acquisition file
user=getenv('USERNAME');
root=makeRoot(user, handles.acquisition.microscope);%this provides a root directory based on the name and date
handles.acquisition.info={'exp' user root 'Aim:   Strain:  Comments:'};%Initialise the experimental info - exp name and details may be altered later when refreshGUI is called but root and user stay the same

%then import the data from the handles.acquisition structure into the GUI:
refreshGUI(handles);
guidata(hObject, handles)