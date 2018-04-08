function [Done]= GenGraphvizLumpNew1 (RelationMatrix,RelationRefs, outStep,selectedAb,selectedBact,dottyPath,filePath)

%May 26, 2013


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


VarianceDif1=[];
VarianceDif2=[];
VarianceDif3=[];
VarianceDif4=[];
VarianceDif5=[];
% these vectors will be filled respectively with the 1rst,2nd,3rd,4th, and 5th differences
%the difference resistances at the edges in order to detect which nodes are
%expected to be subjected to human??? intervention

edge1=[];
edge2=[];
edge3=[];
edge4=[];
edge5=[];
colorNodeRed=[];
colorNodeGreen=[];
[N N2]=size(RelationMatrix);
resistanceEdge1=[];
for i=1:N
    DifCol= RelationMatrix(i,6)- RelationMatrix(i,1);
    if (outStep(DifCol)==0)
        continue;
    end
    switch DifCol
        case 1
            edge1=[edge1 RelationMatrix(i,8)];
            VarianceDif1=[VarianceDif1 i];
            resistanceEdge1=[resistanceEdge1 RelationMatrix(i,11)];
        case 2
            edge2=[edge2 RelationMatrix(i,8)];
            VarianceDif2=[VarianceDif2 i];
            
        case 3
            
            edge3=[edge3 RelationMatrix(i,8)];
            VarianceDif3=[VarianceDif3 i];
            
        case 4
            edge4=[edge4 RelationMatrix(i,8)];
            VarianceDif4=[VarianceDif4 i];
        case 5
            edge5=[edge5 RelationMatrix(i,8)];
            VarianceDif5=[VarianceDif5 i];
    end
end
resistanceEdge1=[resistanceEdge1 RelationMatrix(N,14)];%get the resistances of each node corresponding to one step difference.

if (outStep(1)==1)
    
    resistanceRmvMax=sort(resistanceEdge1);
    meanR=mean(resistanceRmvMax(1:6));
    edgeRmvMax=sort(abs(edge1));
    stdDiff=std(resistanceRmvMax(1:6));
    
    for k=2:length(resistanceEdge1)
        if ((resistanceEdge1(k)> resistanceEdge1(k-1)) && (edge1(k-1)>8))
            colorNodeRed=[colorNodeRed VarianceDif1(k-1)];
        elseif ((resistanceEdge1(k)< resistanceEdge1(k-1)) && (edge1(k-1)<-8))
            colorNodeGreen=[colorNodeGreen VarianceDif1(k-1)];
        end
        
    end
    
end


%for the dotty application to get rid of the circle on the edge go to the
%file dotty.lefty in the folder Graphviz2.30\lib\lefty\ and

%Edit the file dotty.lefty and change the line that says: 'edgehandles' = 1; to 'edgehandles' = 0; it's around line 110.

%I got this information from the website: http://www.graphviz.org/content/FaqNoEdgeHandles

fileName = [filePath ,'\output.txt'];

fid = fopen(fileName,'w','a','UTF-8');
fprintf(fid, '%s', ' ');
fclose(fid);
tempNodes=[0 0];
tempc1=1;
Val=[];
ValLen=1;
[N M]=size(RelationMatrix);


fid = fopen(fileName,'a+','a','UTF-8');
fprintf(fid, '%s\n', 'digraph G { ');
fprintf(fid, '%s\n', 'subgraph cluster_0 {');

s1L=length(selectedAb);
s2L=length(selectedBact);
fprintf(fid, '%s','label = "Antibitotic: ');

for j1=1:s1L
    
    fprintf(fid, '%s%s',selectedAb{j1},' ');
    if (mod(j1,3) ==0)
        fprintf(fid, '%s','\n ');
    end
end

fprintf(fid, '%s',' \n Bacteria: ');
for j2=1:s2L
    
    fprintf(fid, '%s%s',selectedBact{j2},' ');
    if (mod(j2,3) ==0)
        fprintf(fid, '%s','\n');
    end
end
fprintf(fid, '%s','";');


fprintf(fid, '%s\n', 'style=filled;');
fprintf(fid, '%s\n', 'color=lightgrey;');
fprintf(fid, '%s\n', 'node [style=filled,color=white];');


