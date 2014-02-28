function [tiles handles] = makeTiles (nRows,nColumns, rowSpacing, colSpacing, handles)

Points=nRows*nColumns;%number of points

%define a default group (the group of the previous point +1 if there is one,
%otherwise 1)
headings={'Name','x (microns)','y (microns)','z (microns)', 'PFS offset', 'Group'};
numChannels=size(handles.acquisition.channels,1);
editable=[true true true true true true];
for ch=1:numChannels
    headings(6+ch)=strcat(handles.acquisition.channels(ch,1),'(ms)');
    editable(6+ch)=true;
end
set(handles.pointsTable,'ColumnName',headings);
set(handles.pointsTable,'ColumnEditable',editable);
number=0;
global mmc;
startX=mmc.getXPosition('XYStage');
startY=mmc.getYPosition('XYStage');
pause(.01);

%If the PFS is on then we can determine and correct for any slope of the
%cover slip
if strcmp(mmc.getProperty('TIPFSStatus','Status'),'Locked')
   disp('Measuring sample slope');
   %Move the stage 100um to the right. If there's a slope then the PFS will
   %correct it - then read the z drive value to determine slope
   startZ=mmc.getPosition('TIZDrive')
   %First any slope in X
   mmc.setRelativeXYPosition('XYStage',100,0);
   %Wait for the pfs to finish focusing
   status='Focusing';
   while strcmp('Status','Focusing')
      status=mmc.getProperty('TIPFSStatus','Status');
      pause (0.1);
   end

   newZ_x=mmc.getPosition('TIZDrive');
   xSlope=newZ_x-startZ;
   %Then slope in Y
   mmc.setRelativeXYPosition('XYStage',0,100);
   status='Focusing';
   while strcmp('Status','Focusing')
      status=mmc.getProperty('TIPFSStatus','Status');
      pause (0.1);
   end
   newZ_y=mmc.getPosition('TIZDrive');
   ySlope=newZ_y-newZ_x;
   %Return stage to original position
   mmc.setRelativeXYPosition('XYStage',-100,-100);
   while strcmp('Status','Focusing')
      status=mmc.getProperty('TIPFSStatus','Status');
      pause (0.1);
   end
   disp(['Sample slopes by ' num2str(xSlope) 'microns per 100um movement in x']);
   disp(['Sample slopes by ' num2str(ySlope) 'microns per 100um movement in y']);
   disp(['Slope will be corrected when determining tiled positions']);
else
    disp('No correction for any sample slope - PFS is not on and locked');
    ySlope=0;
    xSlope=0;
end
%x and y slopes are per 100um of x or y stage translation
%Convert to 1um.
xSlope=xSlope/100
ySlope=ySlope/100

startZ=mmc.getPosition('TIZDrive')
for row=1:nRows
    for col=1:nColumns
        %Generate a default name and make sure this name hasn't already been taken
        number=number+1;
        defName=strcat('pos',num2str(number));%generate default point name       
        tiles{number,1}=defName;
        tiles{number,2}=(col-1)*colSpacing+startX;
        tiles{number,3}=(row-1)*rowSpacing+startY;
        %Calculate z position based on how far away from the start position
        %it is in x and y and the recorded slopes.
        xDistance=(col-1)*colSpacing;
        zDisplacementX=xDistance*xSlope;     
        yDistance=(row-1)*rowSpacing;
        zDisplacementY=yDistance*ySlope;      
        tiles{number,4}=startZ+zDisplacementX+zDisplacementY;
        tiles{number,5}=mmc.getPosition('TIPFSOffset');
        tiles{number,6}=number;
        
        %The first 6 columns of the points table have been defined. The remaining
        %columns are exposure times, one for each channel. Need the channels
        %selected and default exposure times.
        numChannels=size(handles.acquisition.channels,1);
        for ch=1:numChannels
        tiles(number,6+ch)={num2str(cell2mat(handles.acquisition.channels(ch,2)))};%this has to be a string - will allow entries other than numbers - eg 'double' for a double exposure to test bleaching
        end
    end
end

end