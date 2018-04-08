function [LocationVec LocationMatrix]= GetLocationVectors (xls_fileName)
% refer to the GetBactVectors since this function applies the same concepts
[ndata, text, LocationList] = xlsread(xls_fileName);
LocationVec=[];
[N M]=size(LocationList);
N=N-1;
LocationMatrix=[];
LocationVec=LocationList(2,2);

for i=1:N
[truefalse1, index1] = ismember(LocationList(i+1,2), LocationVec);
if (truefalse1==0)
LocationVec=[LocationVec , LocationList(i+1,2)];
[truefalse1, index1] = ismember(LocationList(i+1,2), LocationVec);
end

LocationMatrix=[LocationMatrix;index1];

end
