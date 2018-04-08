function [Name,Group,SubGroup,Variant,AbtMatrix]= GetAbtVectors (xls_fileName)
% refer to the GetBactVectors since this function applies the same concepts
[ndata, text, AntibioList] = xlsread(xls_fileName);
AbtMatrix=[];
[N M]=size(AntibioList);
N=N-1;
Name=AntibioList(2,1);
Group=AntibioList(2,2);
SubGroup=AntibioList(2,3);
Variant=AntibioList(2,4);

for i=1:N
[truefalse1, index1] = ismember(AntibioList(i+1,1), Name);
if (truefalse1==0)
Name=[Name , AntibioList(i+1,1)];
[truefalse1, index1] = ismember(AntibioList(i+1,1), Name);
end
[truefalse2, index2] = ismember(AntibioList(i+1,2), Group);
if (truefalse2==0)
Group=[Group , AntibioList(i+1,2)];
[truefalse2, index2] = ismember(AntibioList(i+1,2), Group);
end
[truefalse3, index3] = ismember(AntibioList(i+1,3), SubGroup);
if (truefalse3==0)
SubGroup=[SubGroup , AntibioList(i+1,3)];
[truefalse3, index3] = ismember(AntibioList(i+1,3), SubGroup);
end
[truefalse4, index4] = ismember(AntibioList(i+1,4), Variant);
if (truefalse4==0)
Variant=[Variant, AntibioList(i+1,4)];
[truefalse4, index4] = ismember(AntibioList(i+1,4), Variant);
end
AbtMatrix=[AbtMatrix;index1 index2 index3 index4];


end

end