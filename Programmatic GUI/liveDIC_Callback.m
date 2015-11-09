function liveDIC_Callback(hObject, eventdata)
%

handles=guidata(hObject);
global gui;
global mmc;
switch handles.acquisition.microscope.Name
    case 'Batman'
        mmc.setProperty('Evolve','Port','Normal');
end
if gui.isLiveModeOn
    gui.enableLiveMode(0);
    set(handles.liveDIC,'String','Live');
    set(handles.live,'BackgroundColor',[.15 0.23 0.37]);
else
    mmc.setConfig('Channel', handles.acquisition.microscope.InitialChannel);
    mmc.waitForConfig('Channel', handles.acquisition.microscope.InitialChannel);
    gui.enableLiveMode(1);
    set(handles.live,'String','Stop Live');
    set(handles.liveDIC,'BackgroundColor',[0.2 .9 0.2]);
end
guidata(hObject, handles)
