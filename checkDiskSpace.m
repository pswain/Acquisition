function Gb_free=checkDiskSpace(disk)
%Modified from:
% http://compgroups.net/comp.soft-sys.matlab/matlab-command-to-get-free-hd-
% disk-space/798752
if nargin==1
    disk=[disk '\'];
else
   disk='C:\'; 
end
[c,d] = dos(['dir ' disk]);
[c,e] = size(d);
f = strrep(d((e-27):(e-11)),',','');
Gb_free = str2num(f)/(1024*1024*1024);
clear c d e f