function updateFlowData(hObject, eventdata, handles)
%Records information from the gui controls in the flow panel to
%handles.acquisition.flow

%If a pump control has been altered, need to know which one it was
handles=guidata(hObject);
nPumps=2;
for n=1:nPumps
    volCell=get(handles.(['diameterP' num2str(n)]),'String');
    volString=volCell{get(handles.(['diameterP' num2str(n)]),'Value')};
    handles.acquisition.flow{4}(n).diameter=pump.getDiameter(volString);
    handles.acquisition.flow{4}(n).contents=get(handles.(['contentsP' num2str(n)]),'String');
    handles.acquisition.flow{4}(n).currentRate=str2num(get(handles.(['flowRateP' num2str(n)]),'String'));
    handles.acquisition.flow{4}(n).running=get(handles.(['runP' num2str(n)]),'Value');
    handles.acquisition.flow{4}(n).updatePumps;%sends information to the syringe pumps
    handles.acquisition.flow{5}.pumps{n}=handles.acquisition.flow{4}(n);
end

guidata(hObject, handles);