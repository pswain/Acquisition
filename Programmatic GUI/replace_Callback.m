function replace_Callback(hObject, eventdata)
%

handles=guidata(hObject);



global mmc;
%confirm only one point is selected
sizes=size(handles.selected);
nSelected=sizes(1);
if nSelected==1
    row=handles.selected(1);
    table=get(handles.pointsTable,'Data');
    oldZ=table{row,4};
    oldPFS=table{row,5};
    pointsToAdjust=questdlg('Adjust the Z position (including PFS offset) for...?','Adjust Z for which points','This point only','All points in this group', 'All points','This point only');  
    table{row,2}=mmc.getXPosition(handles.acquisition.microscope.XYStage);
    table{row,3}=mmc.getYPosition(handles.acquisition.microscope.XYStage);
    table{row,4}=mmc.getPosition(handles.acquisition.microscope.ZStage);
    table{row,5}=handles.acquisition.microscope.Autofocus.getOffset;
    switch pointsToAdjust
        case 'All points'
            diff=table{row,4}-oldZ;
            diffPFS=table{row,5}-oldPFS;
            for n=1:size(table,1)
                table{n,4}=table{n,4}+diff;
                table{n,5}=table{n,5}+diffPFS;
            end
        case 'This point only'
            
        case 'All points in this group'
            group=table{row,6};
            diff=table{row,4}-oldZ;
            diffPFS=table{row,5}-oldPFS;
            for n=1:size(table,1)
                if table{n,6}==group
                    table{n,4}=table{n,4}+diff;
                    table{n,5}=table{n,5}+diffPFS;
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
