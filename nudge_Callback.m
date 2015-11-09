function nudge_Callback(hObject, eventdata)
%

handles=guidata(hObject);
tag=get(hObject,'Tag');
global mmc
set(handles.(tag),'Value',0);%Unpress the button
switch tag
    case 'shiftLeft'
        mmc.setRelativeXYPosition('XYStage',-handles.distance,0);
    case 'shiftRight'
        mmc.setRelativeXYPosition('XYStage',handles.distance,0);
    case 'shiftUp'
        mmc.setRelativeXYPosition('XYStage',0,-handles.distance);
    case 'shiftDown'
        mmc.setRelativeXYPosition('XYStage',0,handles.distance);
        
end
guidata(hObject, handles)