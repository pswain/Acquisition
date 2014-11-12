function handles=makeTile(handles,inputX, inputY)
global mmc;
set(handles.pointsTable,'Enable','on');%Make sure the table is activated (won't be if this is the first point to be defined)



x=inputX;
y=inputY;
w=5;
l=5;
lens=60;
if lens==60
    dist=140;   %Image size (60x) = .263um/pixel*512 = 134.656microns
    %           %dist=130 gives a slight overlap. dist>135 gives no overlap
    %           
end

for a=1:w
    for b=1:l
        mmc.setXYPosition('XYStage',x,y);
        pause(.8);%To let the pfs adjust the z position;
        nPoints=size(handles.acquisition.points,1);%number of points previously defined
        %define a default group (the group of the previous point +1 if there is one,
        %otherwise 1)
        if nPoints>0
            group=cell2mat(handles.acquisition.points(nPoints,6))+1;
        else%this is the first point defined. Set group to 1 and also initialise the column headings (based on the chosen channels)
            group=1;
            headings={'Name','x (microns)','y (microns)','z (microns)', 'PFS offset', 'Group'};
            numChannels=size(handles.acquisition.channels,1);
            editable=[true true true true true true];
            for ch=1:numChannels
                headings(6+ch)=strcat(handles.acquisition.channels(ch,1),'(ms)');
                editable(6+ch)=true;
            end
            set(handles.pointsTable,'ColumnName',headings);
            set(handles.pointsTable,'ColumnEditable',editable);
        end
        %Generate a default name and make sure this name hasn't already been taken
        number=nPoints+1;
        defName=strcat('pos',num2str(number));%generate default point name
        nameOK=0;
        while nameOK==0
            usename=1;
            for n=1:nPoints
                name=char(handles.acquisition.points(n));
                if strcmp(name,defName)==1
                    usename=0;
                end
            end
            if usename==1
                nameOK=1;
            else
                number=number+1;
                defName=strcat('pos',num2str(number));%generate default point name
            end
        end
        [x y z PFS]=definePoint;%call to function that gets position data from scope
        handles.acquisition.points((nPoints+1),1:6)={defName,x,y,z,PFS,group};%add data to acquisition data
        %The first 6 columns of the points table have been defined. The remaining
        %columns are exposure times, one for each channel. Need the channels
        %selected and default exposure times.
        numChannels=size(handles.acquisition.channels,1);
        for ch=1:numChannels
        handles.acquisition.points(nPoints+1,6+ch)={num2str(cell2mat(handles.acquisition.channels(ch,2)))};%this has to be a string - will allow entries other than numbers - eg 'double' for a double exposure to test bleaching
        end
        set (handles.pointsTable,'Data',handles.acquisition.points);%update the table
        x=x-130;
    end
    x=inputX;
    y=y+130;    
end


