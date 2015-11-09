function makeTile_Callback(hObject, eventdata)
%

handles=guidata(hObject);
set(handles.pointsTable,'Enable','on');%Make sure the table is activated (won't be if this is the first point to be defined)

correctLens=false;
while ~correctLens
    lens=inputdlg('Enter lens magnification (10, 40 (Robin only), 60 or 100):','Tile creation: enter magnification',1,{'60'});
    if any(strcmp(lens{:},{'40', '60','100','10'}));
        correctLens=true;
    end
end
defaults={'10','10','',''};
switch lens{:}
    case '10'
        defaults{3}='824';
        defaults{4}='824';
    case '40'
        defaults{1}='15';
        defaults{2}='5';
        defaults{3}='155'; %167 to be touching
        defaults{4}='-200'; %220 to be adjacent
    case '60'
        defaults{3}='137';
        defaults{4}='137';
    case '100'
        defaults{3}='82.4';
        defaults{4}='82.4';
end
defaults{5}='pos';
answers=inputdlg({'Number of rows (y)','Number of columns(x)','Space between rows (microns)','Space between columns (microns)','Name for this group'},'Tile creation: define dimensions',1,defaults);



currPosList=handles.acquisition.points;
[tiles handles]=makeTiles(str2num(answers{1}),str2num(answers{2}),str2num(answers{3}),str2num(answers{4}), answers{5},handles);
tiles(1:size(currPosList,1),:)=currPosList;
set(handles.pointsTable,'Data',tiles);
handles.acquisition.points=tiles;
set(handles.pointsTable,'Enable','on');%Make sure the table is activated (won't be if this is the first point to be defined)
updateDiskSpace(handles);
guidata(hObject, handles)