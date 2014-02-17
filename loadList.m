function points=loadList(filename)
fid=fopen(filename);
rawdata = textscan(fid,'%s');
rawdata=rawdata{:};
points={};
for p=1:size(rawdata,1)
    thispoint=rawdata(p,:);
    thispoint=char(thispoint);
    pointScan=textscan(thispoint,'%s %f %f %f %f %f','delimiter',',');
    name=pointScan{:};
    
    points(p,1)=name;
    points(p,2:6)=pointScan(2:6);
end