% declare the labels for each number

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
            
            fprintf(fid, '%d%s\n',(tempc1-1),'[label="",style=invis];edge[style=invis];');
            
            
            ind= find(colorNodeRed==index1(k));
            if (~isempty(ind))
                fprintf(fid, '%s', '"');
                fprintf(fid, '%g', RelationMatrix(index1(k),12));
                fprintf(fid, '%s', '/');
                fprintf(fid, '%g', RelationMatrix(index1(k),13));
                fprintf(fid, '%s', ' to ');
                fprintf(fid, '%g', RelationMatrix(index1(k),19));
                fprintf(fid, '%s', '/');
                fprintf(fid, '%g', RelationMatrix(index1(k),20));
                fprintf(fid, '%s', ' ;  N: ');
                fprintf(fid, '%g', RelationMatrix(index1(k),21));
                fprintf(fid, '%s', ' ;  R: ');
                fprintf(fid, '%2.2g', RelationMatrix(index1(k),14));
                
                fprintf(fid, '%s\n', '%" [color=red];');
                
            end
            
            
            
            ind= find(colorNodeGreen==index1(k));
            if (~isempty(ind))
                fprintf(fid, '%s', '"');
                fprintf(fid, '%g', RelationMatrix(index1(k),12));
                fprintf(fid, '%s', '/');
                fprintf(fid, '%g', RelationMatrix(index1(k),13));
                fprintf(fid, '%s', ' to ');
                fprintf(fid, '%g', RelationMatrix(index1(k),19));
                fprintf(fid, '%s', '/');
                fprintf(fid, '%g', RelationMatrix(index1(k),20));
                fprintf(fid, '%s', ' ;  N: ');
                fprintf(fid, '%g', RelationMatrix(index1(k),21));
                fprintf(fid, '%s', ' ;  R: ');
                fprintf(fid, '%2.2g', RelationMatrix(index1(k),14));
                
                fprintf(fid, '%s\n', '%" [color=green];');
                
            end
            
            
            fprintf(fid, '%d%s',(tempc1-1),'->');
            fprintf(fid, '%s', '"');
            fprintf(fid, '%g', RelationMatrix(index1(k),12));
            fprintf(fid, '%s', '/');
            fprintf(fid, '%g', RelationMatrix(index1(k),13));
            fprintf(fid, '%s', ' to ');
            fprintf(fid, '%g', RelationMatrix(index1(k),19));
            fprintf(fid, '%s', '/');
            fprintf(fid, '%g', RelationMatrix(index1(k),20));
            fprintf(fid, '%s', ' ;  N: ');
            fprintf(fid, '%g', RelationMatrix(index1(k),21));
            fprintf(fid, '%s', ' ;  R: ');
            fprintf(fid, '%2.2g', RelationMatrix(index1(k),14));
            
            
            fprintf(fid, '%s\n', '%";');
            
            
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
            
            fprintf(fid, '%d%s\n',(tempc1-1),'[label="",style=invis];edge[style=invis];');
            
            
            fprintf(fid, '%d%s',(tempc1-1),'->');
            
            AllNodes(j,:)=temp1;
            fprintf(fid, '%s', '"');
            fprintf(fid, '%g', RelationMatrix(index1(k),9));
            fprintf(fid, '%s', '/');
            fprintf(fid, '%g', RelationMatrix(index1(k),10));
            fprintf(fid, '%s', ' to ');
            fprintf(fid, '%g', RelationMatrix(index1(k),15));
            fprintf(fid, '%s', '/');
            fprintf(fid, '%g', RelationMatrix(index1(k),16));
            fprintf(fid, '%s', ' ;  N: ');
            fprintf(fid, '%g', RelationMatrix(index1(k),17));
            fprintf(fid, '%s', ' ;  R: ');
            fprintf(fid, '%2.2g', RelationMatrix(index1(k),11));
            
            
            fprintf(fid, '%s\n', '%";');
            fprintf(fid, '%s%d','{rank=same;',tempc1 );%"Start R: 0%"  1 }');
            fprintf(fid, '%s', '  "');
            fprintf(fid, '%g', RelationMatrix(index1(k),9));
            fprintf(fid, '%s', '/');
            fprintf(fid, '%g', RelationMatrix(index1(k),10));
            fprintf(fid, '%s', ' to ');
            fprintf(fid, '%g', RelationMatrix(index1(k),15));
            fprintf(fid, '%s', '/');
            fprintf(fid, '%g', RelationMatrix(index1(k),16));
            fprintf(fid, '%s', ' ;  N: ');
            fprintf(fid, '%g', RelationMatrix(index1(k),17));
            fprintf(fid, '%s', ' ;  R: ');
            fprintf(fid, '%2.2g', RelationMatrix(index1(k),11));
            
            fprintf(fid, '%s\n', '%"}');
            
            
            
            
            
            j=j+1;
            ValLen=ValLen+1;
        end
    end
