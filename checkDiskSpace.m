function Gb_free=checkDiskSpace
%Copied from:
% http://compgroups.net/comp.soft-sys.matlab/matlab-command-to-get-free-hd-
% disk-space/798752
[c,d] = dos('dir');
[c,e] = size(d);
f = strrep(d((e-27):(e-11)),',','');
Gb_free = str2num(f)/(1024*1024*1024);
clear c d e f