function switchParams_Callback(hObject, eventdata)
%

handles=guidata(hObject);
handles.acquisition.flow{5}=handles.acquisition.flow{5}.setSwitchParams;

guidata(hObject, handles)