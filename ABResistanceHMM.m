function varargout = ABResistanceHMM(varargin)


% This is the file for the Behavioral GUI
% 
% The Hidden Markov Model (HMM) was selected to predict the evolution of AMR over one year based on the given history.
% The file “DatabaseTable.mat” is used since it contains the preprocessed data as historical background to train the HMM, to predict the next year resistance, and to validate our model. Since the HMM is already explained in the text, we will only go into the technical steps to generate the HMM scores to come up with the next year predicted resistance.
% In the behavioral GUI, a user first selects the features of antimicrobial, bacteria, and site to study. Then he chooses a threshold value after which the expected resistance is classified beyond the acceptable medical value. Thus if the predicted next year resistance was above such threshold the GUI will color it red to indicate to the physician that it is not recommended to use the selected antimicrobial set to fight the selected set of bacteria.
% The user can choose the statistical mode to use for the predicted scores. He can select it to be permissive, moderate or restrictive. Also he can select whether he is using the model to validate its performance against the actual last recorded resistance, or to predict the expected next year resistance. The next year resistance is the resistance of the year next to the last entered year in the excel sheet. We will shortly explain the difference among these modes.
% When the user presses on the button “Generate HMM Score” the following is done:
% 1.	First, a matrix containing the entries satisfying the selected antimicrobial features, bacteria features, and sites is generated using the Matlab file “SelectFromR.m” as part of the behavioral GUI file “ABresistanceHMM.fig”.
% 2.	The same work done in the structural model to sort the data based on their date, and divide the entries that are over more than one year into entries of one year, and lumping the sites and references is done here also using the same files: “SlotTable.m” as part of the file “LumpMatrix.m” and “LumpMatrix.m” as part of the “ABResistanceHMM.fig” GUIfile.
% 3.	In the new preprocessed matrix, we quantize the resistance values to the nearest multiple of five number to be able to process the data adequately, since the presence of decimal numbers (as resistance values) may complicate the HMM training and prediction because it would significantly raise the number of possible emissions. For example, and since the difference resistance range lies between -100 and 100, if we have a unit difference of 5 between two consecutive resistances the total number of emissions would be 41. Whereas if we have a unit difference of 0.1 between two consecutive resistances instead of 5, the number of emissions would be 2001.
% 4.	Now the data is ready for training the HMM:
%       ?	Generate all the possible observations of month difference and
%       resistance difference for the given data using the Matlab file “GenerateAllSets.m” as part of this behavioralGUI file.
%       ?	Then input the observations to the HMM train that Matlab has as built in function along with the set of possible emissions. This is done using the Matlab file “TrainHMMNew.m” as part of this behavioral GUI file.
% 5.	After training the HMM, predict for the next year the score of each resistance (0%, 5%, 10%, .., 100%). And based on the score the predicted resistance is calculated as explained in the paper. To get the HMM score for each resistance we calculate the probability of the new observation sequence given by the HMM, let’s call it P(B1,B2,..Bn),and that of the first n-1 observation sequence which is P(B1,B2,B(n-1)), so that we can get the probability P(Bn) since the observations are mutually exclusive:
% 
% P(Bn)=P(B1,B2,..Bn)/P(B1,B2,B(n-1)) 
% 6.	Depending on the used mode (permissive, moderate, or restrictive), we choose a value ? to be respectively 0, 0.01, or 0.1.The final HMM score value for a given resistance is given by:
% 
% ScoreHMM = P(Bn)-?^(|threshold-expected Resistance|/5 +1)
% The Matlab code for the 5th and 6th steps is present in this file.
% Note that for the validation of our model, for a given n entries we train the HMM over n-1 entries. Then we predict the HMM score for the next year and we compare the predicted resistance to the actual one recorded in the excel sheet.
% Please note also that the HMM need at least a data set of more than five years to work correctly, so make sure that the selected set of antimicrobial, bacteria, sites give this minimum required number of years.
% 


% Last Modified by GUIDE v2.5 25-Dec-2013 13:26:05

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
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% get the antibiotic and bacteria properties and search for the rows that
% satisfy them in the table.

global S
yesPercent=0;
noPercent=0;

valSite=get(handles.listbox26, 'Value');%be sure to have at least one selected site

stringSite=get(handles.listbox26, 'String');%be sure to have at least one selected site


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
    
    h = msgbox('No record is found for such antibiotic/bacteria/site properties combination','Error in selected properties','error')
    
