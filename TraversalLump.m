function [edgeOrder]= TraversalLump (RelationMatrix,RelationRefs, outStep,selectedAb,selectedBact)

%May 26, 2013
% RelationMatrix(:,8)= num2fixpt(RelationMatrix(:,8),sfix(8),5,'Nearest');
% RelationMatrix(:,11)=num2fixpt(RelationMatrix(:,11),sfix(8),5,'Nearest');
% RelationMatrix(:,14)=num2fixpt(RelationMatrix(:,14),sfix(8),5,'Nearest');

SparseVec1=[];
SparseSource=[];%represents the child of the spaceVec1
edgeVal=[];%represents the edge (dt and dp)

%define start node and end node matrices to define where to put start and
%end;
% we put the start before a node that doesnt show up in the end node matrix
% and we put the end after a node that doesnt show up in the start node
% matrix
%StartNode and EndNode Matrices contain: start month, end month, total N
%and total R

StartNode=[0 0 0 0 0 0];

EndNode=[0 0 0 0 0 0];

%what we will do is to take the last number and try to find all rows having
%their start with this number
%then put these rows in a temp matrix and redo the operation until no more
%starting number is found


c1=1;
c2=1;



tempNodes=[0 0];
tempc1=1;
Val=[];
ValLen=1;
[N M]=size(RelationMatrix);



Min1=min(RelationMatrix(:,1));
Max1=max(RelationMatrix(:,6));
AllNodes=[0 0 0 0 0 0 0];
j=1;
for i=Min1:Max1
    
    
    index1=find(RelationMatrix(:,1)==i);
    
    if (isempty(index1))
        index1= find(RelationMatrix(:,6)==i);
        L=length(index1);
        
        for k=1:L
            temp1=[RelationMatrix(index1(k),12:14) RelationMatrix(index1(k),19:22)];
            [truefalse1, newind]=ismember(temp1,AllNodes,'rows');
            
            if (max(truefalse1))
                continue;
            end
            
            AllNodes(j,:)=temp1;
            fdk= find(tempNodes(:,1)==RelationMatrix(index1(k),13));
            
            if (isempty(fdk))
                tempNodes(tempc1,1)=RelationMatrix(index1(k),13);
                tempNodes(tempc1,2)=tempc1;
                tempc1=tempc1+1;
            end
            
            j=j+1;
            ValLen=ValLen+1;
        end
    else
        L=length(index1);
        for k=1:L
            temp1=[RelationMatrix(index1(k),9:11) RelationMatrix(index1(k),15:18)];
            [truefalse1, newind]=ismember(temp1,AllNodes,'rows');
            if (max(truefalse1))
                continue;
            end
            fdk= find(tempNodes(:,1)==RelationMatrix(index1(k),10));
            if (isempty(fdk))
                tempNodes(tempc1,1)=RelationMatrix(index1(k),10);
                tempNodes(tempc1,2)=tempc1;
                tempc1=tempc1+1;
            end
            
            AllNodes(j,:)=temp1;
            
            
            j=j+1;
            ValLen=ValLen+1;
        end
    end
end

tempNodes=sortrows(tempNodes,1);
[h1 h2]=size(tempNodes);


for i=1:N
    DifCol= RelationMatrix(i,6)- RelationMatrix(i,1);
    if (outStep(DifCol)==0)
        continue;
    end
    
    StartNode(c1,:)=[RelationMatrix(i,9:11) RelationMatrix(i,15:17)];
    StartNum(c1)=RelationMatrix(i,1);
    StartResistance(c1)=RelationMatrix(i,8);
    StartRefs(c1).R1=RelationRefs(i).R1;
    
    SparseVec1=[SparseVec1 (RelationMatrix(i,1)+1)];
    
    c1=c1+1;

    EndNode(c2,:)=[RelationMatrix(i,12:14) RelationMatrix(i,19:21)];
    EndRefs(c2).R2=RelationRefs(i).R2;
    
    
    SparseSource=[SparseSource (RelationMatrix(i,6)+1)];
    edgeVal=[edgeVal;RelationMatrix(i,7:8)];
    c2=c2+1;
    
    
end

Done=1;

%remove duplicates then see what is present in one not in another..

%[C,ia,ic] = unique(A)

[StartNode, iSa,iC]=unique(StartNode,'rows');
[EndNode, iEn,iC]=unique(EndNode,'rows');
StartRefsNew=StartRefs(iSa);
EndRefsNew=EndRefs(iEn);

StartNum=StartNum(iSa);
StartResistance=StartResistance(iSa);
[C,iS,iE] = intersect(StartNode,EndNode,'rows');

[s1 s2]=size(StartNode);
[e1 e2]=size(EndNode);
for tempc1=1:s1
    index= find(iS==tempc1);
    if (isempty(index))
        
        
        SparseVec1=[SparseVec1 1];
        SparseSource=[SparseSource (StartNum(tempc1)+1)];
        edgeVal=[edgeVal;[0 StartResistance(tempc1)]];
        
    end
end
graphMatrix=[SparseVec1' SparseSource' edgeVal];

DG = sparse(SparseVec1,SparseSource,true,max(SparseSource),max(SparseSource));
%h = view(biograph(DG))
order = graphtraverse(DG,1);
edgeOrder=[];
ln=length(order);
for i=2:ln
    for j=i:-1:1
        if (DG(order(j),order(i))==1)
            ind1=find (graphMatrix(:,1)==order(j));
            ind2= find(graphMatrix(:,2)==order(i));
            newind=intersect(ind1,ind2);
            edgeOrder=[edgeOrder;graphMatrix(newind,3:4)];
        end
    end
end

end