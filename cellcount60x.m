%For counting cell numbers in haemocytometer slide
%Takes 12 adjacent fields covering fields within the 12 squares.
%Move stage to the middle of a haemocytometer square - in the square at the
%top left (seen through eyepiece) of a group of 12 squares.
%Segmentation works best when cells are slightly out of focus - get a dark
%ring around the cell that nicely separates adjacent cells.
%inputs
%1. strain - a string describing the strain.
%2. dilution - a scalar dilution factor

function[cellsperml]=cellcount60x(strain,dilution)
global mmc;

%load configuration file - needed to define the pixel size
mmc.loadSystemConfiguration('C:\Program Files\Micro-Manager-1.3_NB\MMConfig_count60x.cfg');
%Define an acquisition data structure - including automatic
%generation of points. Then call run acquisition
acqData={};
acqData.channels={'DIC', [10] [0] [0] [0] [2] [1] [1]};
acqData.z=[1 0 0 0 0];%1 section, 0 spacing, PFS off
acqData.time=[0 1 1 1];
acqData.flow={'no flow', 'no flow', 1 zeros(1,180)};
info=strcat('Cell count experiment: Strain:',strain,', Dilution:',num2str(dilution));
user=getenv('USERNAME');
root=makeRoot(user);%this provides a root directory based on the name and date
acqData.info={'count',user,root,info}; 

%Automatic generation of points:
%First get the current position
 startx=mmc.getXPosition('XYStage');
 starty=mmc.getYPosition('XYStage');
 z=mmc.getPosition('TIZDrive');
 PFS=mmc.getProperty('TIPFSOffset','Position');
 PFS=str2double(char(PFS));

 %acqData.points={};
 
 %First point is the current position
 %Define 4x3 grid of positions - 250 microns apart (size of field is 134
 %microns - the resulting fields will be non-overlapping.
 c=1;
 for y=starty:-250:(starty-750)
 for x=startx:-250:(startx-500)
     acqData.points(c,:)={num2str(c), x, y, z, PFS, 10};
     c=c+1;
 end
 end
 

%Initialise timepoint array - to take the data for a single timepoint
%timepoint=zeros(numPositions,numChannels,numzsections,512,512);

timepoint=zeros(12,1,1,512,512);
timepoint=im2uint16(timepoint);
EMsets=[0 0 0];
%capture the data
[logfile,exptFolder,posDirectories]=initializeFiles(acqData); 
initializeScope;
%No PFS initialisation step - this acquisition is run with the PFS off as 
%the coverslip is too thick for it to work.
disp('Acquisition in progress: press ctrl+C to abort acquisition');
disp (acqData);
%loop through the positions
timepoint=zeros(512,512,1);
for pos=1:12
    fprintf(logfile,'%s',strcat('Position:',num2str(pos),', ',char(acqData.points(pos,1))));
    fprintf(logfile,'\r\n');
    visitXY(logfile,acqData.points(pos,:));%sets the xy position of the stage
    posFolder=posDirectories(pos);
    chanoutput=captureChannels(acqData,logfile,posFolder,pos,1,EMsets);
    timepoint(:,:,pos)=reshape(chanoutput.images(:),512,512);
end

%Display result - need to copy data from timepoint into results array.

%initialise results image for display - 12 images, 512x512 each arranged 3x4
%1:512 then 15 black pixels then 527:1039 then 15 black pixels
%then 1054:1566 then (in y only) 15 black pixels then 1581:2093

results=zeros(1566,2093);

results(1:512,1:512)=timepoint(:,:,1);
results(1:512,527:1038)=timepoint(:,:,2);
results(1:512,1054:1565)=timepoint(:,:,3);
results(1:512,1581:2092)=timepoint(:,:,4);
results(527:1038,1:512)=timepoint(:,:,5);
results(527:1038,527:1038)=timepoint(:,:,6);
results(527:1038,1054:1565)=timepoint(:,:,7);
results(527:1038,1581:2092)=timepoint(:,:,8);
results(1054:1565,1:512)=timepoint(:,:,9);
results(1054:1565,527:1038)=timepoint(:,:,10);
results(1054:1565,1054:1565)=timepoint(:,:,11);
results(1054:1565,1581:2092)=timepoint(:,:,12);

figure;
imshow(results,[]);

%code here to count cells and return number per ml.
 count=zeros(1,12);
for n=1:12
 img=squeeze(timepoint(n,1,1,:,:));
% img=im2uint8(img);
 background = imopen(img,strel('disk',15));
 img=img-background;
 thresh=graythresh(img);
 img2=im2bw(img,thresh);
 celldata = regionprops(img2, 'Area','Solidity');
 celldata2=vertcat(celldata.Area);
 celldata3=vertcat(celldata.Solidity);
 singlecells=celldata2>40 & celldata2<150;
 joinedcells=celldata2>=150 & celldata3<0.95;
 count(n)=sum(singlecells)+2*(sum(joinedcells));
 fprintf(logfile,'%s',strcat('Position:',num2str(n),': ',num2str(count(n)),'cells counted'));
 fprintf(logfile,'\r\n');
end
 
% Volume calibration:

% Volume of smallest square is 0.25nl (http://en.wikipedia.org/wiki/Haemocytometer)
% 
% Length of side of square is 50 microns. Area is 2500microns sqd
% 
% Size of image from 60x lens is 512x0.236(size of pixel)=134.66. Image area =134.66x134.66  = 18133.356 microns sqd.
% 
% Number of small squares that would fit in the whole image =  18133.356/2500 = 7.253
% 
% Vol represented by whole field = 7.253 x 0.25nl = 1.813nl
 
%Mean number of cells = sum(count)/1.812nl x 12.

cellspernl=sum(count)/1.182*12;
cellsperml=cellspernl*1000000;
set(gcf,'NumberTitle','Off');
set(gcf,'Name',strcat('Cells per ml: ',num2str(cellsperml)));
fprintf(logfile,'%s',strcat('Measured cells/ml culture=',num2str(cellsperml)));
fprintf(logfile,'\r\n');
 
 
%Then take the mean and normalise to volume - give cells/ml as an output
%to this function and maybe also a figure with all 12 images.
 
%Volume normalisation:



 
 