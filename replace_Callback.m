function replace_Callback(hObject, eventdata)
%

handles=guidata(hObject);



global mmc;
%confirm only one point is selected
sizes=size(handles.selected);
nSelected=sizes(1);
if nSelected==1
    ans=questdlg('Do you want to adjust all z positions?');
    table=get(handles.pointsTable,'Data');
    row=handles.selected(1);
    if strcmp(ans,'Yes')
        oldZ=table{row,4};
    end
    table{row,2}=mmc.getXPosition('XYStage');
    table{row,3}=mmc.getYPosition('XYStage');
    table{row,4}=mmc.getPosition(handles.acquisition.microscope.ZStage);
    table{row,5}=handles.acquisition.microscope.Autofocus.getOffset;
    if strcmp(ans,'Yes')
        diff=table{row,4}-oldZ;
        for n=1:size(table,1)
            if n~=row
                table{n,4}=table{n,4}+diff;
            end
        end
    end
    
    set(handles.pointsTable,'Data',table);
    handles.acquisition.points=table;
    guidata(hObject, handles);
    
else
    errordlg('Please select one point to replace','Replace point');
    
end
guidata(hObject, handles)
