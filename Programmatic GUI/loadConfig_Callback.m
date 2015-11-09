function loadConfig_Callback(hObject, eventdata)
handles=guidata(hObject);
fprintf('<a href=""> Loading micromanager configuration... </a>\n')
guiconfig2(handles.acquisition.microscope);
fprintf('<a href=""> Setting the GUI for your microscope... </a>\n')
handles=handles.acquisition.microscope.setGUI(handles);
binOptions=get(handles.bin,'String');
bin=binOptions{get(handles.bin,'Value')};
handles.acquisition.microscope.setBin(bin);
set(handles.eye,'Enable','on');
set(handles.camera,'Enable','on');
set(handles.EM,'Enable','on');
set(handles.CCD,'Enable','on');

for i=1:length(handles.acquisition.flow{5}.pumps)
    try
        handles.acquisition.flow{5}.pumps{i}.openPump;
    catch
        warndlg(['Failed to connect to pump number ' num2str(i)]);
    end
end
guidata(hObject, handles);