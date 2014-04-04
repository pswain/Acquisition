classdef DemoMMC
   properties
       exposure=0;
       shutterDevice;
       devices;%structure with fields named for the devices
       autoShutter;
   end
   methods
   
       function mmc=DemoMMC()
          %Constructor function - initialises device properties 
          mmc.devices.TIPFSStatus.Status='Locked';
          mmc.devices.TIPFSOffset.Position=0;
          mmc.devices.XYStage.XPosition=0;
          mmc.devices.XYStage.YPosition=0;
          mmc.devices.TIZDrive.Position=0;
          mmc.devices.Evolve.MultiplierGain=270;
          mmc.devices.Evolve.Port='Normal';
          mmc.devices.DTOL_Switch.State=0;
          mmc.devices.PIFOC.Position=0;

         
          
          
          
       end
       function loadSystemConfiguration(mmc, filepath)
           %demo load config function - currently does nothing - could be
           %used to get a config file with various demo devices for more
           %detailed testing of the code
           disp('loadSystemConfiguration - demo function was run');
           disp('filepath');
       end
       function mmc=setConfig (mmc,groupName,configName)
          disp('setConfig - demo function was run');
          disp(['Configuration set: ' groupName ',' configName]);
          
          if strcmp(groupName,'Channel')
              switch configName
                  case 'GFP'
                      mmc=mmc.setProperty('DTOL_Switch','State',4);
                      mmc=mmc.setProperty('DTOL_Switch','Label','Digital 2');
                      mmc=mmc.setProperty('TIAnalyzer','Inserted','Extracted');
                      mmc=mmc.setProperty('TIFilterBlock1','Label','4-G/mC');
                      mmc=mmc.setProperty('TIFilterBlock1','State',3);
                      mmc=mmc.setProperty('EmissionFilterWheel','Label','GFP');
                      mmc=mmc.setProperty('EmissionFilterWheel','State',4);                                          
                  case 'DIC'
                      mmc=mmc.setProperty('DTOL_Switch','State',1);
                      mmc=mmc.setProperty('DTOL_Switch','Label','Digital 0');
                      mmc=mmc.setProperty('TIAnalyzer','Inserted','Inserted');
                      mmc=mmc.setProperty('TIFilterBlock1','Label','2-ANALY');
                      mmc=mmc.setProperty('TIFilterBlock1','State',1);
                      mmc=mmc.setProperty('EmissionFilterWheel','Label','Open1');
                      mmc=mmc.setProperty('EmissionFilterWheel','State',7);   
                  case 'GFPAutoFL'
                      mmc=mmc.setProperty('DTOL_Switch','State',4);
                      mmc=mmc.setProperty('DTOL_Switch','Label','Digital 2');
                      mmc=mmc.setProperty('TIAnalyzer','Inserted','Extracted');
                      mmc=mmc.setProperty('TIFilterBlock1','Label','4-G/mC');
                      mmc=mmc.setProperty('TIFilterBlock1','State',3);
                      mmc=mmc.setProperty('EmissionFilterWheel','Label','tdTomato');
                      mmc=mmc.setProperty('EmissionFilterWheel','State',5);   
                  case 'CFP'
                      mmc=mmc.setProperty('DTOL_Switch','State',2);
                      mmc=mmc.setProperty('DTOL_Switch','Label','Digital 1');
                      mmc=mmc.setProperty('TIAnalyzer','Inserted','Extracted');
                      mmc=mmc.setProperty('TIFilterBlock1','Label','3-C/Y/C');
                      mmc=mmc.setProperty('TIFilterBlock1','State',2);
                      mmc=mmc.setProperty('EmissionFilterWheel','Label','CFP');
                      mmc=mmc.setProperty('EmissionFilterWheel','State',1);   
                  case 'YFP'
                      mmc=mmc.setProperty('DTOL_Switch','State',4);
                      mmc=mmc.setProperty('DTOL_Switch','Label','Digital 2');
                      mmc=mmc.setProperty('TIAnalyzer','Inserted','Extracted');
                      mmc=mmc.setProperty('TIFilterBlock1','Label','3-C/Y/C');
                      mmc=mmc.setProperty('TIFilterBlock1','State',2);
                      mmc=mmc.setProperty('EmissionFilterWheel','Label','YFP');
                      mmc=mmc.setProperty('EmissionFilterWheel','State',2);   
                  case 'mCherry'
                      mmc=mmc.setProperty('DTOL_Switch','State',8);
                      mmc=mmc.setProperty('DTOL_Switch','Label','Digital 3');
                      mmc=mmc.setProperty('TIAnalyzer','Inserted','Extracted');
                      mmc=mmc.setProperty('TIFilterBlock1','Label','4-G/mC');
                      mmc=mmc.setProperty('TIFilterBlock1','State',3);
                      mmc=mmc.setProperty('EmissionFilterWheel','Label','mCherry');
                      mmc=mmc.setProperty('EmissionFilterWheel','State',3);   
                  case 'tdTomato'       
                      mmc=mmc.setProperty('DTOL_Switch','State',8);
                      mmc=mmc.setProperty('DTOL_Switch','Label','Digital 3');
                      mmc=mmc.setProperty('TIAnalyzer','Inserted','Extracted');
                      mmc=mmc.setProperty('TIFilterBlock1','Label','5-tdTom');
                      mmc=mmc.setProperty('TIFilterBlock1','State',4);
                      mmc=mmc.setProperty('EmissionFilterWheel','Label','tdTomato');
                      mmc=mmc.setProperty('EmissionFilterWheel','State',5);  
                  
              end
          end
          
          
          
       end
       
       function waitForConfig(mmc, groupName,chName)
          disp('waitForConfig - demo function was run');
       
       end

       
       function stopSequenceAcquisition(mmc)
            disp('stopSequenceAcquisition - demo function was run');

       end
       
       function setExposure (mmc,exposure)
          disp('setExposure - demo function was run');
          disp(['Exposure set to: ' num2str(exposure)]);
          mmc.exposure=exposure;       
       end
   
       function setShutterDevice(mmc,devicename)
           mmc.shutterDevice=devicename;
           disp('setShutterDevice - demo function was run');
       end
       
       function mmc=setProperty(mmc,deviceName, propertyName, propertyValue)
            propertyName(strfind(propertyName,' '))='_';%avoids a possible error of an invalid field name for the structure in the next line
            propertyName(strfind(propertyName,'('))='C';%avoids a possible error of an invalid field name for the structure in the next line
            propertyName(strfind(propertyName,')'))='S';%avoids a possible error of an invalid field name for the structure in the next line
            propertyName(strfind(propertyName,'-'))='_';%avoids a possible error of an invalid field name for the structure in the next line

            
            
            deviceName(strfind(deviceName,' '))='_';%avoids a possible error of an invalid field name for the structure in the next line
            deviceName(strfind(deviceName,'('))='C';%avoids a possible error of an invalid field name for the structure in the next line
            deviceName(strfind(deviceName,')'))='S';%avoids a possible error of an invalid field name for the structure in the next line
            deviceName(strfind(deviceName,'-'))='_';%avoids a possible error of an invalid field name for the structure in the next line

            
            mmc.devices.(deviceName).(propertyName)=propertyValue;
            disp('setProperty - demo function was run');
            if isnumeric(propertyValue)
                value=num2str(propertyValue);
            else
                value=propertyValue;
            end
            disp([deviceName ': ' propertyName ': ' value]);
       end
       
       function setAutoShutter(mmc,input);
            mmc.autoShutter=input;
            disp('setAutoShutter - demo function was run');

       end
       
       function propertyValue=getProperty(mmc,deviceName, propertyName)
            propertyName(strfind(propertyName,' '))='_';%avoids a possible error of an invalid field name for the structure in the next line
            propertyName(strfind(propertyName,'('))='C';%avoids a possible error of an invalid field name for the structure in the next line
            propertyName(strfind(propertyName,')'))='S';%avoids a possible error of an invalid field name for the structure in the next line
            propertyName(strfind(propertyName,'-'))='_';%avoids a possible error of an invalid field name for the structure in the next line

            
            
            deviceName(strfind(deviceName,' '))='_';%avoids a possible error of an invalid field name for the structure in the next line
            deviceName(strfind(deviceName,'('))='C';%avoids a possible error of an invalid field name for the structure in the next line
            deviceName(strfind(deviceName,')'))='S';%avoids a possible error of an invalid field name for the structure in the next line
            deviceName(strfind(deviceName,'-'))='_';%avoids a possible error of an invalid field name for the structure in the next line

            
            disp('getProperty - demo function was run');
            
            propertyValue=mmc.devices.(deviceName).(propertyName);
            
            if isnumeric(propertyValue)
                value=num2str(propertyValue);
            else
                value=propertyValue;
            end
            
            
            disp([deviceName ': ' propertyName ': ' value]);
       end
       
       function xPosition=getXPosition(mmc,device)
          xPosition=mmc.getProperty(device,'XPosition');
           
           
       end
       function yPosition=getYPosition(mmc,device)
          yPosition=mmc.getProperty(device,'YPosition');         
       end
           
       function zPosition=getZPosition(mmc,device)
          z=mmc.getProperty(device,'ZPosition');
       end
       
       function position=getPosition(mmc,device)
           position=mmc.getProperty(device,'Position');
       end
       
       function position=setPosition(mmc,device,position)
           position=mmc.setProperty(device,'Position',position);
       end
       
       function setXYPosition(mmc,device, x, y)
           mmc.setProperty(device,'XPosition',x);
           mmc.setProperty(device,'YPosition',y);
       end
       function waitForDevice(mmc,device)
       end
       function snapImage(mmc)
            disp('Image snapped - DemoMMC');         
       end
       
       function img=getImage(mmc)
           img=zeros(262144,1);
           img=uint16(img);
           for n=1:262144
                img(n)=rand*(2^16);
           end
           
       end
       
       
       
   end
end
    
    
    
