function [data]=extractnumbers(startdir,position, channel)

    [filename path] = uigetfile(startdir,'*.txt');
    filename=strcat(path,filename);
logfile=fopen(strcat(filename));
rawdata = textscan(logfile,'%s');
rawdata=rawdata{:};


        %First find positions of interest:
        [matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring] = regexp(rawdata,position);
        a=cellfun('isempty', matchend);
        thispos=find(a==0);%gives indices to entries that end with the position name - entry will be: eg 'Position:5,2_1'
        [matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring]=regexp(rawdata,strcat('for',channel,':'));
        a=cellfun('isempty', matchstart);
        thischan=find(a==0);%this will find entries for all positions
        max=zeros(size(thispos,1),1);
        for n=1:size(thispos,1)
            %For this position - find which entry corresponds to the channel's maximum value
            pos=thispos(n);
            count=1;
            chan=thischan(count);
            while pos>chan
                count=count+1;
                chan=thischan(count);
            end
            a=rawdata(chan);
            a=a{:};
            max(n)=str2double(a(8:end));
        end
    %Get the focus drift
        [matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,splitstring] = regexp(rawdata,'Cumulative');
        a=cellfun('isempty', matchstart);
        driftpos=find(a==0);
        driftdata=zeros(size(driftpos,1),1);
        for n=1:size(driftpos,1)
            driftentry=rawdata(driftpos(n)+2);
            driftentry=driftentry{:};
            driftdata(n)=str2double(driftentry(4:end));
        end

data.max=max;
data.drift=driftdata;