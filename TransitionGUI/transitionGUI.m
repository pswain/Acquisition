function varargout = transitionGUI(varargin)
% TRANSITIONGUI MATLAB code for transitionGUI.fig
%      TRANSITIONGUI, by itself, creates a new TRANSITIONGUI or raises the existing
%      singleton*.
%
%      H = TRANSITIONGUI returns the handle to a new TRANSITIONGUI or the handle to
%      the existing singleton*.
%
%      TRANSITIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRANSITIONGUI.M with the given input arguments.
%
%      TRANSITIONGUI('Property','Value',...) creates a new TRANSITIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before transitionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to transitionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help transitionGUI

% Last Modified by GUIDE v2.5 02-Dec-2013 21:31:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @transitionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @transitionGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before transitionGUI is made visible.
function transitionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to transitionGUI (see VARARGIN)

% Choose default command line output for transitionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
extractnplot1(handles)
% UIWAIT makes transitionGUI wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = transitionGUI_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout={extractnplot1(handles)};
delete(hObject);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%nummod_input= get(handles.edit1, 'string');
%nummod_input= str2double(nummod_input);
%call to a function that updates the GUI to contain x number of module
%modification sections.


%function moduleModifsection(name, verticalposition)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

extractnplot1(handles)  
  

%edit3_output


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

extractnplot1(handles)  

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


extractnplot1(handles)  

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [step_values,slope]=linear_changes(start_value, finish, duration)
slope= (finish-start_value)/duration;
step_values= start_value:slope:start_value+(finish-start_value);


function [step_values,order]=exp_arrival(start_value, finish, order, number)
    if isempty(number)
        number=50;
    end
     if isempty(order)
        order=3
    end
    
normalized_transition= logspace(1, 1+order, number-1)
normalized_transition= normalized_transition/max(normalized_transition)

scale= finish-start_value
step_values= edges_match(start_value+scale*normalized_transition, start_value, finish)



function [step_values, order]=stabilization(start_value, finish, order, number)
    if isempty(number)
        number=50;
    end
    if isempty(order)
        order=3
    end
    
normalized_transition= logspace(1+order,1, number-1)
normalized_transition= 1-normalized_transition/max(normalized_transition)

scale= finish-start_value
step_values= edges_match(start_value+scale*normalized_transition, start_value, finish)


function [step_values, t]=sigmoidal_arrival(start_value, finish, a,c, number)
    if isempty(number)
        number=50;
    end
    if isempty(a)
        a=.35
    end
    if isempty(c)
        c= (start_value+finish)/2
    end
        
normalized_transition= normalized_sigmoidal(number, a,c)


