function [DatabaseTable]= TableData (OriginalxlsFile,AbtNames,BactNames)
%this file generates the table that we will use for the structural and HMM
%models

%in our case 
% OriginalxlsFile is 'SampleInitialData.xlsx'
% AbtNames is 'antimicrobialList.xlsx'
% BactNames is 'bacteriaList.xlsx'


% 
% In order to optimize the execution of the code in MATLAB, for each column containing string values we associate numerical values that maps to the strings such that similar strings have similar numerical equivalent value, and different strings have different numerical equivalent values. This would fasten the comparison since string comparison is slower than numerical comparison.
% On the other hand, we built up two matrices representing respectively the antimicrobial and bacteria features, all in numerical values.
% The bacteria features are the bacteria name, the genus, the species, the group, and the preset category.
% The antimicrobial features are the antimicrobial name, the group, the subgroup, the variant, and the preset category.
% The user can select to study the AMR data based on a set of antimicrobial and bacteria features. The methods map the selected set of features using a filter on the matrices to extract the matching records.

[BactName,BactGenus,BactSpecies,BactGroup,BactDiarrhea,BactMatrix]= GetBactVectors (BactNames);
[AbtName,AbtGroup,AbtSubGroup,AbtVariant,AbtMatrix]= GetAbtVectors (AbtNames);
[NewData,zerob,zeroa]= Preprocess (OriginalxlsFile,AbtName,BactName);
[LocationVec LocationMatrix]= GetLocationVectors (OriginalxlsFile);%country from which samples were taken
[SiteVec SiteMatrix]= GetSiteVectors (OriginalxlsFile);%site of the body from which samples were taken; usually urine vs non-urine..
FinalData(:,1)=NewData(2:end,1);
FinalData(:,2)=num2cell(LocationMatrix(:,1));
FinalData(:,3)=NewData(2:end,3);
FinalData(:,4)=NewData(2:end,4);
FinalData(:,5)=NewData(2:end,5);
FinalData(:,6)=NewData(2:end,6);
FinalData(:,7)=num2cell(SiteMatrix(:,1));
FinalData(:,8)=NewData(2:end,8);
FinalData(:,9)=NewData(2:end,9);
FinalData(:,10)=NewData(2:end,11);
FinalData(:,11)=NewData(2:end,12);
FinalData(:,12)=NewData(2:end,13);
% FinalData(:,13)=NewData(2:end,14);
% FinalData(:,14)=NewData(2:end,15);

DatabaseTable.FinalData=FinalData;
DatabaseTable.LocationVec=LocationVec;
DatabaseTable.SiteVec=SiteVec;
DatabaseTable.AbtName=AbtName;
DatabaseTable.AbtGroup=AbtGroup;
DatabaseTable.AbtSubGroup=AbtSubGroup;
DatabaseTable.AbtVariant=AbtVariant;
DatabaseTable.AbtMatrix=AbtMatrix;
DatabaseTable.BactName=BactName;
DatabaseTable.BactGenus=BactGenus;
DatabaseTable.BactSpecies=BactSpecies;
DatabaseTable.BactGroup=BactGroup;
DatabaseTable.BactDiarrhea=BactDiarrhea;
DatabaseTable.BactMatrix=BactMatrix;
end