end

fclose(fid);

fid = fopen(fileName,'a+','a','UTF-8');

tempNodes=sortrows(tempNodes,1);
[h1 h2]=size(tempNodes);

fprintf(fid, '%d%s\n',h1+1,'[label="",style=invis];edge[style=invis];');

for hh1=1:h1
    
    fprintf(fid, '%d%s',tempNodes(hh1,2), ' ->');
    
end

fprintf(fid, '%d',h1+1);

fprintf(fid, '%s\n',' edge[style=invis];');

for i=1:N
    DifCol= RelationMatrix(i,6)- RelationMatrix(i,1);
    if (outStep(DifCol)==0)
        continue;
    end
    switch DifCol
        case 1
            fprintf(fid, '%s', ' edge[color=maroon, style=solid]');
        case 2
            fprintf(fid, '%s', ' edge[color=yellow, style=solid]');
            
        case 3
            
            fprintf(fid, '%s', ' edge[color=blue, style=solid]');
            
            
        case 4
            fprintf(fid, '%s', ' edge[color=green, style=solid]');
            
        case 5
            fprintf(fid, '%s', ' edge[color=magenta, style=solid]');
            
    end
    
    
    ind= find(colorNodeRed==i);
    if (~isempty(ind))
        
        fprintf(fid, '%s', '"');
        fprintf(fid, '%g', RelationMatrix(i,12));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', RelationMatrix(i,13));
        fprintf(fid, '%s', ' to ');
        fprintf(fid, '%g', RelationMatrix(i,19));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', RelationMatrix(i,20));
        fprintf(fid, '%s', ' ;  N: ');
        fprintf(fid, '%g', RelationMatrix(i,21));
        fprintf(fid, '%s', ' ;  R: ');
        fprintf(fid, '%2.2g', RelationMatrix(i,14));
        
        fprintf(fid, '%s\n', '%" [color=red];');
        
    end
    
    ind= find(colorNodeGreen==i);
    if (~isempty(ind))
        
        fprintf(fid, '%s', '"');
        fprintf(fid, '%g', RelationMatrix(i,12));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', RelationMatrix(i,13));
        fprintf(fid, '%s', ' to ');
        fprintf(fid, '%g', RelationMatrix(i,19));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', RelationMatrix(i,20));
        fprintf(fid, '%s', ' ;  N: ');
        fprintf(fid, '%g', RelationMatrix(i,21));
        fprintf(fid, '%s', ' ;  R: ');
        fprintf(fid, '%2.2g', RelationMatrix(i,14));
        
        fprintf(fid, '%s\n', '%" [color=green];');
        
    end
    
    fprintf(fid, '%s', '"');
    fprintf(fid, '%g', RelationMatrix(i,9));
    fprintf(fid, '%s', '/');
    fprintf(fid, '%g', RelationMatrix(i,10));
    fprintf(fid, '%s', ' to ');
    fprintf(fid, '%g', RelationMatrix(i,15));
    fprintf(fid, '%s', '/');
    fprintf(fid, '%g', RelationMatrix(i,16));
    fprintf(fid, '%s', ' ;  N: ');
    fprintf(fid, '%g', RelationMatrix(i,17));
    fprintf(fid, '%s', ' ;  R: ');
    fprintf(fid, '%2.2g', RelationMatrix(i,11));
    
    
    StartNode(c1,:)=[RelationMatrix(i,9:11) RelationMatrix(i,15:17)];
    StartNum(c1)=RelationMatrix(i,1);
    StartRefs(c1).R1=RelationRefs(i).R1;
    
    
    
    c1=c1+1;
    fprintf(fid, '%s', '%" -> "');
    fprintf(fid, '%g', RelationMatrix(i,12));
    fprintf(fid, '%s', '/');
    fprintf(fid, '%g', RelationMatrix(i,13));
    fprintf(fid, '%s', ' to ');
    fprintf(fid, '%g', RelationMatrix(i,19));
    fprintf(fid, '%s', '/');
    fprintf(fid, '%g', RelationMatrix(i,20));
    fprintf(fid, '%s', ' ;  N: ');
    fprintf(fid, '%g', RelationMatrix(i,21));
    fprintf(fid, '%s', ' ;  R: ');
    
    fprintf(fid, '%2.2g', RelationMatrix(i,14));
    
    EndNode(c2,:)=[RelationMatrix(i,12:14) RelationMatrix(i,19:21)];
    EndRefs(c2).R2=RelationRefs(i).R2;
    
    
    c2=c2+1;
    fprintf(fid, '%s', '%" [label ="dM: ');
    fprintf(fid,'%g',RelationMatrix(i,7));
    fprintf(fid, '%s', ' dR: ');
    fprintf(fid,'%2.2g',RelationMatrix(i,8));
    
    fprintf(fid, '%s\n', '%"];');
    
    