else
  if (length(R1(:,1))>10)
      R1=R1(end-9:end,:);  
  end
  alpha=0;
    HMM_Mode=get(handles.popupmenu11,'Value');
    if (HMM_Mode==1)
        alpha=0;
    elseif(HMM_Mode==2)
        alpha=0.01;
    else
        alpha=0.1;
    end
    
    
    %here the continuation depends on the fact if we have lumping or not.
    
    LumpSite=1;
    
    LumpRef=1;
    outStep(1)=1;
    outStep(2)=1;
    outStep(3)=1;
    outStep(4)=1;
    outStep(5)=1;
    validationCheck = get(handles.radiobutton3,'Value');
    % lump the results
    if (validationCheck==1)
        [RelationMatrix AfterSlots LumpedMatrix RelationRefs]= LumpMatrix (R1(1:end-1,:),LumpRef,LumpSite);
    else
        [RelationMatrix AfterSlots LumpedMatrix RelationRefs]= LumpMatrix (R1(1:end,:),LumpRef,LumpSite);
    end
    % Quantize the resistance percentages into 20 intervals from 0 to 100%(0,5,10,15,20,25,30,...,100)
    quatileVal=2;
    RelationMatrix(:,8)= num2fixpt(RelationMatrix(:,8),sfix(8),quatileVal,'Nearest');
    RelationMatrix(:,11)=num2fixpt(RelationMatrix(:,11),sfix(8),quatileVal,'Nearest');
    RelationMatrix(:,14)=num2fixpt(RelationMatrix(:,14),sfix(8),quatileVal,'Nearest');
    RelationMatrix(:,23)=num2fixpt(RelationMatrix(:,23),sfix(8),quatileVal,'Nearest');
    RelationMatrix(:,24)=num2fixpt(RelationMatrix(:,24),sfix(8),quatileVal,'Nearest');
    RelationMatrix(:,25)=num2fixpt(RelationMatrix(:,25),sfix(8),quatileVal,'Nearest');
    
    [AllObs, Emissions,EmisMatrix,flagIntermediate]= GenerateAllSets (RelationMatrix); %the flagIntermediate output indicates whether there is a significant number of differences to include it in the HMM or not.
   if (flagIntermediate)
     h = msgbox('Intermediate not zero','Error in selected properties','error')
   
   end
       [trans,emis]= TrainHMMNew (AllObs, Emissions);
    
    
    %get the emissions having 12 months difference
    ind=find(EmisMatrix(:,1)==12);
    StartY=max(RelationMatrix(:,6));
    EndY=StartY+1;
    ExpectedProb=[];
    new_data={};
    NProbs= length(ind);
    contents = cellstr(get(handles.popupmenu12,'String')) ;
    thresholdValue= str2num(contents{get(handles.popupmenu12,'Value')});
   totalN1= 100/quatileVal +1;
    for k1=1:totalN1
        resistancePercent= num2str((k1-1)*quatileVal );
     new_data{k1,1}=[resistancePercent '%'];
     new_data{k1,2}='0';
    end        
    
    k1=1;
           if (~ flagIntermediate)
            EmisMatrix= [EmisMatrix zeros(length(EmisMatrix),1)];
           end
               for k=1:NProbs
        
        ResistanceVal=RelationMatrix(end,14)+EmisMatrix(ind(k),2);

        IntermediateVal=RelationMatrix(end,25)+EmisMatrix(ind(k),3);
        
        if (ResistanceVal<0 || ResistanceVal>100 || IntermediateVal<0 || IntermediateVal>100 )
            continue;
        end
        newMatrix=[RelationMatrix(:,:);StartY 	EndY 	EndY 	EndY 	EndY 	EndY 	EmisMatrix(ind(k),1:2) RelationMatrix(end,12:14) RelationMatrix(end,19:20) RelationMatrix(end,14)+EmisMatrix(ind(k),2)	 RelationMatrix(end,19:22)	RelationMatrix(end,19)	 (RelationMatrix(end,20)+1) RelationMatrix(end,21:22) EmisMatrix(ind(k),3) RelationMatrix(end,25) RelationMatrix(end,25)+EmisMatrix(ind(k),3)];
        
        NewObs= NewSeq (newMatrix, flagIntermediate);
        
        [r1 c1]=size(NewObs);
        tempLen=[];
        for tm1=1:c1
            tempLen=[tempLen length(NewObs{tm1})];
            
        end
        [C,I]=max(tempLen);
        
        tableIndex=(RelationMatrix(end,14)+EmisMatrix(ind(k),2))/quatileVal+1;
        [PSTATES,logpseq]=hmmdecode(NewObs{I},trans,emis,'Symbols',Emissions);
        [PSTATES1,logpseq1]=hmmdecode({NewObs{1,I}{1,1:(end-1)}},trans,emis,'Symbols',Emissions);
        resistancePercent=num2str(RelationMatrix(end,14)+EmisMatrix(ind(k),2));
        ExpectedProb= [ExpectedProb (exp(logpseq)/exp(logpseq1))*100 ];
        alphaIndex= abs(thresholdValue-(RelationMatrix(end,14)+EmisMatrix(ind(k),2)))/quatileVal+1;
      tempVal=  str2double(new_data{tableIndex,2})+(exp(logpseq)/exp(logpseq1)-(alpha^alphaIndex))*100 ;
        new_data{tableIndex,2}= num2str(tempVal);
        
        if (thresholdValue<(RelationMatrix(end,14)+EmisMatrix(ind(k),2)))
            noPercent=noPercent+(exp(logpseq)/exp(logpseq1)-alpha^alphaIndex)*100 ;
            new_data{tableIndex,1} = strcat(...
                '<html><span style="color: #FF0000; font-weight: bold;">', ...
                new_data{tableIndex,1}, ...
                '</span></html>');
            new_data{tableIndex,2} = strcat(...
                '<html><span style="color: #FF0000; font-weight: bold;">', ...
                new_data{tableIndex,2}, ...
                '</span></html>');
        else
            yesPercent=yesPercent+(exp(logpseq)/exp(logpseq1)-alpha^alphaIndex)*100 ;
        end
        k1=k1+1;
        
    end
    
    set(handles.uitable, 'data',new_data);
    
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

% Hint: popupmenu controls usually have a white background on Windowshist([9 2][3 100]);.
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


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11


% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu12.
function popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu12


% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


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
% global S
% l1= length(S.DatabaseTable.LocationVec);
% allcountries=[];
% for i=1:l1
% allcountries {i}=  S.DatabaseTable.LocationVec(1,i);
% end


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
%     set(hObject,'String', allcountries);
end
