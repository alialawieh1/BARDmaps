function [R1]= SelectFromR (mat_Table,select_vector_a, select_vector_b,select_vector_site,select_vector_country,k)
%this function give us from the table the rows having the specified
%characteristics of bacteria and antibiotics
%Ref|Location|StartMonth|StartYear|EndMonth|EndYear|Site|Bacteria|Nisolates|Antibiotic|R%|NResistant


R1=[];%R1 represents the result rows corresponding to the required antibiotics and bacteria.
C=length(select_vector_country);
M=length(select_vector_a);
N=length(select_vector_b);
L=length(select_vector_site);
CIndices=[];
VecC=cell2mat(mat_Table(k:end,2));%convert the cell values of country to a numerical value
for c1=1:C
indC=find((VecC==select_vector_country(c1)));%get the index of the equivalent rows
CIndices=[CIndices;indC];

end


DraftTable=mat_Table(CIndices,:);
AIndices=[];
VecA=cell2mat(DraftTable(:,10));%convert the cell values of antibiotics to a numerical value
for k1=1:M
indA=find((VecA==select_vector_a(k1)));%get the index of the equivalent rows
AIndices=[AIndices;indA];

end

DraftTable3=DraftTable(AIndices,:);
VecB=cell2mat(DraftTable3(:,8));
BIndices=[];
for m=1:N
indB=find (VecB==select_vector_b(m));
BIndices=[BIndices;indB];
end

Draft2Table=DraftTable3(BIndices,:);
VecS=cell2mat(Draft2Table(:,7));

for l1=1:L
indS=find (VecS==select_vector_site(l1));
R1=[R1;Draft2Table(indS,:)];
end



end