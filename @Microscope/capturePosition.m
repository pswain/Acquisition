function      returnData=capturePosition(obj,acqData,logfile,folder,pos,t,CHsets)
%Captures, saves and returns the data for a given position. This method
%currently used by the Nikon microscopes Batman and Batgirl while the Robin
%subclass overrides this method. This version sets the channel first and
%captures all Z sections for each channel seperately.
[returnData]=captureChannels(acqData,logfile,folder,pos,t,CHsets);




end