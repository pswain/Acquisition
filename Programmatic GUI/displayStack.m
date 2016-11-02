%Gui to display a stack of a single channel and timepoint - to be used when
%snapping a stack.
function displayStackGUI=displayStack(stack)
scrsz = get(0,'ScreenSize');
displayStackGUI.fig=figure('MenuBar','none','Position',[scrsz(3)/4 scrsz(3)/4 scrsz(3)/4 scrsz(3)/4]);
displayStackGUI.axes=axes('Parent',displayStackGUI.fig,'Position',[.05 .07 .9 .9]);
%Display the first image of the stack
image=double(stack(:,:,1));
image=image/max(image(:))*.95;
image=repmat(image,[1 1 3]);
displayStackGUI.image=imshow(image);
displayStackGUI.stack=stack;
sliderStep = [1/(size(stack,3)-1) 1/(size(stack,3)-1)];
displayStackGUI.slider=uicontrol('Style','slider',...
                'Parent',displayStackGUI.fig,...
                'Min',1,...
                'Max',size(stack,3),...
                'Units','normalized',...
                'Value',1,...
                'Position',[.05 .01 .9 .05],...
                'SliderStep',sliderStep,...
                'Callback',@(src,event)displayStackSlider_callback(displayStackGUI,src));
end


function displayStackSlider_callback(displayStackGUI,src)
z=get(src,'Value');
image=double(displayStackGUI.stack(:,:,z));
image=image/max(image(:))*.95;
image=repmat(image,[1 1 3]);
set(displayStackGUI.image,'CData',image);
end