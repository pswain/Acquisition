function diameterP1_Callback(hObject, eventdata)
%

handles=guidata(hObject);
contents = cellstr(get(hObject,'String'));
volString=contents{get(hObject,'Value')};
diameter=pump.getDiameter(volString);
pumpSerial=handles.acquisition.flow{4}(1).serial;
fprintf(pumpSerial,['DIA' num2str(diameter)]);pause(.05);
guidata(hObject, handles)