end

Done=1;
fclose(fid);



fid = fopen(fileName,'a+','a','UTF-8');

%remove duplicates then see what is present in one not in another..


[StartNode, iSa,iC]=unique(StartNode,'rows');
[EndNode, iEn,iC]=unique(EndNode,'rows');
StartRefsNew=StartRefs(iSa);
EndRefsNew=EndRefs(iEn);

StartNum=StartNum(iSa);
[C,iS,iE] = intersect(StartNode,EndNode,'rows');

[s1 s2]=size(StartNode);
[e1 e2]=size(EndNode);
for tempc1=1:s1
    index= find(iS==tempc1);
    if (isempty(index))
        
        fprintf(fid, '%s', 'edge[color=black] "Start R: 0%" -> "');
        fprintf(fid, '%g', StartNode(tempc1,1));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', StartNode(tempc1,2));
        fprintf(fid, '%s', ' to ');
        fprintf(fid, '%g', StartNode(tempc1,4));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', StartNode(tempc1,5));
        fprintf(fid, '%s', ' ;  N: ');
        fprintf(fid, '%g', StartNode(tempc1,6));
        fprintf(fid, '%s', ' ;  R: ');
        fprintf(fid, '%2.2g', StartNode(tempc1,3));
        
        fprintf(fid, '%s\n', '%";');
        
        
    end
end

for tempc2=1:e1
    index= find (iE==tempc2);
    if (isempty(index))
        
        fprintf(fid, '%s', '  edge[color=black] "');
        fprintf(fid, '%g', EndNode(tempc2,1));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', EndNode(tempc2,2));
        fprintf(fid, '%s', ' to ');
        fprintf(fid, '%g', EndNode(tempc2,4));
        fprintf(fid, '%s', '/');
        fprintf(fid, '%g', EndNode(tempc2,5));
        fprintf(fid, '%s', ' ;  N: ');
        fprintf(fid, '%g', EndNode(tempc2,6));
        fprintf(fid, '%s', ' ;  R: ');
        fprintf(fid, '%2.2g', EndNode(tempc2,3));
        
        fprintf(fid, '%s\n', '%" -> "End" ;');
    end
end

fprintf(fid, '%s\n','{rank=same;"Start R: 0%"  1 }');
fprintf(fid, '%s%d%s\n','{rank=same;"End" ',  h1+1,' }');
fprintf(fid, '%s\n', '}');
fprintf(fid, '%s\n', '}');
fclose(fid);
combinedStr = [dottyPath ,'\dotty ', filePath ,'\output.txt'];
[status,out]=system(combinedStr);


end