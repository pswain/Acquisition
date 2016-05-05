function obj=getFilters(obj)
%Parses the config file to extract filter information
confFile=fopen(obj.Config);
confData=textscan(confFile,'%s','Delimiter','#');
confData=confData{:};
%Find the channel presets:
presets=strfind(confData,'Preset: ');
presets=find(~cellfun(@isempty,presets));
presets(end+1)=length(confData);
for ch=1:length(presets)-1
    %Find the lines that define the preset properties
    chName= confData{presets(ch)}
    chName=chName(9:end);
    chName(~isstrprop(chName,'alphanum'))=[];
    thisCh=strfind(confData,chName);
    thisCh=find(~cellfun(@isempty,thisCh));
    %Loop through the properties of this preset
    props=thisCh(thisCh>presets(ch)&thisCh<presets(ch+1));
    for p=1:length(props)
        line=confData{props(p)};
        line=textscan(line,'%s','Delimiter',',');
        line=line{:};
        %line {4} is the device, line{5}, the property and line{6} the value
        obj.Channels.(chName)(p).device=line{4};
        obj.Channels.(chName)(p).property=line{5};
        obj.Channels.(chName)(p).value=line{6};
        
        
    end
end
%Loop through the channels, defining the filters
chNames=fields(obj.Channels)
for ch=1:length(chNames)
    chName=chNames{ch};
    obj.Filters.(chName)=cell(length(obj.Channels.(chName)),1);
    for n=1:length(obj.Channels.(chName))
        device=obj.Channels.(chName)(n).device;
        property=obj.Channels.(chName)(n).property;
        value=obj.Channels.(chName)(n).value;
        %Find device name/description
        target=['@' device '. "'];
        deviceLine=strfind(confData,target);
        deviceLine=find(~cellfun(@isempty,deviceLine));
        if ~isempty(deviceLine)
            deviceLine=confData{deviceLine};
            deviceLine=textscan(deviceLine,'%s','Delimiter','"');
            deviceLine=deviceLine{:};
            %Find the lines with the current property and value
            target=['@' device ',' property ',' value];
            valueLine=strfind(confData,target);
            valueLine=find(~cellfun(@isempty,valueLine));
            if ~isempty(valueLine)
                valueLine=confData{valueLine};
                valueLine=textscan(valueLine,'%s','Delimiter','"');
                valueLine=valueLine{:};
                obj.Filters.(chName){n,1}=[deviceLine{2} valueLine{2}];
            end
        end
    end
    obj.Filters.(chName)(cellfun(@isempty,obj.Filters.(chName)))=[];
end
end