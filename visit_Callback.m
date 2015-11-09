function visit_Callback(hObject, eventdata)
%

handles=guidata(hObject);
global mmc;
%confirm only one point is selected
sizes=size(handles.selected);
nSelected=sizes(1);
if nSelected==1
    %get data for position to visit
    table=get(handles.pointsTable,'Data');
    row=handles.selected(1);
    x=table{row,2};
    y=table{row,3};
    z=table{row,4};
    pfs=table{row,5};
    %Is the PFS on
    pfsOn=handles.acquisition.microscope.Autofocus.isLocked;
    %if so switch it off for xy stage movement
    if pfsOn==1
        handles.acquisition.microscope.Autofocus.switchOff;
    end
    %move the stage
    mmc.setXYPosition('XYStage',x,y);
    mmc.waitForDevice('XYStage');
    %move Z position to set value
    mmc.setPosition(handles.acquisition.microscope.ZStage,z);
    %Switch autofocus device back on if in use
    if pfsOn==1
        handles.acquisition.microscope.Autofocus.switchOn;
        handles.acquisition.microscope.Autofocus.setOffset(pfs);
    end
    uiresume(gcbf);
    
else
    errordlg('Please select one point to visit','Visit point');
end
guidata(hObject, handles)