function DistInfo ()

TableData=load('DatabaseTable.mat');

%get from the database all the possible empirical combinations between an
%antibiotic and a bacteria

%the column 8 contains the bacteria name and column 10 contains the
%antibiotic name, both in numeric representation

VecA=cell2mat(TableData.DatabaseTable.FinalData(:,10));
VecB=cell2mat(TableData.DatabaseTable.FinalData(:,8));
VecS=cell2mat(TableData.DatabaseTable.FinalData(:,7));
Vec_A_B=[VecA VecB VecS];
Vec_A_B=unique(Vec_A_B,'rows');

[Lia,indexSite]= ismember('Urine',TableData.DatabaseTable.SiteVec);

Vec_A_B(Vec_A_B(:,3)==indexSite,:) = [] ;%remove the urine site from the list


[M N]=size(Vec_A_B);
LenEdges=[];
A_B=[];
for i=1:M
    
    R1= SelectFromR (TableData.DatabaseTable.FinalData,Vec_A_B(i,1), Vec_A_B(i,2),Vec_A_B(i,3),1:length(TableData.DatabaseTable.LocationVec), 1);%indicate the vector of antibiotics and bacteria and the sites to study
    
    [RelationMatrix AfterSlots LumpedMatrix RelationRefs]= LumpMatrix (R1,1,1);
    [ro co]=size(RelationMatrix);
    if (ro==0)
        AllEdges(i).Edges=[];
        LenEdges=[LenEdges 0];
        A_B=[A_B;Vec_A_B(i,1)  Vec_A_B(i,2) Vec_A_B(i,3)];
        continue;
    end
    [edgeOrder]= TraversalLump (RelationMatrix,RelationRefs, [1 1 1 1 1],Vec_A_B(i,1), Vec_A_B(i,2));
    AllEdges(i).Edges(:,:)=edgeOrder(:,:);
    [s1 s2]=size(edgeOrder);
    LenEdges=[LenEdges s1];
    A_B=[A_B;Vec_A_B(i,1)  Vec_A_B(i,2) Vec_A_B(i,3)];
end

%after computing all possible edges try to find patterns among them

% 1- get the vectors having same length,
% 2- subtract the months from each other
% 3- subtract the values of the resistance difference from each other
% 4- calculate the maximum likelihood for both vectors (months, and
% resistance)
% 5- choose the one having the least value


LenVals=unique(LenEdges);
Len=length(LenVals);
for j=1:Len
    if (LenVals(j)>=4)
        ind=find(LenEdges==LenVals(j));
        
        if (isempty(ind))
            continue;
        elseif (length(ind)==1)
            continue;
        else
            L=length(ind);
            X=[];
            Str1={};
            LabelS={};
            str2=[];
            for k=1:(L-1)
                
                X=[X; [AllEdges(ind(k)).Edges(:,2)]'];
                
                str2=[str2 num2str(k) ': ' cell2mat(TableData.DatabaseTable.AbtName(A_B(ind(k),1))) '  ' cell2mat(TableData.DatabaseTable.BactName(A_B(ind(k),2))) 10];
                LabelS{k}=num2str(k) ;
                
            end
            Str1{1}=str2;
            [r1 c1]=size(X);
            if (r1>1)
                Y=pdist(X);
                Y1=squareform(Y);
                Z= linkage(Y);
                
                figure()
                
                dendrogram(Z,'labels',LabelS);
                legend(Str1)
            end
        end
    end
end

end