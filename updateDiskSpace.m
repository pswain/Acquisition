function updateDiskSpace(handles)
%Checks the amount of free disk space and how much is required for the
%current experiment - updates the gui accordingly
disp('Updating required disk space');
GbFree=handles.freeDisk;
set(handles.GbFree,'String',num2str(GbFree));
imageSizeKb=407;%When adapting for Robin - make this dependent on a field of handles.microscope
imageSizeGb=imageSizeKb/1000000;
%Total number of time points
if handles.acquisition.time(1)==1
    %This is a time lapse acquisition
    numTps=handles.acquisition.time(3);
else
    numTps=1;
end

%How many images are required?
totalImages=0;
for ch=1:size(handles.acquisition.channels,1)
    
    %Number of time points
    if numTps>1
        startTp=handles.acquisition.channels{ch,5};
        thisChTps=numTps-startTp+1;%When end Tp box is included - add this to calculation of number of Tps.    
        skip=max(handles.acquisition.channels{ch,3},1);
        thisChTps=ceil(thisChTps/skip);
    else
        thisChTps=1;
    end
    
    
    %Sections per time point
    if handles.acquisition.channels{ch,4}==1
       %This channel does z sectioning
       thisChZ=handles.acquisition.z(1);
    else
        thisChZ=1;
    end
    thisChImages=thisChZ*thisChTps;
    %Now have number of images to be used for each position if all use the
    %default settings. Need to remove any positions with zero exposures -
    %not imaging that channel at that position
    if length(handles.acquisition.points)>0
        exposures=handles.acquisition.points(:,ch+6);%This gives the column of exposure times for channel ch
        numNotUsed=nnz(strcmp(exposures,'0'));%Number of positions where this channel is not used
        numUsed=length(exposures)-numNotUsed;%number of positions where this channel is used
        thisChImages=thisChImages*numUsed;
    end
    %Add to the total
    totalImages=totalImages+thisChImages;
end

GbReqd=totalImages*imageSizeGb;

set(handles.GbReqd,'String',num2str(GbReqd));
if GbReqd>=GbFree
    set(handles.GbReqd,'ForegroundColor','r');
    warndlg('Not enough disk space for this experiment!');
end


