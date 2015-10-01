%Returns an object of the appropriate Microscope subclass for the computer
%you are connected to (based on the hostname).
function obj=chooseScope
%Get computer name
[idum,hostname]= system('hostname');
if length(hostname)<14
    hostname(length(hostname)+1:14)=' ';
end
%Establish which computer is running this, and therefore which microscope
k=strfind(hostname,'SCE-BIO-C03727');
if ~isempty(k)
    %Robin
    obj=Robin;
else
    l=strfind(hostname,'SCE-BIO-C03982');
    if ~isempty(l)
        obj=Batman;
    else
        m=strfind(hostname,'SCE-BIO-C04078');
        if ~isempty(m)
            obj=Batgirl;
            %Add an else here for a demo microscope - eg for working on the
            %software on Macs
        end
    end
end
end

    
    