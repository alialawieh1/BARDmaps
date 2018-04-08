function [NewData,ZeroBact,ZeroAbt]= Preprocess (OriginalxlsFile,AbtNames,BactNames)

ZeroAbt=[1];
ZeroBact=[1];
%get the original datatable (in our example it is the newdateformat.xlsx)
[ndata, text, NewData] = xlsread(OriginalxlsFile);

[RowsNum ColNum]=size(NewData);

[truefalse1, index] = ismember(NewData(2,11), AbtNames);
NewData(2,11)=num2cell(index);
[truefalse1, index] = ismember(NewData(2,8),BactNames);
NewData(2,8)=num2cell(index);
%transform the bacteria and antibiotic names into numbers
for i=3:RowsNum
    [truefalse1, index] = ismember(NewData(i,11),AbtNames );
    NewData(i,11)= num2cell(index);
    if (index==0)
    ZeroAbt=[ZeroAbt i];
end
    [truefalse1, index] = ismember(NewData(i,8),BactNames );
    NewData(i,8)=num2cell(index);
   if (index==0)
    ZeroBact=[ZeroBact i];
end 
end

  
end
%now data is ready to be worked on.