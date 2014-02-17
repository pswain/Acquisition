%Timelapse acquisition with a single channel (no point visiting or z
%sectioning). 
%Set dye set configuration and exposure time before running this
function[]=oneChTimelapse(timepoints,interval,exptName,folder)
global mmc;
height=512;
width=512;
tic%start of timer - toc statement will give time since this tic
for t=1:timepoints
    startOfTimepoint=toc;
    endOfTimepoint=(startOfTimepoint+interval);
    filename=strcat(folder,'\','img_',sprintf('%09d',t),'_',exptName);
    mmc.snapImage();
        img=mmc.getImage;
        img2=typecast(img,'uint16'); 
        img2=reshape(img2,[height,width]);
        imwrite(img2,filename);
        currTime=toc;
        while (currTime<endOfTimepoint)
        currTime=toc;
        end
    
end
