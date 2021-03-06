today=date;
root=[strcat('C:\AcquisitionData\Swain Lab\Ivan\RAWDATA\',today(8:11),'\',today(4:6),'\', date)];
acqName = 'saveTest';
channels = {'DIC'};%edit to use other channels
exposures = [10, 100];

posName={'position1'};
directories = {''};
width=512; 
height=512;
numTimepoints=1;
numChannels=1;
numPositions=1;
numSlices=1;



exptNum=0;
exptNumString=sprintf('%02d',exptNum);
exptFolder=strcat(root,'\',acqName,'_',exptNumString);


while exist(exptFolder,'dir')==7
   
    exptNum=(exptNum+1);
    exptNumString=sprintf('%02d',exptNum);
    exptFolder=strcat(root,'\',acqName,'_',exptNumString);
end


%make directories for each position

for n=1:numPositions
directories(n)=cellstr(strcat(exptFolder,'\',posName(n)));
    mkdir (char(directories(n)));
end

for i=1:numTimepoints
    for k=1:numPositions
        for j=1:numChannels
            for z=1:numSlices
mmc.snapImage();
img=mmc.getImage();
img2=typecast(img,'uint8'); 
img2=reshape(img2,[height,width]); 
imshow(img2,[]);
filename=char(strcat('img_',sprintf('%09d',i),'_',channels(j),'_',sprintf('%03d',z)));
imwrite(img2,strcat(char(directories(k)),'\',filename,'.tif'));
            end%slices loop
        end%channels loop
    end%positions loop
end%timepoints loop