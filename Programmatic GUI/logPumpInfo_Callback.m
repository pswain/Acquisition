function logPumpInfo_Callback(hObject, eventdata)
%Radio button callback - choice of whether to record real time pump
%information during acquisition
handles=guidata(hObject);
handles.acquisition.flow{5}.logRealInfo=logical(get(hObject,'Value'));
guidata(hObject,handles);
end