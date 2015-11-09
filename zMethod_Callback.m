function zMethod_Callback(hObject, eventdata)
%

handles=guidata(hObject);
contents = cellstr(get(hObject,'String'));
input=contents{get(hObject,'Value')};

switch input
    case 'PIFOC'
        handles.acquisition.z(6)=1;
    case 'PIFOC with PFS on'
        handles.acquisition.z(6)=2;
    case 'PFS'
        handles.acquisition.z(6)=3;
end

guidata(hObject, handles)