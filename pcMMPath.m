javaaddpath('C:\Program Files\Micro-Manager-1.4.21/ij.jar');
%Add all jars in the plugins directory
a=dir (fullfile('C:\Program Files\Micro-Manager-1.4.21/plugins/Micro-Manager'));
for n=3:length(a)
    if strcmp(a(n).name(end-3:end),'.jar')
        %['C:\Program Files\Micro-Manager-1.4.21/plugins/Micro-Manager/' a(n).name]
        javaaddpath(['C:\Program Files\Micro-Manager-1.4.21/plugins/Micro-Manager/' a(n).name]);
    end
end

