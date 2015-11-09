function live_Callback(hObject, eventdata)
%

handles=guidata(hObject);
global gui;
if gui.isLiveModeOn
    gui.enableLiveMode(0);
    set(handles.live,'String','Live');
    set(handles.live,'BackgroundColor',[0.2 .9 0.2]);
else
    gui.enableLiveMode(1);
    set(handles.live,'String','Stop Live');
    set(handles.live,'BackgroundColor',[.9 0.2 0.2]);
end

guidata(hObject, handles)