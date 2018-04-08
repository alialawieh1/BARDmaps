function [Name,Genus,Species,Group,Diarrhea,BactMatrix]= GetBactVectors (xls_fileName)
%this function returns the Bacteria Matrix (BatMatrix) that contains all
%the bacteria set in numeric format. the first column represents the
%bacteria name, the second its genus, the third its species, the fourth its
%group, and the fifth its diarrhea if any.
%we will use the ouptut of this function in order to rename the bacteria in
%the table by their number so that it would be easier to search them based
%on any of their criteria (see the function "SelectFromR.m")
%xls_fileName should be a string (eg. 'bacteriaList.xlsx') indicating the name of the excel file containing the bacteria list. should have the format of the file: bacteriaList.xlsx

[ndata, text, BacteriaList] = xlsread(xls_fileName);
BactMatrix=[];
[N M]=size(BacteriaList);
N=N-1;
Name=BacteriaList(2,1);%we started by the second row since in the excel file the first row contains the header indicating what each column represents
Genus=BacteriaList(2,2);
Species=BacteriaList(2,3);
Group=BacteriaList(2,4);
Diarrhea=BacteriaList(2,5);
% we will get the vectors of distinct values that a bacteria may take for
% name, genus, species, group and diarrhea. these vectors contains
% the distinct values that could be taken fot this class. based on their
% place in the vector the matrix is built on.
for i=1:N
[truefalse1, index1] = ismember(BacteriaList(i+1,1), Name);%i+1 since the first row is the header of the excel table.
if (truefalse1==0)% to detect non yet entered values in the vector
Name=[Name , BacteriaList(i+1,1)];
[truefalse1, index1] = ismember(BacteriaList(i+1,1), Name);
end
[truefalse2, index2] = ismember(BacteriaList(i+1,2), Genus);
if (truefalse2==0)
Genus=[Genus , BacteriaList(i+1,2)];
[truefalse2, index2] = ismember(BacteriaList(i+1,2), Genus);
end
[truefalse3, index3] = ismember(BacteriaList(i+1,3), Species);
if (truefalse3==0)
Species=[Species , BacteriaList(i+1,3)];
[truefalse3, index3] = ismember(BacteriaList(i+1,3), Species);
end
[truefalse4, index4] = ismember(BacteriaList(i+1,4), Group);
if (truefalse4==0)
Group=[Group, BacteriaList(i+1,4)];
[truefalse4, index4] = ismember(BacteriaList(i+1,4), Group);
end
[truefalse5, index5] = ismember(BacteriaList(i+1,5), Diarrhea);
if (truefalse5==0)
Diarrhea=[Diarrhea, BacteriaList(i+1,5)];
[truefalse5, index5] = ismember(BacteriaList(i+1,5), Diarrhea);
end
BactMatrix=[BactMatrix;index1 index2 index3 index4 index5];

end

end