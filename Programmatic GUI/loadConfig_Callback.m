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
guidata(hObject, handles);