scale= finish-start_value
step_values= edges_match(start_value+scale*normalized_transition, start_value,finish)
t= [a,c]

    function [step_values, c]=step(value, duration)
        c=1;
        step_values=ones(duration,1)'*value
        
        
        



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox5.
function listbox5_Callback(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox5
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


    %function linearplot(step_values

   %  linear_changes(start_value, finish, duration, start_time) 
    
    function output=extractnplot1(handles) 
        
      cla(handles.axes1);
          
       
total_duration=0        
%top row
duration1=        str2double(get(handles.edit3, 'string'))
total_duration=total_duration+duration1;
duration1=num2str(updateGranularity_duration(duration1, get(handles.uipanel2, 'UserData') ))
duration11=updateGranularity_duration(duration1, get(handles.uipanel2, 'UserData') )
initial_flow1=    str2double(get(handles.edit5, 'string'))
final_flow1=      str2double(get(handles.edit6, 'string'))
transition_type1= get(handles.listbox1, 'Value')
especial11= get(handles.slider3, 'Value')
especial12=get(handles.slider7, 'Value')
updateSlider(transition_type1, handles, 'slider3', 'text8', 'slider7', 'text12', 'edit5', 'text4', 'text5')
%upper middle row
duration2=  str2double(get(handles.edit8, 'string'))
total_duration=total_duration+duration2
duration2=num2str(updateGranularity_duration(duration2, get(handles.uipanel2, 'UserData') ))
initial_flow2= str2double(get(handles.edit9, 'string'))
final_flow2= str2double(get(handles.edit10, 'string'))
transition_type2= get(handles.listbox3, 'Value')
especial21= get(handles.slider4, 'Value')
especial22=get(handles.slider8, 'Value')
updateSlider(transition_type2, handles, 'slider4', 'text9', 'slider8', 'text13', 'edit9', 'text22', 'text23')
%lower middle row
duration3=  str2double(get(handles.edit11, 'string'))
total_duration=total_duration+duration3
duration3=num2str(updateGranularity_duration(duration3, get(handles.uipanel2, 'UserData') ))
initial_flow3=  str2double(get(handles.edit12, 'string'))
final_flow3= str2double(get(handles.edit13, 'string'))
transition_type3= get(handles.listbox4, 'Value')
especial31= get(handles.slider5, 'Value')
especial32=get(handles.slider9, 'Value')
updateSlider(transition_type3, handles, 'slider5', 'text10', 'slider9', 'text14', 'edit12', 'text24', 'text25')
%bottom row
duration4=  str2double(get(handles.edit14, 'string'))
total_duration=total_duration+duration4
duration4=num2str(updateGranularity_duration(duration4, get(handles.uipanel2, 'UserData') ))
initial_flow4= str2double(get(handles.edit15, 'string'))
final_flow4= str2double(get(handles.edit16, 'string'))
transition_type4=  get(handles.listbox5, 'Value')
especial41= get(handles.slider6, 'Value')
especial42=get(handles.slider10, 'Value')
updateSlider(transition_type4, handles, 'slider6', 'text11', 'slider10', 'text15', 'edit15', 'text26', 'text27' )

string1= design_transition(transition_type1, initial_flow1, final_flow1, duration1, especial11,especial12, getstate())
string2= design_transition(transition_type2, initial_flow2, final_flow2, duration2, especial21,especial22, getstate())
string3= design_transition(transition_type3, initial_flow3, final_flow3, duration3, especial31,especial32, getstate())
string4= design_transition(transition_type4, initial_flow4, final_flow4, duration4, especial41,especial42, getstate())

[tran1, misc1]=eval(string1);
[tran2, misc2]=eval(string2);
[tran3, misc3]=eval(string3);
[tran4, misc4]=eval(string4);


tran1=loop_transition(tran1, str2double(get(handles.edit17, 'string')));
tran2=loop_transition(tran2, str2double(get(handles.edit18, 'string')));
tran3=loop_transition(tran3, str2double(get(handles.edit19, 'string')));
tran4=loop_transition(tran4, str2double(get(handles.edit20, 'string')));
%cat(dim, a,b) allows to concatenate a vector a long a specified dimension


full_transition1= cat(2, tran1,trim_transitions(tran1,tran2), trim_transitions(tran2,tran3), trim_transitions(tran3,tran4))'

size(full_transition1)

%%total rate defines the upper and lower limits of flow rate. therefore the
%%lowest plotting limit will not be zero if the smallest value is not zero
%%so flow rates from both syringes can be added.
total_rate= max(full_transition1)+min(full_transition1);

full_transition2= total_rate-full_transition1

total_duration

total_length= size(full_transition1);

times=updateGranularity_times(get(handles.uipanel2, 'UserData'), total_length(1))
hold('on')
area( handles.axes1,times, ones(total_length)*total_rate)
area( handles.axes1, times, full_transition1, 'FaceColor','r')


hold('off')

%output={strrep(strrep(num2str(times), '  ' , ','), ',,', ','),strrep(strrep(num2str(full_transition1'), '  ' , ','), ',,', ','),strrep(strrep(num2str(full_transition2'), '  ' , ','), ',,', ',')} ;

output= [times', full_transition1, full_transition2];


%linear_changes(edit5_output, edit6_output, edit3_output, 0)
%plot( linear_changes(edit5_output, edit6_output, edit3_output, 0))   






%exp_arrival(20, 50, 3, 50)
%plot(handles.axes1, eval(string1))
%plot(handles.axes2, exp_arrival(50, 20, 3, 50))
%plot(handles.axes3, stabilization(20, 50, 3, 50))
%plot(handles.axes4, sigmoidal_arrival(20,50,.35, 25,50))
  

        function transition_string=design_transition(transition_type, start, finish, duration, especial1, especial2,state)
           if isempty(especial2)
               especial2=1
           end 
           
            switch transition_type
                case 1
                    transition_string=strcat('linear_changes(', num2str(start),',', num2str(finish),',', num2str(duration),')');  
            
                case 2
                    %function step_values=exp_arrival(start_value, finish, order, number)
                    transition_string=strcat('exp_arrival(', num2str(start),',', num2str(finish),',', num2str(especial1),',',num2str(duration), ')');  
                case 3
                    %step_values=sigmoidal_arrival(start_value, finish, a,c, number)
                    transition_string=strcat('sigmoidal_arrival(', num2str(start),',', num2str(finish),',',num2str(especial1),',', num2str(especial2),',', num2str(duration), ')');
                case 4
                    %step_values=stabilization(start_value, finish, order, number)
                    transition_string=strcat('stabilization(',  num2str(start),',', num2str(finish),',',num2str(especial1),',', num2str(duration) ,')');
                case 5
                    transition_string=strcat('step(', num2str(finish),',',num2str(duration),')');
                case 6
                    transition_string=strcat('param_switching(', num2str(start),',', num2str(finish),',', num2str(especial1),',', num2str(especial2),',',num2str(duration), ',', num2str(state), ')')
           
            end
            
            
            
            function updateSlider(transition_type, handles, objname, textname, slider2name, text2name, initialflowname, text3name, text4name)
              
                 switch transition_type
                case 1
                    
                    strcat('set(handles.', objname, ',''Enable'',''off'')')
                    eval(  strcat('set(handles.', text3name, ',''string'',''Initial flow rate'')'))
                     eval(  strcat('set(handles.', text4name, ',''string'',''Final flow rate'')'))
                    eval(  strcat('set(handles.', objname, ',''Enable'',''off'')'))
                    eval(  strcat('set(handles.', textname, ',''string'','''')'))
                    eval(  strcat('set(handles.', slider2name, ',''Visible'',''off'')'))
                    eval(  strcat('set(handles.', text2name, ',''string'','''')'))
                   eval(  strcat('set(handles.', initialflowname, ',''Visible'',''on'')'))
                case 2
                      slidervalue= num2str(eval(strcat('get(handles.', objname, ',''Value'')')))
                      eval(  strcat('set(handles.', text3name, ',''string'',''Initial flow rate'')'))
                     eval(  strcat('set(handles.', text4name, ',''string'',''Final flow rate'')'))
                    eval(  strcat('set(handles.', objname, ',''Enable'',''on'')'))
                    eval(  strcat('set(handles.', textname, ',''string'',''order:  ', slidervalue, '  '')'))
                    eval(  strcat('set(handles.', slider2name, ',''Visible'',''off'')'))
                    eval(  strcat('set(handles.', text2name, ',''string'','''')'))
                   eval(  strcat('set(handles.', initialflowname, ',''Visible'',''on'')'))
                case 3
                      slidervalue= num2str(eval(strcat('get(handles.', objname, ',''Value'')')))
                      eval(  strcat('set(handles.', text3name, ',''string'',''Initial flow rate'')'))
                     eval(  strcat('set(handles.', text4name, ',''string'',''Final flow rate'')'))
                      slider2value= num2str(eval(strcat('get(handles.', slider2name, ',''Value'')')))
                    eval(  strcat('set(handles.', objname, ',''Enable'',''on'')'))
                     eval(  strcat('set(handles.', textname, ',''string'',''Param 1:  ', slidervalue, '  '')'))
                     eval(  strcat('set(handles.', text2name, ',''string'',''Param 2:  ', slider2value, '  '')'))
                     eval(  strcat('set(handles.', slider2name, ',''Visible'',''on'')'))
                    eval(  strcat('set(handles.', initialflowname, ',''Visible'',''on'')'))
                     
                case 4
                      slidervalue= num2str(eval(strcat('get(handles.', objname, ',''Value'')')))
                    eval(  strcat('set(handles.', text3name, ',''string'',''Initial flow rate'')'))
                     eval(  strcat('set(handles.', text4name, ',''string'',''Final flow rate'')'))
                      eval(  strcat('set(handles.', objname, ',''Enable'',''on'')'))
                     eval(  strcat('set(handles.', slider2name, ',''Visible'',''off'')'))
                     eval(  strcat('set(handles.', text2name, ',''string'','''')'))
                     eval(  strcat('set(handles.', textname, ',''string'',''order :  ', slidervalue, '  '')'))
                     eval(  strcat('set(handles.', initialflowname, ',''Visible'',''on'')'))
                case 5
                     eval(  strcat('set(handles.', objname, ',''Enable'',''off'')'))
                     eval(  strcat('set(handles.', text3name, ',''string'',''Initial flow rate'')'))
                     eval(  strcat('set(handles.', text4name, ',''string'',''Final flow rate'')'))
                     eval(  strcat('set(handles.', textname, ',''string'','''')'))
                     eval(  strcat('set(handles.', slider2name, ',''Visible'',''off'')'))
                     eval(  strcat('set(handles.', text2name, ',''string'','''')'))
                     eval(  strcat('set(handles.', initialflowname, ',''Visible'',''off'')'))
                     
                case 6
                   
                     slidervalue= num2str(eval(strcat('get(handles.', objname, ',''Value'')')))
                    slider2value= num2str(eval(strcat('get(handles.', slider2name, ',''Value'')')))
                     eval(  strcat('set(handles.', objname, ',''Enable'',''on'')'))
                     eval(  strcat('set(handles.', text3name, ',''string'',''Low flow rate'')'))
                     eval(  strcat('set(handles.', text4name, ',''string'',''High flow rate'')'))
                     eval(  strcat('set(handles.', slider2name, ',''Visible'',''on'')'))
                     
                     eval(  strcat('set(handles.', initialflowname, ',''Visible'',''on'')'))  
                     %eval(  strcat('set(handles.', textname, ',''string'',''Khigh low:  ', slidervalue, '  '')'))
                      eval(  strcat('set(handles.', textname, ',''string'',''Param 1:  ', slidervalue, '  '')'))
                     eval(  strcat('set(handles.', text2name, ',''string'',''Param 2:  ', slider2value, '  '')'))
                     %eval(  strcat('set(handles.', text2name, ',''string'',''Klow high:  ', slider2value, '  '')'))
                     
                     
            end
                
                
                    


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
extractnplot1(handles)


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

extractnplot1(handles)
% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

extractnplot1(handles) 
% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

extractnplot1(handles) 
% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
extractnplot1(handles) 

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider10_Callback(hObject, ~, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
extractnplot1(handles) 

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choose_file(handles)

% --- Executes on button press in coarse.
function coarse_Callback(hObject, eventdata, handles)
% hObject    handle to coarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of coarse


% --- Executes on button press in medium.
function medium_Callback(hObject, eventdata, handles)
% hObject    handle to medium (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of medium


% --- Executes on button press in fine.
function fine_Callback(hObject, eventdata, handles)
% hObject    handle to fine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fine


    function  choose_file(handles)
        
        [file,path]= uiputfile('Transition1.csv')
        
        set(handles.filename, 'string', strcat(path,file))
        
        
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tran=extractnplot1(handles)
create_file(tran, handles)


    function create_file(transition, handles)
  file=get(handles.filename, 'string')
        csvwrite(file, transition)
  
        switch ismac
            
            case 0
                open(file)
            case 1
                system(['open', ' ',file])
                
        end
        
        
        function transition2=trim_transitions(transition1, transition2)
            
            if transition1(end)== transition2(1)
            transition2=transition2(2:end)
            end
            
            function vector=edges_match(vector, start,finish)
                
                if vector(1)~= start
                    vector= [start,vector]
                end
                if vector(end)~=finish
                    vector=[vector,finish]
                end
                
                
                
    function [time_list, state_list] = param_switching(hi, lo, k_lohi, k_hilo, duration, state)
%function that creates a random sucession of switches as a function of the
%switching rate from low to high (k_lohi) and switching rate from high to low (k_hilo).
%starting at time 0 and at state x where x can be either lo or hi
%, we choose the next switching time by sampling an exponential
%distribution with lambda= k_hilo if the current state is hi, and lambda=k_lohi if
%the current state is low. then the selected switching time is stored and
%time is set to the new time. current state is stored in a state list and
%updated to the next state.
%Note: for simplicity, duration, k_lohi, k_hilo will be expressed in the same time units 
i=2;
time=0;
time_list=0;
state_list(1)=state
while time < duration


switch state_list(i-1)
    case hi    
time_list(i)= time_list(i-1)+exprnd(k_hilo);
    case lo
        time_list(i)= time_list(i-1)+exprnd(k_lohi);
        
end
  time=time_list(i);
state=state_switch(state,hi,lo);
state_list(i)= state;
i=i+1;


end

if  time_list(end)>duration
        time_list=time_list(1:end-1)
        state_list= state_list(1:end-1)
end

     
function finalst=paramswitchplot(times, states)
timeslbm= times+0.0001
stateslbm= [states(1) states]
y=size(times)
finalst(1, 1:2)= [times(1) states(1)]
k=2
for i=2:y(2)
    
   finalst(k:k+1,1:2)= vertcat( horzcat(times(i), stateslbm(i)), horzcat(timeslbm(i), stateslbm(i+1)));
   k=k+2
end

%area(finalst(:,1))
                
                    
   %%pending: this function should get information from a collection of
   %%radial buttons that decide which is the starting state. it could be
   %%selected by the user or calculated but we havent decided yet.
    function value=getstate()

        value=60
        
     
        %function sliderkeycallback()
            
            

                
        


% --- Executes on key press with focus on slider3 and none of its controls.
function slider3_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
disp(eventdata.Key)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(handles.figure1,'Waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path]=uigetfile()

fullfilename= [path filename]

handles= load(fullfilename, 'handles')

extractnplot1(handles)


function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
extractnplot1(handles)

% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double

extractnplot1(handles)
% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double

extractnplot1(handles)
% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double

extractnplot1(handles)
% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



    function final=loop_transition(steps, times)
        
        final=repmat(steps,[1,times])


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path]=uiputfile('Transition1.mat')
fullfilename= [path filename]

save(fullfilename, 'handles')


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


    function duration=updateGranularity_duration(duration, granularity)
        duration=duration*granularity;
        
    


        function times=updateGranularity_times(granularity, totalduration)
           x=1/granularity;
            %times= 0:x:totalduration;
            times(1)=0;
            for i=2:(totalduration)
            times(i)=times(i-1)+x    ;
            
            end
            
           % x=totalduration*granularity
            %times=linspace(0,totalduration, x)
        
            


% --- Executes when selected object is changed in uipanel2.
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel2 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag')
    case 'fine'
        set(handles.uipanel2, 'UserData', 5);
        extractnplot1(handles);
    case 'medium'
        set(handles.uipanel2, 'UserData', 2);
       extractnplot1(handles);
    case 'coarse'
        set(handles.uipanel2, 'UserData', 1);
         extractnplot1(handles);
end
