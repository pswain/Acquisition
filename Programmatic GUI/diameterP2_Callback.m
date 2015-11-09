function diameterP2_Callback(hObject, eventdata)
%

handles=guidata(hObject);
contents = cellstr(get(hObject,'String'));
volString=contents{get(hObject,'Value')};
diameter=pump.getDiameter(volString);
pumpSerial=handles.acquisition.flow{4}(2).serial;
fprintf(pumpSerial,['DIA' num2str(diameter)]);pause(.05);
guidata(hObject, handles)