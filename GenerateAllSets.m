function [AllObs, Emissions,EmisMatrix, flagIntermediate]= GenerateAllSets (RelationMatrix)

%Take the last number (6th column of the matrix RelationMatrix and try to find all rows having
%their start with this number
%then put these rows in a temp matrix and redo the operation until no more
%starting number is found

%1- build first the observations having two cells,
%2- then each time we have a new row check if we can expand on the already found observations

[N M]=size(RelationMatrix);
j=1;
AllObs={};
EmisMatrix=[];
PrefixMatrix=[];
valInter=[];
flagIntermediate=0;
% nbIntermediates= find(RelationMatrix(1:N,23)==0);
% if (length(nbIntermediates) > N/2)
%     flagIntermediate=0;
% else
%     flagIntermediate=1;
%     valInter=23;
% end

for i=1:N
    
    EmisMatrix(i,:)=RelationMatrix(i,[7:8 valInter]);
    str1=num2str(RelationMatrix(i,[7:8 valInter]));
    
    searchNum = RelationMatrix(i,6);%search for the number in the 6th column, it represents the ending month and year
    
    
    if (~isempty(PrefixMatrix))
        row1= find(PrefixMatrix(:)==RelationMatrix(i,1));%search if there is previous observations that ends with the same month and year that this new row starts with
        if (~isempty(row1))
            L=length(row1);
            for k=1:L
                AllObs{j}=[AllObs{row1(k)},str1];
                PrefixMatrix(j)=searchNum;
                j=j+1;
            end
        end
    end
    indicies=find (RelationMatrix(i:end,1)==searchNum);%to search for those having same number
    %representing the month and year in the rows next to the studied one
    
    indicies=indicies+i-1;%to get the index in the RelationMatrix
    
    if (isempty(indicies))
        continue;%this means that no rows having the start equal to the end month and year of the studied row
    end
    
    L=length(indicies);
    for k=1:L
        
        str2=num2str(RelationMatrix(indicies(k),[7:8 valInter]));
        
        str3={str1,str2};
        AllObs{j}=str3;
        PrefixMatrix(j)=RelationMatrix(indicies(k),6);
        j=j+1;
    end
end

EmisMatrix=unique(EmisMatrix,'rows');
[r1 c1]=size(EmisMatrix);
for i=1:r1
    Emissions{i}=num2str(EmisMatrix(i,:));
end
end