function [AfterSlots SlotedTable SStartYears SStopYears SNIsolates SRefs]= SlotTable (R1)
%decide what to lump
%divide the records having duration more that one year over slots

sortedTable= sortrows(R1,[4 3 6 5]);

[N M]= size (sortedTable);
tempCol(:,1)=cell2mat(sortedTable(:,3));
indices=find(tempCol(:,1)==7);
tempCol(:,1)=cell2mat(sortedTable(:,5));
indices2=find(tempCol(:,1)==7);
if (~isempty(indices))
    sortedTable(indices,3)={1};
end
if (~isempty(indices2))
    sortedTable(indices2,5)={1};
    newVal=cell2mat(sortedTable(indices2,6))+1;
    [r1 c1]=size(newVal);
    for k1=1:r1
    sortedTable(indices2(k1),6)={newVal(k1)};
    end
end


StartYears(:,1)=cell2mat(sortedTable(:,3));%the starting month
StartYears(:,2)=cell2mat(sortedTable(:,4));%the starting year
StopYears(:,1)=cell2mat(sortedTable(:,5));%end month
StopYears(:,2)=cell2mat(sortedTable(:,6));%end year
NIsolates = cell2mat(sortedTable(:,9));%total isolates
Refs=cell2mat(sortedTable(:,1));%reference paper


j=1;

 for i=1:N
 DifferenceMonth=ceil(12*(cell2mat(sortedTable(i,6))-cell2mat(sortedTable(i,4)))+(cell2mat(sortedTable(i,5))-cell2mat(sortedTable(i,3))));


%if difference more than 12 created rows equal to the quotient, and with
%resistance samples equal to the total divided by the quotient

%Ref|Location|StartMonth|StartYear|EndMonth|EndYear|Site|Bacteria|Nisolates|Antibiotic|R%|NResistant|I%|NIintermediate
% 1 |   2    |      3   |   4     |     5  |    6  | 7  |   8    |    9    |    10    |11|    12    |13|14

    ntimes=floor(DifferenceMonth/12);
    
    for m=1:ntimes
    SStartYears(j,1)=StartYears(i,1);%month
    SStartYears(j,2)=StartYears(i,2)+(m-1);%year
    SStopYears(j,1)=StopYears(i,1);%month
    SStopYears(j,2)=StartYears(i,2)+m;%year
    
    SlotedTable(j,1)=Refs(i);
    SlotedTable(j,2)=cell2mat(sortedTable(i,2));
    SlotedTable(j,3)=6*(SStartYears(j,2)+SStopYears(j,2));
    SlotedTable(j,4)=SlotedTable(j,3);
    SlotedTable(j,5)=SlotedTable(j,3);
    SlotedTable(j,6)=SlotedTable(j,3);
    SlotedTable(j,7)=cell2mat(sortedTable(i,7));
    SlotedTable(j,8)=cell2mat(sortedTable(i,8));
    SlotedTable(j,9)=floor(NIsolates(i)/ntimes);
    SlotedTable(j,10)=cell2mat(sortedTable(i,10));
    SlotedTable(j,11)=cell2mat(sortedTable(i,11));
    SlotedTable(j,12)=cell2mat(sortedTable(i,12))/ntimes;
    SlotedTable(j,13)=cell2mat(sortedTable(i,13));
    SlotedTable(j,14)=cell2mat(sortedTable(i,14))/ntimes;
    
    SNIsolates(j) = floor(NIsolates(i)/ntimes) ;%total isolates or total resistances?
   
    SRefs(j)=Refs(i);


    j=j+1;
    end

 end
 
 
 
 AfterSlots(:,1:12)= SlotedTable(:,1:12);
 AfterSlots(:,13:14)=SStartYears;
 AfterSlots(:,15:16)=SStopYears ;
 AfterSlots(:,17)=SRefs ;
 AfterSlots(:,18)=SNIsolates;
 AfterSlots(:,19:20)=SlotedTable(:,13:14);%added for the intermediate
 AfterSlots=sortrows(AfterSlots,[3 1]);
 
 SlotedTable=AfterSlots(:,[1:12 19:20]);
 SStartYears=AfterSlots(:,13:14);
 SStopYears =AfterSlots(:,15:16);
 SRefs =AfterSlots(:,17);
 SNIsolates=AfterSlots(:,16);

 
 
end