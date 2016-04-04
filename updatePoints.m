function handles=updatePoints(handles,deleted)
%updates the points table when changes are made to the number of channels
%imaged
%The optional input 'deleted' indicates which channel has been removed
headings=get(handles.pointsTable,'ColumnName');
if nargin==1%only the handles input is supplied. This means no channel has been deleted - a channel has been added
    numColumns=size(headings,1);
    lastChan=size(handles.acquisition.channels,1);%the index to the channel that has just been added
    defExp=handles.acquisition.channels(lastChan,2);%exposure time from channels panel - default exposure - to be used initially for all point groups but then editable
    numPoints=size(handles.acquisition.points,1);
    newcolumn=zeros(numPoints,1);
    newcolumn(:,1)=cell2mat(defExp);
    newcolumn=num2str(newcolumn);
    for pos=1:size(newcolumn,1)
        handles.acquisition.points(pos,numColumns+1)={newcolumn(pos,:)};
    end
    %Now deal with the headings of the points table.
    headings(numColumns+1)=strcat(handles.acquisition.channels(lastChan,1),'(ms)');
else%a deleted channel number has been input
    toDelete=deleted+6;
    nameToDelete=strcat(handles.acquisition.channels(deleted,1),'(ms)');
    handles.acquisition.points(:,toDelete)=[];
    n=7;
    done=0;
    while done==0 && n<=size(headings,1)
        if strcmp(headings(n),nameToDelete)==1
            headings(n)=[];
            done=1;
        end
        n=n+1;
    end
end
set(handles.pointsTable,'ColumnName',headings);
set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
