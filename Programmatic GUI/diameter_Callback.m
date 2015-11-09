function diameter_Callback(hObject, handles)
% hObject    handle to diameterP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns diameterP2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from diameterP2
tag=get(hObject,'Tag');
pumpNumber=str2num(tag(end));
contents = cellstr(get(hObject,'String'));
volString=contents{get(hObject,'Value')};
diameter=pump.getDiameter(volString);
pumpSerial=handles.acquisition.flow{4}(pumpNumber).serial;
%Stop the pump before sending new diameter
fprintf(pumpSerial,'STP');pause(.05);
fprintf(pumpSerial,['DIA' num2str(diameter)]);pause(.05);
%Restart if necessary
if get(handles.(['runP' num2str(pumpNumber)]),'Value')>0
    fprintf(pumpSerial,'RUN1');pause(.1);
end
