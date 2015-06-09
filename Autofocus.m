classdef Autofocus
    properties
        Type%string, 'PFS', 'none' or alternative device type
        InUse%true = on (in use) or false = off
        Drift%double, distance in microns that the focus has drifted from its original position
        Status%status of the device (used if PFS)
    end
    
    
    
    
    methods
        function obj=Autofocus(type)
            %Constructor method for Autofocus object - input string type
            %defines the type of device
            obj.Type=type;
            obj.InUse=false;
            obj.Drift=0;
        end
        
        function timelapseWarning(obj)
           global mmc;
           switch obj.Type
               case 'PFS'
                   if ~strcmp(mmc.getProperty('TIPFSStatus','Status'),'Locked in focus');
                       errordlg('Warning ... The PFS is off','Autofocus off warning','Modal');                                           
                   end
           end
        end
        
        function switchOn(obj,wait)
            global mmc;
            switch obj.Type
                case 'PFS'
                    mmc.setProperty('TIPFSStatus','State','On');
                    if nargin==2
                        if wait
                            %Wait until the PFS is no longer activating before continuing
                            pause(.5);
                            obj.Status=mmc.getProperty('TIPFSStatus','Status');
                            while strcmp(obj.Status,'Focusing')==1 || strcmp(obj.Status,'Activating');
                                pause(.5);
                                obj.Status=mmc.getProperty('TIPFSStatus','Status');
                            end
                        end
                    end
            end
            
        end
        function switchOff(obj)
            global mmc;
            switch obj.Type
               case 'PFS'

                    mmc.setProperty('TIPFSStatus','State','Off');
                    pause (0.4);
            end
            
        end
        
        function locked=isLocked(obj)
            global mmc;
            switch obj.Type
                case 'PFS'
                    locked=strcmp('Locked in focus',mmc.getProperty('TIPFSStatus','Status'));
                case 'none'
                    locked=false;
            end
        end
        
        function setOffset(obj,offset)
           global mmc
           switch obj.Type
               case 'PFS'
                   mmc.setPosition('TIPFSOffset',offset);
           end

        end
        
        function status=getStatus(obj)
           global mmc
           switch obj.Type
               case 'PFS'
                   status=mmc.getProperty('TIPFSStatus','Status');
           end
            
        end
        
        function offset=getOffset(obj)
            global mmc
            switch obj.Type
                case 'PFS'
                	offset=mmc.getPosition('TIPFSOffset');
                case 'none'
                    offset=0;
            end
        end
        
        



        
    end
    
end