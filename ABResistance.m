function varargout = ABResistance(varargin)

% This is the file for the Structural model
%
% When a user selects features of antimicrobial and bacteria from the structural GUI, the name fields of the antimicrobial and bacteria will include all names that match the selected features based on the predefined matrices. This is done by collecting the names of the antimicrobial and bacteria that match the features in the antimicrobial and bacteria matrices.
% Then the user selects the sites he wants to study. From the generated matrix representing the whole database, we collect the entries that match the antimicrobial names, bacteria names, and studied sites. This is done using the Matlab file �SelectFromR.m� as part of the structural GUI file �ABresistance.fig�.
% The new generated matrix that satisfies the selected conditions of antimicrobial, bacteria, and site is now ready for work:
% 1.	First order the entries based on the studied dates from the oldest to the newest.
% 2.	Then since we want to study the trend of AMR over years we will use a unit of one year.
% 3.	For the entries having an interval of studied time more than one year, the entry is split into a number of entries equivalent to the number of years. All the records of the cells of the original entry are left the same except for the total number of isolates and the number of resistant samples it is divided by the number of years. Steps 1 through 3 are done in the file �SlotTable.m� as part of the file �LumpMatrix.m�.
% 4.	Then if more than one entry of a given reference has the same date with different sites, we make them one entry and we add up the samples and the resistant samples and we calculate the percentage resistance for the new entry.
% 5.	If the user chooses from the GUI to lump the references, we do the same for the entries having the same starting and ending dates with different reference as we did in step 4.
% Steps 1 through 5 are executed in the file �LumpMatrix.m� as part of the �ABResistance.fig� GUI file.
% After preparing the data, now we can compute the difference resistance between two entries which are consecutive in time or with a difference of up to 5 available dates that comes after the date of the studied entry.
% The GUI generates a graph that reflects the structure of the AMR over time. The graph is built up of nodes and edges connecting the nodes. In the graph a node represents the number of isolates studied over a year, along with the value of resistance during the specified interval of time between the two mentioned dates. The dates are presented as starting month and year and end month and year, where the month is here January since we are assuming that the unite of date is one year. As for the edge, the label indicates the difference of months between two nodes along with the difference of resistances between the two nodes. This difference may be negative if the resistance decreased from a node going to another one. Also, the difference is not a straight forward subtraction of values between the nodes. The description of the edge label will come shortly.
% For a given node i, we calculate in months the average of the date between the start date and end date in the node, let�s say it is t(i) . In our model, the graph can visualize up to five differences relationship. The nth difference of time for the edge pointing to node i is calculated as follows:
%
% delta(n)t(i)=t(i)-[(t(i-1) +t(i-2)+..+t(i-n-1))/(n-1)]
%
% And the nth resistance difference for the edge pointing to node i is calculated as follows:
%
% delta(n)R(i)=t(i)-[(R(i-1) +R(i-2)+..+R(i-n-1))/(n-1)]
%
% The user can choose to visualize the first, second, third, fourth, and/or fifth difference AMR. The importance of such visualizations is to regard the evolution of the resistance difference over years.
% Users may choose to visualize the AMR for a site or to lump the results over multiple sites. This may be done to visualize if the AMR differs depending on the selected site for a given antibiotics-bacteria combination.
% �graphviz� is used as tool to visualize the graph of AMR trend over years. After specifying the content of the nodes, the connected nodes and the labels of the edges connecting those nodes, the code that generates the graph is written in an output text file (in our case its name is �output.txt�). Then we run from Matlab the dotty application and we pass it the output file in order to visualize the graph. The visualization of the structural graph is done when pressing on the button in the structural GUI.
% The generation of nodes, edges, labels, and other details related to the graphviz visualization (like title, colors of the edges, etc.) is done in the Matlab file �GenGraphvizLumpNew1.m� as part of the GUI file �ABResistance.fig�. The generated graph starts with a Start node and ends with an End node so that we will have a connected graph that is contained between the start and the end nodes.
% In the graph, for the selected differences, if the resistance difference on an edge is bigger than 90% of the variance of resistance differences over similar edge differences, the node to which this edge point to is colored red to indicate that a jump happened and that the resistance rose unexpectedly faster than before and/or after.
% On the opposite side, if the resistance difference is less than -90% of the variance of resistance differences over similar edge differences, the node to which this edge point to is colored green to indicate that a great resistance reduction happened and that the resistance diminished unexpectedly faster than before and/or after.
% For both cases the alarm encourages scientists to refer to the period of abrupt changes to analyze what could have happened to influence dramatically the resistance difference. This would lead to hypotheses of some historical/medical/environmental/economical/human interference/etc.. that may have caused the major changes on AMR.
% The importance of the graph, in addition to what has been mentioned till now and the tracking of abrupt changes in AMR, is the ability to visualize the relationship not only between one specific antimicrobial and one specific bacteria from the table; rather the data is concatenated and aggregated for a set of features of antimicrobial and bacteria, which allows the visualization of the results over a wider range and over a holistic view.
% Moreover one can choose to see one of the differences up to five differences where a flow may seem clear if the studied AMR was regarded over 3 difference date intervals for example and still be ambiguous if regarded over a one difference graph.






