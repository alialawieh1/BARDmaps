function [NewObs]= NewSeq (RelationMatrix,flagIntermediate)
%what we will do is to take the last number and try to find all rows having
%their start with this number
%then put these rows in a temp matrix and redo the operation until no more
%starting number is found


% Quantize the resistance percentages into 20 intervals from 0 to 100%(0,5,10,15,20,25,30,...,100)
intermediateVal=[];
if (flagIntermediate)
    intermediateVal=23;
end
[N M]=size(RelationMatrix);
j=1;
AllObs={};
PrefixMatrix=[];
c2=1;
for i=1:N
    
    temp=RelationMatrix(i,:);%the temp here is equal to the studied row
    
    searchNum = temp(1,6);%search for the number in the 6th column, it represents the ending month and year
    str1=num2str(RelationMatrix(i,[7:8 intermediateVal] ));
    
    if (~isempty(PrefixMatrix))
        row1= find(PrefixMatrix(:)==RelationMatrix(i,1));%search if there is previous observations that ends with the same month and year that this new row starts with
        if (~isempty(row1))
            L=length(row1);
            for k=1:L
                AllObs{j}=[AllObs{row1(k)},str1];
                PrefixMatrix(j)=searchNum;
                
                if (i==N)
                    NewObs{c2}= AllObs{j};
                    c2=c2+1;
                end
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
        str2=num2str(RelationMatrix(indicies(k),[7:8 intermediateVal]));
        
        
        str3={str1,str2};
        
        AllObs{j}=str3;
        PrefixMatrix(j)=RelationMatrix(indicies(k),6);
        j=j+1;
    end
end
end