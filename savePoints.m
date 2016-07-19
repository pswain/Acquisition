function savePoints(acqData,outputFile)


fprintf(outputFile,'Position name, X position, Y position, Z position, PFS offset, Group');
for channel=1:size(acqData.channels,1)
    fprintf(outputFile,', %10s',acqData.channels{channel,1});
end
fprintf(outputFile,'\n');
for n=1:size(acqData.points,1)
    fprintf(outputFile,'%13s, %10.2f, %10.2f, %10.3f, %10.3f, %5u',...
        char(acqData.points{n,1}),... %1. position name
        acqData.points{n,2},... %2. X stage position
        acqData.points{n,3},... %3. Y stage position
        acqData.points{n,4},... %4. Z drive position
        acqData.points{n,5},... %5. PFS offset
        acqData.points{n,6}); %6. Group number
    for channel=1:size(acqData.channels,1)
        % Output the exposure for each channel:
        fprintf(outputFile,', %10u',str2double(acqData.points{n,6+channel}));
    end
    fprintf(outputFile,'\n');
end