% ABRESISTANCE MATLAB code for ABResistance.fig
%      ABRESISTANCE, by itself, creates a new ABRESISTANCE or raises the existing
%      singleton*.
%
%      H = ABRESISTANCE returns the handle to a new ABRESISTANCE or the handle to
%      the existing singleton*.
%
%      ABRESISTANCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABRESISTANCE.M with the given input arguments.
%
%      ABRESISTANCE('Property','Value',...) creates a new ABRESISTANCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ABResistance_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ABResistance_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ABResistance

% Last Modified by GUIDE v2.5 06-Jul-2014 15:22:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ABResistance_OpeningFcn, ...
    'gui_OutputFcn',  @ABResistance_OutputFcn, ...
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


% --- Executes just before ABResistance is made visible.
function ABResistance_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ABResistance (see VARARGIN)

% Choose default command line output for ABResistance
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ABResistance wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ABResistance_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)


% get the antibiotic and bacteria properties and search for the rows that
% satisfy them in the table.
global S
valSite=get(handles.listbox26, 'Value');%be sure to have at least one selected site
if (isempty(valSite))
    h = msgbox('You should specify at least one Site','','error');
    
    return;
end
siteLen=length(valSite);
newValSite=[];
[Lia,indexSite]= ismember('Urine',S.DatabaseTable.SiteVec);

for i=1:siteLen
    if (valSite(i)==2)% if nonUrine: add everything else than the Urine index from the siteVec
        
        for k=1:length(S.DatabaseTable.SiteVec)
            if( k ~=indexSite)
                newValSite=[newValSite k];
            end
        end
    elseif (valSite(i)==1)% if Urine: add just the Urine index from the siteVec
        newValSite=[newValSite indexSite];
    end
end
selectedAb=get(handles.listbox9, 'String');
selectedBact=get(handles.listbox20, 'String');

select_vector_a=[];
N=length(selectedAb);
for i=1:N
    [trueind,index]=ismember(selectedAb{i},S.DatabaseTable.AbtName);
    select_vector_a=[select_vector_a;index];
end
select_vector_b=[];
N=length(selectedBact);

for i=1:N
    [trueind,index]=ismember(selectedBact{i},S.DatabaseTable.BactName);
    select_vector_b=[select_vector_b;index];
end
selectedCountry=get(handles.country_menu, 'Value');

% [trueind,index]=ismember(selectedCountry,S.DatabaseTable.LocationVec);
select_vector_country=selectedCountry;


R1= SelectFromR (S.DatabaseTable.FinalData,select_vector_a, select_vector_b,newValSite,select_vector_country,1);%indicate the vectore of antibiotics and bacteria and the sites to study

if (isempty (R1))
    %indicate that there is no record found for such antibiotic/bacteria
    %properties combinations
    
    msgbox('No record is found for such antibiotic/bacteria/site properties combination','Error in selected properties','error')
    
else
    
    
    
    LumpRef=0;
    %here the continuation depends on the fact if we have lumping or not.
    
    LumpSite=1;
    
    
    if (get(handles.checkbox14, 'Value'))
        LumpRef=1;
    end
    outStep(1)=get(handles.checkbox1, 'Value');
    outStep(2)=get(handles.checkbox2, 'Value');
    outStep(3)=get(handles.checkbox3, 'Value');
    outStep(4)=get(handles.checkbox4, 'Value');
    outStep(5)=get(handles.checkbox5, 'Value');
    
    [RelationMatrix AfterSlots LumpedMatrix RelationRefs]= LumpMatrix (R1,LumpRef,LumpSite);
    if (isempty(RelationMatrix))
        msgbox('Not enough data is found to build the graph','No data to display','error')
    else
        [Done]= GenGraphvizLumpNew1 (RelationMatrix,RelationRefs,outStep,selectedAb,selectedBact,'C:\Users\Downloads\graphviz-2.30\bin','C:\Users\Documents\MATLAB');
        
    end
    
    
    
    
end



% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu9


% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on pushbutton1 and none of its controls.
function pushbutton1_KeyPressFcn(hObject, eventdata, handles)

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global S
S=load('DatabaseTable.mat');


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


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


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


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


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19


% --- Executes on button press in checkbox20.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox20


% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21


% --- Executes on button press in checkbox22.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox22


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14


% --- Executes on button press in checkbox25.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox25


% --- Executes on button press in checkbox26.
function checkbox26_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox26


% --- Executes on button press in checkbox23.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox23


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24


% --- Executes on selection change in listbox7.
function listbox7_Callback(hObject, eventdata, handles)
% hObject    handle to listbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox7


% --- Executes during object creation, after setting all properties.
function listbox7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S


str1List=cellstr(get(handles.listbox7,'String'));
str2List=cellstr(get(handles.listbox9,'String'));
val=get(handles.listbox7, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if (isempty(str2List))
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
AbtNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.AbtMatrix(:,1)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    AbtNames=[AbtNames;S.DatabaseTable.AbtMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
AbtNames=unique(AbtNames);
% AbtG=unique(AbtG);
% AbtSG=unique(AbtSG);


strList=unique(strList);
set(handles.listbox9,'String', strList);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.listbox9, 'Value');
if (isempty(val))
    return;
else
    
    
    selected = get(handles.listbox9,'Value');
    prev_str = get(handles.listbox9, 'String');
    if ~isempty(prev_str)
        prev_str(get(handles.listbox9,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox9, 'String', prev_str, ...
                'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox9, 'String',{''});
        end
    end
end


% --- Executes on selection change in listbox8.
function listbox8_Callback(hObject, eventdata, handles)
% hObject    handle to listbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox8


% --- Executes during object creation, after setting all properties.
function listbox8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox15.
function listbox15_Callback(hObject, eventdata, handles)
% hObject    handle to listbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox15 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox15


% --- Executes during object creation, after setting all properties.
function listbox15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox16.
function listbox16_Callback(hObject, eventdata, handles)
% hObject    handle to listbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox16 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox16


% --- Executes during object creation, after setting all properties.
function listbox16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox17.
function listbox17_Callback(hObject, eventdata, handles)
% hObject    handle to listbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox17 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox17


% --- Executes during object creation, after setting all properties.
function listbox17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox18.
function listbox18_Callback(hObject, eventdata, handles)
% hObject    handle to listbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox18 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox18


% --- Executes during object creation, after setting all properties.
function listbox18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox19.
function listbox19_Callback(hObject, eventdata, handles)
% hObject    handle to listbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox19 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox19


% --- Executes during object creation, after setting all properties.
function listbox19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox20.
function listbox20_Callback(hObject, eventdata, handles)
% hObject    handle to listbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox20 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox20


% --- Executes during object creation, after setting all properties.
function listbox20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox21.
function listbox21_Callback(hObject, eventdata, handles)
% hObject    handle to listbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox21 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox21


% --- Executes during object creation, after setting all properties.
function listbox21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox22.
function listbox22_Callback(hObject, eventdata, handles)
% hObject    handle to listbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox22 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox22


% --- Executes during object creation, after setting all properties.
function listbox22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox23.
function listbox23_Callback(hObject, eventdata, handles)
% hObject    handle to listbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox23 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox23


% --- Executes during object creation, after setting all properties.
function listbox23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox24.
function listbox24_Callback(hObject, eventdata, handles)
% hObject    handle to listbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox24 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox24


% --- Executes during object creation, after setting all properties.
function listbox24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S


str1List=cellstr(get(handles.listbox15,'String'));
str2List=cellstr(get(handles.listbox20,'String'));
val=get(handles.listbox15, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if (isempty(str2List))
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
BactNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.BactMatrix(:,1)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
BactNames=unique(BactNames);
% AbtG=unique(AbtG);
% AbtSG=unique(AbtSG);


strList=unique(strList);
set(handles.listbox20,'String', strList);


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.listbox20, 'Value');
if (isempty(val))
    return;
else
    
    
    selected = get(handles.listbox20,'Value');
    prev_str = get(handles.listbox20, 'String');
    if ~isempty(prev_str)
        prev_str(get(handles.listbox20,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox20, 'String', prev_str, ...
                'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox20, 'String',{''});
        end
    end
end




% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S


str1List=cellstr(get(handles.listbox16,'String'));
str2List=cellstr(get(handles.listbox21,'String'));
val=get(handles.listbox16, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if (isempty(str2List))
    
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
BactNames=[];

for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.BactMatrix(:,2)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
    
    
end
%
BactNames=unique(BactNames);


strList=unique(strList);
set(handles.listbox21,'String', strList);

strList3=cellstr(get(handles.listbox20,'String'));
strList4=S.DatabaseTable.BactName(BactNames);
if (isempty(strList3))
    len=0;
    strList3=strList4;
else
    len=length(strList3{1});
    if (len==0)
        strList3=strList4;
    else
        strList3= union(strList3,strList4);
    end
end
set(handles.listbox20,'String', strList3);



% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S

val=get(handles.listbox21, 'Value');
if (isempty(val))
    return;
else
    
    %get what are the antibiotics to remove from the listbox9
    
    selected = get(handles.listbox21,'Value');
    prev_str = get(handles.listbox21, 'String');
    lenVal=length(selected);
    BactNames=[];
    for i=1:lenVal
        [true1,id1]=ismember( prev_str(selected(i)),S.DatabaseTable.BactGenus);
        
        [r c v]=find(S.DatabaseTable.BactMatrix(:,2)==id1);%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
        BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
        
    end
    %[C,ia,ib] = intersect(A,B)
    BacNames=get(handles.listbox20, 'String');
    
    [newNames,ia,ib]=intersect(BacNames,S.DatabaseTable.BactName(BactNames));
    BacNames(ia)=[];
    if (length(BacNames)>0)
        set(handles.listbox20, 'String',BacNames);
    else
        set(handles.listbox20, 'String',{''});
    end
    
    if ~isempty(prev_str)
        prev_str(get(handles.listbox21,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox21, 'String', prev_str,'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox21, 'String', {''});
        end
    else
        set(handles.listbox21, 'String', {''});
    end
    
    
end


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S


str1List=cellstr(get(handles.listbox17,'String'));
str2List=cellstr(get(handles.listbox22,'String'));
val=get(handles.listbox17, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if (isempty(str2List))
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
BactNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.BactMatrix(:,3)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
BactNames=unique(BactNames);
% AbtG=unique(AbtG);
% AbtSG=unique(AbtSG);


strList=unique(strList);
set(handles.listbox22,'String', strList);

strList3=cellstr(get(handles.listbox20,'String'));
strList4=S.DatabaseTable.BactName(BactNames);
len=length(strList3{1});
if (len==0)
    strList3=strList4;
else
    strList3= union(strList3,strList4);
end
set(handles.listbox20,'String', strList3);


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global S

val=get(handles.listbox22, 'Value');
if (isempty(val))
    return;
else
    
    %get what are the antibiotics to remove from the listbox9
    
    selected = get(handles.listbox22,'Value');
    prev_str = get(handles.listbox22, 'String');
    lenVal=length(selected);
    BactNames=[];
    for i=1:lenVal
        [true1,id1]=ismember( prev_str(selected(i)),S.DatabaseTable.BactSpecies);
        
        [r c v]=find(S.DatabaseTable.BactMatrix(:,3)==id1);%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
        BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
        
    end
    %[C,ia,ib] = intersect(A,B)
    BacNames=get(handles.listbox20, 'String');
    
    [newNames,ia,ib]=intersect(BacNames,S.DatabaseTable.BactName(BactNames));
    BacNames(ia)=[];
    if (length(BacNames)>0)
        set(handles.listbox20, 'String',BacNames);
    else
        set(handles.listbox20, 'String',{''});
    end
    
    if ~isempty(prev_str)
        prev_str(get(handles.listbox22,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox22, 'String', prev_str,'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox22, 'String', {''});
        end
    else
        set(handles.listbox22, 'String', {''});
    end
end




% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global S


str1List=cellstr(get(handles.listbox18,'String'));
str2List=cellstr(get(handles.listbox23,'String'));
val=get(handles.listbox18, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if(isempty(str2List))
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
BactNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.BactMatrix(:,4)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
BactNames=unique(BactNames);



strList=unique(strList);
set(handles.listbox23,'String', strList);

strList3=cellstr(get(handles.listbox20,'String'));
strList4=S.DatabaseTable.BactName(BactNames);
if (isempty(strList3))
    len=0;
else
    len=length(strList3{1});
end
if (len==0)
    strList3=strList4;
else
    strList3= union(strList3,strList4);
end
set(handles.listbox20,'String', strList3);

% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S

val=get(handles.listbox23, 'Value');
if (isempty(val))
    return;
else
    
    %get what are the antibiotics to remove from the listbox9
    
    selected = get(handles.listbox23,'Value');
    prev_str = get(handles.listbox23, 'String');
    lenVal=length(selected);
    BactNames=[];
    for i=1:lenVal
        [true1,id1]=ismember( prev_str(selected(i)),S.DatabaseTable.BactGroup);
        
        [r c v]=find(S.DatabaseTable.BactMatrix(:,4)==id1);%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
        BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
        
    end
    %[C,ia,ib] = intersect(A,B)
    BacNames=get(handles.listbox20, 'String');
    
    [newNames,ia,ib]=intersect(BacNames,S.DatabaseTable.BactName(BactNames));
    BacNames(ia)=[];
    if (length(BacNames)>0)
        set(handles.listbox20, 'String',BacNames);
    else
        set(handles.listbox20, 'String',{''});
    end
    
    if ~isempty(prev_str)
        prev_str(get(handles.listbox23,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox23, 'String', prev_str,'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox23, 'String', {''});
        end
    else
        set(handles.listbox23, 'String', {''});
    end
end



% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global S


str1List=cellstr(get(handles.listbox19,'String'));
str2List=cellstr(get(handles.listbox24,'String'));
val=get(handles.listbox19, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if(isempty(str2List))
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
BactNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.BactMatrix(:,5)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
BactNames=unique(BactNames);



strList=unique(strList);
set(handles.listbox24,'String', strList);

strList3=cellstr(get(handles.listbox20,'String'));
strList4=S.DatabaseTable.BactName(BactNames);
if (isempty(strList3))
    len=0;
else
    len=length(strList3{1});
end
if (len==0)
    strList3=strList4;
else
    strList3= union(strList3,strList4);
end
set(handles.listbox20,'String', strList3);


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S

val=get(handles.listbox24, 'Value');
if (isempty(val))
    return;
else
    
    %get what are the antibiotics to remove from the listbox9
    
    selected = get(handles.listbox24,'Value');
    prev_str = get(handles.listbox24, 'String');
    lenVal=length(selected);
    BactNames=[];
    for i=1:lenVal
        [true1,id1]=ismember( prev_str(selected(i)),S.DatabaseTable.BactDiarrhea);
        
        [r c v]=find(S.DatabaseTable.BactMatrix(:,5)==id1);%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
        BactNames=[BactNames;S.DatabaseTable.BactMatrix(r,1)];
        
    end
    %[C,ia,ib] = intersect(A,B)
    BacNames=get(handles.listbox20, 'String');
    
    [newNames,ia,ib]=intersect(BacNames,S.DatabaseTable.BactName(BactNames));
    BacNames(ia)=[];
    if (length(BacNames)>0)
        set(handles.listbox20, 'String',BacNames);
    else
        set(handles.listbox20, 'String',{''});
    end
    
    if ~isempty(prev_str)
        prev_str(get(handles.listbox24,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox24, 'String', prev_str,'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox24, 'String', {''});
        end
    else
        set(handles.listbox24, 'String', {''});
    end
end




% --- Executes on selection change in listbox9.
function listbox9_Callback(hObject, eventdata, handles)
% hObject    handle to listbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox9


% --- Executes during object creation, after setting all properties.
function listbox9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox10.
function listbox10_Callback(hObject, eventdata, handles)
% hObject    handle to listbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox10


% --- Executes during object creation, after setting all properties.
function listbox10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox11.
function listbox11_Callback(hObject, eventdata, handles)
% hObject    handle to listbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox11


% --- Executes during object creation, after setting all properties.
function listbox11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox12.
function listbox12_Callback(hObject, eventdata, handles)
% hObject    handle to listbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox12


% --- Executes during object creation, after setting all properties.
function listbox12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S


str1List=cellstr(get(handles.listbox8,'String'));
str2List=cellstr(get(handles.listbox10,'String'));
val=get(handles.listbox8, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if (isempty(str2List))
    
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
AbtNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.AbtMatrix(:,2)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    AbtNames=[AbtNames;S.DatabaseTable.AbtMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
AbtNames=unique(AbtNames);
% AbtG=unique(AbtG);
% AbtSG=unique(AbtSG);


strList=unique(strList);
set(handles.listbox10,'String', strList);

strList3=cellstr(get(handles.listbox9,'String'));
strList4=S.DatabaseTable.AbtName(AbtNames);
if (isempty(strList3))
    len=0;
    strList3=strList4;
else
    len=length(strList3{1});
    if (len==0)
        strList3=strList4;
    else
        strList3= union(strList3,strList4);
    end
end
set(handles.listbox9,'String', strList3);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S

val=get(handles.listbox10, 'Value');
if (isempty(val))
    return;
else
    
    %get what are the antibiotics to remove from the listbox9
    
    selected = get(handles.listbox10,'Value');
    prev_str = get(handles.listbox10, 'String');
    lenVal=length(selected);
    AbtNames=[]
    for i=1:lenVal
        [true1,id1]=ismember( prev_str(selected(i)),S.DatabaseTable.AbtGroup);
        
        [r c v]=find(S.DatabaseTable.AbtMatrix(:,2)==id1);%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
        AbtNames=[AbtNames;S.DatabaseTable.AbtMatrix(r,1)];
        
    end
    %[C,ia,ib] = intersect(A,B)
    AbNames=get(handles.listbox9, 'String');
    [newNames,ia,ib]=intersect(AbNames,S.DatabaseTable.AbtName(AbtNames));
    AbNames(ia)=[];
    if (length(AbNames)>0)
        set(handles.listbox9, 'String',AbNames);
    else
        set(handles.listbox9, 'String',{''});
    end
    if ~isempty(prev_str)
        prev_str(get(handles.listbox10,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox10, 'String', prev_str,'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox10, 'String', {''});
        end
    else
        set(handles.listbox10, 'String', {''});
    end
    
    
end



% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S


str1List=cellstr(get(handles.listbox11,'String'));
str2List=cellstr(get(handles.listbox13,'String'));
val=get(handles.listbox11, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if (isempty(str2List))
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
AbtNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.AbtMatrix(:,3)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    AbtNames=[AbtNames;S.DatabaseTable.AbtMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
AbtNames=unique(AbtNames);
% AbtG=unique(AbtG);
% AbtSG=unique(AbtSG);


strList=unique(strList);
set(handles.listbox13,'String', strList);

strList3=cellstr(get(handles.listbox9,'String'));
strList4=S.DatabaseTable.AbtName(AbtNames);
len=length(strList3{1});
if (len==0)
    strList3=strList4;
else
    strList3= union(strList3,strList4);
end
set(handles.listbox9,'String', strList3);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global S

val=get(handles.listbox13, 'Value');
if (isempty(val))
    return;
else
    
    %get what are the antibiotics to remove from the listbox9
    
    selected = get(handles.listbox13,'Value');
    prev_str = get(handles.listbox13, 'String');
    lenVal=length(selected);
    AbtNames=[]
    for i=1:lenVal
        [true1,id1]=ismember( prev_str(selected(i)),S.DatabaseTable.AbtSubGroup);
        
        [r c v]=find(S.DatabaseTable.AbtMatrix(:,3)==id1);%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
        AbtNames=[AbtNames;S.DatabaseTable.AbtMatrix(r,1)];
        
    end
    %[C,ia,ib] = intersect(A,B)
    AbNames=get(handles.listbox9, 'String');
    [newNames,ia,ib]=intersect(AbNames,S.DatabaseTable.AbtName(AbtNames));
    AbNames(ia)=[];
    if (length(AbNames)>0)
        set(handles.listbox9, 'String',AbNames);
    else
        set(handles.listbox9, 'String',{''});
    end
    if ~isempty(prev_str)
        prev_str(get(handles.listbox13,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox13, 'String', prev_str,'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox13, 'String', {''});
        end
    else
        set(handles.listbox13, 'String', {''});
    end
    
    
end





% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S


str1List=cellstr(get(handles.listbox12,'String'));
str2List=cellstr(get(handles.listbox14,'String'));
val=get(handles.listbox12, 'Value');
if (isempty(val))
    return;
end
val2Len=0;
strList={};
if(isempty(str2List))
    len=0;
else
    len=length(str2List{1});
end
if (len==0)
    val2Len=0;
else
    val2Len=length(str2List);
    for i=1:val2Len
        strList{i}=str2List{i};
    end
end

valLen=length(val);
AbtNames=[];
% AbtG=[];
% AbtSG=[];
for i=1:valLen
    
    strList{i+val2Len}=  str1List{val(i)};
    [r c v]=find(S.DatabaseTable.AbtMatrix(:,4)==val(i));%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
    AbtNames=[AbtNames;S.DatabaseTable.AbtMatrix(r,1)];
    %    AbtG=[AbtG;S.DatabaseTable.AbtMatrix(r,2)];
    %    AbtSG=[AbtSG;S.DatabaseTable.AbtMatrix(r,3)];
    
end
%
AbtNames=unique(AbtNames);
% AbtG=unique(AbtG);
% AbtSG=unique(AbtSG);


strList=unique(strList);
set(handles.listbox14,'String', strList);

strList3=cellstr(get(handles.listbox9,'String'));
strList4=S.DatabaseTable.AbtName(AbtNames);
if (isempty(strList3))
    len=0;
else
    len=length(strList3{1});
end
if (len==0)
    strList3=strList4;
else
    strList3= union(strList3,strList4);
end
set(handles.listbox9,'String', strList3);

%find in the antibiotic matrix which antibiotic names have such variant and
%add them to the name right list



%

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global S

val=get(handles.listbox14, 'Value');
if (isempty(val))
    return;
else
    
    %get what are the antibiotics to remove from the listbox9
    
    selected = get(handles.listbox14,'Value');
    prev_str = get(handles.listbox14, 'String');
    lenVal=length(selected);
    AbtNames=[]
    for i=1:lenVal
        [true1,id1]=ismember( prev_str(selected(i)),S.DatabaseTable.AbtVariant);
        
        [r c v]=find(S.DatabaseTable.AbtMatrix(:,4)==id1);%for the non-wildcard parameters get the antibiotic matrix rows that have similar values of parameters of select_vector_a
        AbtNames=[AbtNames;S.DatabaseTable.AbtMatrix(r,1)];
        
    end
    %[C,ia,ib] = intersect(A,B)
    AbNames=get(handles.listbox9, 'String');
    [newNames,ia,ib]=intersect(AbNames,S.DatabaseTable.AbtName(AbtNames));
    AbNames(ia)=[];
    if (length(AbNames)>0)
        set(handles.listbox9, 'String',AbNames);
    else
        set(handles.listbox9, 'String',{''});
    end
    if ~isempty(prev_str)
        prev_str(get(handles.listbox14,'Value')) = [];
        if (length(prev_str)>0)
            set(handles.listbox14, 'String', prev_str,'Value', min(selected,length(prev_str)));
        else
            set(handles.listbox14, 'String', {''});
        end
    else
        set(handles.listbox14, 'String', {''});
    end
    
end

% --- Executes on selection change in listbox13.
function listbox13_Callback(hObject, eventdata, handles)
% hObject    handle to listbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox13


% --- Executes during object creation, after setting all properties.
function listbox13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox14.
function listbox14_Callback(hObject, eventdata, handles)
% hObject    handle to listbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox14


% --- Executes during object creation, after setting all properties.
function listbox14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox26.
function listbox26_Callback(hObject, eventdata, handles)
% hObject    handle to listbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox26 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox26


% --- Executes during object creation, after setting all properties.
function listbox26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in country_menu.
function country_menu_Callback(hObject, eventdata, handles)
% hObject    handle to country_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns country_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from country_menu


% --- Executes during object creation, after setting all properties.
function country_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to country_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
