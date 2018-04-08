function [RelationMatrix AfterSlots LumpedMatrix RelationRefs]= LumpMatrix (R1,RefLump,SiteLump)
%RefLump is either 0 or 1 indicating if we want to lump the references of
%the same Antimicrobial resistance. a one indicates that we want to lump
%the references.
%SiteLump: same as RefLump but for the site from where the samples were
%taken. if one it indicates that we want to lump the sites.
% R1 is the output of the function SelectFromR.


%Divide the records having duration more that one year over slots

%SlotedTable=
%Ref|Location|AvgMonth|AvgMonth|AvgMonth|AvgMonth|Site|Bacteria|Nisolates|Antibiotic|R%|NResistant|I%|NIintermediate

RelationRefs=[];
LumpedMatrix=[];

[AfterSlots SlotedTable SStartYears SStopYears SNIsolates SRefs]= SlotTable (R1);
count1=1;
[N M]= size(AfterSlots);
i=1;
while(i<=N)
    index1= find (AfterSlots((i):end,3)==AfterSlots(i,3));
    
    if (length(index1)==1)
        LumpedMatrix(count1,:)=AfterSlots(i,:);
        LumpedNodes(count1).Refs(1)=AfterSlots(i,1);
        count1=count1+1;
        i=i+1;
        continue;
    end
    
    index1=index1+i-1;
    
    if (RefLump==1)
        fnd1=1:N;%if lumping references is allowed no restriction on what rows to process is required
    else
        fnd1= find(AfterSlots(:,1)==AfterSlots(i,1));%if lumping of references is not allowed, we can only merge the rows havinf the same references
    end
    
    if (SiteLump==1)
        fnd2=1:N;
    else
        fnd2= find(AfterSlots(:,7)==AfterSlots(i,7));
    end
    
    
    %get the rows that can be lumped together
    tempIndex=intersect(fnd1,fnd2);
    
    
    [tempInd1, Locb]= ismember(index1,tempIndex);
    
    if (max(Locb)==0)
        LumpedMatrix(count1,:)=AfterSlots(i,:);
        LumpedNodes(count1).Refs(1)=AfterSlots(i,1);
        count1=count1+1;
        i=i+1;
        continue;
    end
    
    [L L1] =size(index1);
    firstFlag=0;
    sndFlag=0;
    count2=1;
    for j=1:L
        
        if (Locb(j)~=0)
            if (firstFlag==0)
                LumpedMatrix(count1,:)=AfterSlots(tempIndex(Locb(j)),:);
                
                firstFlag=1;
                LumpedNodes(count1).Refs(count2)=AfterSlots(tempIndex(Locb(j)),1);
                count2=count2+1;
                i=tempIndex(Locb(j))+1;
            else
                LumpedMatrix(count1,9)=LumpedMatrix(count1,9)+AfterSlots(tempIndex(Locb(j)),9);
                
                LumpedMatrix(count1,12)=LumpedMatrix(count1,12)+AfterSlots(tempIndex(Locb(j)),12);
                LumpedMatrix(count1,20)=LumpedMatrix(count1,20)+AfterSlots(tempIndex(Locb(j)),20);
                LumpedMatrix(count1,11)=LumpedMatrix(count1,12)/LumpedMatrix(count1,9);
                LumpedMatrix(count1,19)=LumpedMatrix(count1,20)/LumpedMatrix(count1,9);
                LumpedNodes(count1).Refs(count2)=AfterSlots(tempIndex(Locb(j)),1);
                
                count2=count2+1;
                i=tempIndex(Locb(j))+1;
            end
            
            
            
        end
        
    end
    
    count1=count1+1;
end


RelationMatrix=[];
Ycount=1;
RNum=1;
[M N]= size(LumpedMatrix);
if (M>0)
    
    NewMatrix(:,1)=LumpedMatrix(:,3);    %time average
    NewMatrix(:,2)=LumpedMatrix(:,9);    %total bacteria number
    NewMatrix(:,3)=LumpedMatrix(:,11);   %resistance percentage
    NewMatrix(:,4)=LumpedMatrix(:,12);   %resistance samples
    NewMatrix(:,5)=LumpedMatrix(:,19);   %intermediate percentage
    NewMatrix(:,6)=LumpedMatrix(:,20);   %intermediate samples
    
    GetNum= unique(NewMatrix(:,1));
    
    t1=0;
    t2=0;
    t3=0;
    t4=0;
    t5=0;
    [ro co]=size(NewMatrix);
    if (ro<2)
        RelationMatrix=[];
    else
        for i=1:M
            Diff1=bsxfun(@minus,NewMatrix(:,:),NewMatrix(i,:));
            
            
            [m1 n1]=size(Diff1);
            VectD1=[];
            
            flag1=0;
            flag2=0;
            flag3=0;
            flag4=0;
            flag5=0;
            temp=0;
            j=i+1;
            t1=NewMatrix(i,1);
            
            diff1Ind=[];
            stateNum=find(GetNum==NewMatrix(i,1));
            while(j<=m1)
                if ((Diff1(j,1)>temp))
                    if (flag1==0)
                        %see if there are other rows having same time difference
                        
                        t2=NewMatrix(j,1);
                        indices=find((Diff1(:,1)==Diff1(j,1)));
                        diff1Ind=indices;
                        for k=1:length(indices)
                            %for first order difference dt=t2-t1 and dp=p2-p1
                            %here we have them directly by the function we used
                            %(bsxfun)
                            VectD1=[VectD1;Diff1(indices(k),:)];
                            j=indices(k)+1;
                            RelationMatrix(RNum,1)=stateNum;%represents the row having t1
                            RelationMatrix(RNum,2)=stateNum+1;%represents the row having t2
                            RelationMatrix(RNum,3)=stateNum+1;
                            RelationMatrix(RNum,4)=stateNum+1;
                            RelationMatrix(RNum,5)=stateNum+1;
                            RelationMatrix(RNum,6)=stateNum+1;
                            RelationMatrix(RNum,7)=Diff1(indices(k),1);
                            RelationMatrix(RNum,8)=Diff1(indices(k),3);
                            
                            RelationMatrix(RNum,9)=LumpedMatrix(i,13);
                            RelationMatrix(RNum,10)=LumpedMatrix(i,14);
                            RelationMatrix(RNum,11)= NewMatrix(i,3);%resistance percentage
                            RelationMatrix(RNum,12)=LumpedMatrix(indices(k),13);
                            RelationMatrix(RNum,13)=LumpedMatrix(indices(k),14);
                            RelationMatrix(RNum,14)=NewMatrix(indices(k),3);%resistance percentage
                            RelationMatrix(RNum,15)=LumpedMatrix(i,15);
                            RelationMatrix(RNum,16)=LumpedMatrix(i,16);
                            RelationMatrix(RNum,17)=SNIsolates(i);
                            RelationRefs(RNum).R1=LumpedNodes(i).Refs;
                            RelationMatrix(RNum,18)=1;%LumpedNodes(i).Refs(1);
                            RelationMatrix(RNum,19)=LumpedMatrix(indices(k),15);
                            RelationMatrix(RNum,20)=LumpedMatrix(indices(k),16);
                            RelationMatrix(RNum,21)=SNIsolates(indices(k));
                            RelationMatrix(RNum,22)=1;%LumpedNodes(indices(k)).Refs(1);
                            
                            RelationMatrix(RNum,23)=Diff1(indices(k),5);
                            RelationMatrix(RNum,24)=NewMatrix(i,5);
                            RelationMatrix(RNum,25)=NewMatrix(indices(k),5);
                            
                            RelationRefs(RNum).R2=LumpedNodes(indices(k)).Refs;
                            
                            RStartYear(RNum,:)=SStartYears(i,:);
                            
                            
                            Ycount=Ycount+1;
                            
                            RNum=RNum+1;
                            
                            
                        end
                        flag1=1;
                        
                    elseif (flag2==0)
                        t3=NewMatrix(j,1);
                        [l1 l2]=size(VectD1);
                        indices=find((Diff1(:,1)==Diff1(j,1)));
                        diff2Ind=indices;
                        deltat=NewMatrix(j,1)- (2*NewMatrix(i,1)+VectD1(1,1))/2;
                        
                        for k=1:l1
                            %here dt=t3-(t1+t2)/2 and dp=p3-(p2+p1)/2
                            %get total number of bacteria
                            
                            deltap2=(2*NewMatrix(i,2)+VectD1(k,2));
                            deltap1=(2*NewMatrix(i,4)+VectD1(k,4));
                            deltaintermideate=(2*NewMatrix(i,6)+VectD1(k,6));
                            deltaAvgI=deltaintermideate/deltap2;
                            deltaAvg=deltap1/deltap2;
                            
                            for k2=1:length(indices)
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                deltap=NewMatrix(indices(k2),3)-deltaAvg;
                                deltaIntermediate=NewMatrix(indices(k2),5)-deltaAvgI;
                                
                                j=indices(k2)+1;
                                RelationMatrix(RNum,1)=stateNum;%represents the row having t1
                                RelationMatrix(RNum,2)=stateNum+1;%represents the row having t2
                                RelationMatrix(RNum,3)=stateNum+2;
                                RelationMatrix(RNum,4)=stateNum+2;
                                RelationMatrix(RNum,5)=stateNum+2;
                                RelationMatrix(RNum,6)=stateNum+2;
                                RelationMatrix(RNum,7)=deltat;
                                RelationMatrix(RNum,8)=deltap;
                                RelationMatrix(RNum,9)=LumpedMatrix(i,13);
                                RelationMatrix(RNum,10)=LumpedMatrix(i,14);
                                RelationMatrix(RNum,11)= NewMatrix(i,3);
                                RelationMatrix(RNum,12)=LumpedMatrix(indices(k2),13);
                                RelationMatrix(RNum,13)=LumpedMatrix(indices(k2),14);
                                RelationMatrix(RNum,14)=NewMatrix(indices(k2),3);
                                RelationMatrix(RNum,15)=LumpedMatrix(i,15);
                                RelationMatrix(RNum,16)=LumpedMatrix(i,16);
                                RelationMatrix(RNum,17)=SNIsolates(i);
                                RelationMatrix(RNum,18)=1;%LumpedNodes(i).Refs(1);
                                RelationRefs(RNum).R1=LumpedNodes(i).Refs;
                                RelationMatrix(RNum,19)=LumpedMatrix(indices(k2),15);
                                RelationMatrix(RNum,20)=LumpedMatrix(indices(k2),16);
                                RelationMatrix(RNum,21)=SNIsolates(indices(k2));
                                RelationMatrix(RNum,22)=1;%LumpedNodes(indices(k2)).Refs(1);
                                
                                
                                RelationMatrix(RNum,23)=deltaIntermediate;
                                RelationMatrix(RNum,24)=NewMatrix(i,5);
                                RelationMatrix(RNum,25)=NewMatrix(indices(k2),5);
                                
                                
                                RelationRefs(RNum).R2=LumpedNodes(indices(k2)).Refs;
                                
                                
                                RStartYear(RNum,:)=SStartYears(i,:);
                                
                                if (RelationMatrix(RNum,8)>1)
                                    h=0;
                                end
                                RNum=RNum+1;
                                
                            end
                            
                        end
                        flag2=1;
                        
                    elseif (flag3==0)
                        t4=NewMatrix(j,1);
                        deltat=t4 - (t1+t2+t3)/3;
                        indices=find((Diff1(:,1)==Diff1(j,1)));
                        diff3Ind=indices;
                        
                        for k=1:length(indices)
                            for k1=1:length(diff1Ind)
                                for k2=1:length(diff2Ind)
                                    %calculate percentage difference
                                    
                                    p1=NewMatrix(i,4);%resistance number
                                    p2=NewMatrix(diff2Ind(k2),4);%resistance number
                                    p3=NewMatrix(diff1Ind(k1),4);
                                    inter1=NewMatrix(i,6);
                                    inter2=NewMatrix(diff2Ind(k2),6);%resistance number
                                    inter3=NewMatrix(diff1Ind(k1),6);
                                    
                                    deltap=(p1+p2+p3)/3;
                                    deltaint=(inter1+inter2+inter3)/3;
                                    
                                    totalp1=NewMatrix(i,2);%resistance number
                                    totalp2=NewMatrix(diff2Ind(k2),2);%resistance number
                                    totalp3=NewMatrix(diff1Ind(k1),2);
                                    totaldeltap=(totalp1+totalp2+totalp3)/3;
                                    deltapAvg=deltap/totaldeltap;
                                    deltaIntermediateAvg=deltaint/totaldeltap;
                                    
                                    finaldeltap=NewMatrix(indices(k),3) - deltapAvg;
                                    finaldeltaIntermediate=NewMatrix(indices(k),5)-deltaIntermediateAvg;
                                    
                                    RelationMatrix(RNum,1)=stateNum;%represents the row having t1
                                    RelationMatrix(RNum,2)=stateNum+1;
                                    RelationMatrix(RNum,3)=stateNum+2;
                                    RelationMatrix(RNum,4)=stateNum+3;
                                    RelationMatrix(RNum,5)=stateNum+3;
                                    RelationMatrix(RNum,6)=stateNum+3;
                                    RelationMatrix(RNum,7)=deltat;
                                    RelationMatrix(RNum,8)=finaldeltap;
                                    RelationMatrix(RNum,9)=LumpedMatrix(i,13);
                                    RelationMatrix(RNum,10)=LumpedMatrix(i,14);
                                    RelationMatrix(RNum,11)= NewMatrix(i,3);
                                    RelationMatrix(RNum,12)=LumpedMatrix(indices(k),13);
                                    RelationMatrix(RNum,13)=LumpedMatrix(indices(k),14);
                                    RelationMatrix(RNum,14)=NewMatrix(indices(k),3);
                                    RelationMatrix(RNum,15)=LumpedMatrix(i,15);
                                    RelationMatrix(RNum,16)=LumpedMatrix(i,16);
                                    RelationMatrix(RNum,17)=SNIsolates(i);
                                    RelationMatrix(RNum,18)=1;%LumpedNodes(i).Refs(1);
                                    RelationRefs(RNum).R1=LumpedNodes(i).Refs;
                                    RelationMatrix(RNum,19)=LumpedMatrix(indices(k),15);
                                    RelationMatrix(RNum,20)=LumpedMatrix(indices(k),16);
                                    RelationMatrix(RNum,21)=SNIsolates(indices(k));
                                    RelationMatrix(RNum,22)=1;%LumpedNodes(indices(k)).Refs(1);
                                    
                                    
                                    RelationMatrix(RNum,23)=finaldeltaIntermediate;
                                    RelationMatrix(RNum,24)=NewMatrix(i,5);
                                    RelationMatrix(RNum,25)=NewMatrix(indices(k),5);
                                    
                                    
                                    RelationRefs(RNum).R2=LumpedNodes(indices(k)).Refs;
                                    
                                    RStartYear(RNum,:)=SStartYears(i,:);
                                    if (RelationMatrix(RNum,8)>1)
                                        h=0;
                                    end
                                    RNum=RNum+1;
                                    
                                end
                            end
                            j=indices(k)+1;
                        end
                        
                        flag3=1;
                        
                    elseif (flag4==0)
                        t5=NewMatrix(j,1);
                        deltat=t5 -(t1+t2+t3+t4)/4;
                        indices=find((Diff1(:,1)==Diff1(j,1)));
                        diff4Ind=indices;
                        
                        for k=1:length(indices)
                            for k1=1:length(diff1Ind)
                                for k2=1:length(diff2Ind)
                                    for k3=1:length(diff3Ind)
                                        
                                        p1=NewMatrix(i,4);%resistance number
                                        p2=NewMatrix(diff2Ind(k2),4);%resistance number
                                        p3=NewMatrix(diff1Ind(k1),4);
                                        p4=NewMatrix(diff3Ind(k3),4);
                                        deltap=(p1+p2+p3+p4)/4;
                                        
                                        int1=NewMatrix(i,6);%resistance number
                                        int2=NewMatrix(diff2Ind(k2),6);%resistance number
                                        int3=NewMatrix(diff1Ind(k1),6);
                                        int4=NewMatrix(diff3Ind(k3),6);
                                        deltaint=(int1+int2+int3+int4)/4;
                                        
                                        
                                        totalp1=NewMatrix(i,2);%resistance number
                                        totalp2=NewMatrix(diff2Ind(k2),2);%resistance number
                                        totalp3=NewMatrix(diff1Ind(k1),2);
                                        totalp4=NewMatrix(diff3Ind(k3),2);
                                        totaldeltap=(totalp1+totalp2+totalp3+totalp4)/4;
                                        finaldeltap=NewMatrix(indices(k),3)- deltap/totaldeltap;
                                        finaldeltaIntermediate=NewMatrix(indices(k),5)- deltaint/totaldeltap;
                                        
                                        j=indices(k)+1;
                                        RelationMatrix(RNum,1)=stateNum;%represents the row having t1
                                        RelationMatrix(RNum,2)=stateNum+1;%represents the row having t2
                                        RelationMatrix(RNum,3)=stateNum+2;
                                        RelationMatrix(RNum,4)=stateNum+3;
                                        RelationMatrix(RNum,5)=stateNum+4;
                                        RelationMatrix(RNum,6)=stateNum+4;
                                        RelationMatrix(RNum,7)=deltat;
                                        RelationMatrix(RNum,8)=finaldeltap;
                                        RelationMatrix(RNum,9)=LumpedMatrix(i,13);
                                        RelationMatrix(RNum,10)=LumpedMatrix(i,14);
                                        RelationMatrix(RNum,11)= NewMatrix(i,3);
                                        RelationMatrix(RNum,12)=LumpedMatrix(indices(k),13);
                                        RelationMatrix(RNum,13)=LumpedMatrix(indices(k),14);
                                        RelationMatrix(RNum,14)=NewMatrix(indices(k),3);
                                        RelationMatrix(RNum,15)=LumpedMatrix(i,15);
                                        RelationMatrix(RNum,16)=LumpedMatrix(i,16);
                                        RelationMatrix(RNum,17)=SNIsolates(i);
                                        RelationMatrix(RNum,18)=1;%LumpedNodes(i).Refs(1);
                                        RelationRefs(RNum).R1=LumpedNodes(i).Refs;
                                        RelationMatrix(RNum,19)=LumpedMatrix(indices(k),15);
                                        RelationMatrix(RNum,20)=LumpedMatrix(indices(k),16);
                                        RelationMatrix(RNum,21)=SNIsolates(indices(k));
                                        RelationMatrix(RNum,22)=1;%LumpedNodes(indices(k)).Refs(1);
                                        
                                        
                                        RelationMatrix(RNum,23)=finaldeltaIntermediate;
                                        RelationMatrix(RNum,24)=NewMatrix(i,5);
                                        RelationMatrix(RNum,25)=NewMatrix(indices(k),5);
                                        
                                        
                                        RelationRefs(RNum).R2=LumpedNodes(indices(k)).Refs;
                                        RStartYear(RNum,:)= SStartYears(i,:);
                                        if (RelationMatrix(RNum,8)>1)
                                            h=0;
                                        end
                                        RNum=RNum+1;
                                    end
                                end
                            end
                        end
                        flag4=1;
                        
                    elseif (flag5==0)
                        t6=NewMatrix(j,1);
                        deltat=t6 -(t1+t2+t3+t4+t5)/5;
                        indices=find((Diff1(:,1)==Diff1(j,1)));
                        diff5Ind=indices;
                        for k=1:length(indices)
                            for k1=1:length(diff1Ind)
                                for k2=1:length(diff2Ind)
                                    for k3=1:length(diff3Ind)
                                        for k4=1:length(diff4Ind)
                                            
                                            p1=NewMatrix(i,4);%resistance number
                                            p2=NewMatrix(diff2Ind(k2),4);%resistance number
                                            p3=NewMatrix(diff1Ind(k1),4);
                                            p4=NewMatrix(diff3Ind(k3),4);
                                            p5=NewMatrix(diff4Ind(k4),4);
                                            deltap=(p1+p2+p3+p4+p5)/5;
                                            
                                            int1=NewMatrix(i,6);
                                            int2=NewMatrix(diff2Ind(k2),6);
                                            int3=NewMatrix(diff1Ind(k1),6);
                                            int4=NewMatrix(diff3Ind(k3),6);
                                            int5=NewMatrix(diff4Ind(k4),6);
                                            deltaint=(int1+int2+int3+int4+int5)/5;
                                            
                                            
                                            totalp1=NewMatrix(i,2);%resistance number
                                            totalp2=NewMatrix(diff2Ind(k2),2);%resistance number
                                            totalp3=NewMatrix(diff1Ind(k1),2);
                                            totalp4=NewMatrix(diff3Ind(k3),2);
                                            totalp5=NewMatrix(diff4Ind(k4),2);
                                            totaldeltap=(totalp1+totalp2+totalp3+totalp4+totalp5)/5;
                                            finaldeltap=NewMatrix(indices(k),3)- deltap/totaldeltap;
                                            finaldeltaIntermediate=NewMatrix(indices(k),5)- deltaint/totaldeltap;
                                            
                                            j=indices(k)+1;
                                            RelationMatrix(RNum,1)=stateNum;%represents the row having t1
                                            RelationMatrix(RNum,2)=stateNum+1;%represents the row having t2
                                            RelationMatrix(RNum,3)=stateNum+2;
                                            RelationMatrix(RNum,4)=stateNum+3;
                                            RelationMatrix(RNum,5)=stateNum+4;
                                            RelationMatrix(RNum,6)=stateNum+5;
                                            RelationMatrix(RNum,7)=deltat;
                                            RelationMatrix(RNum,8)=finaldeltap;
                                            RelationMatrix(RNum,9)=LumpedMatrix(i,13);
                                            RelationMatrix(RNum,10)=LumpedMatrix(i,14);
                                            RelationMatrix(RNum,11)= NewMatrix(i,3);
                                            RelationMatrix(RNum,12)=LumpedMatrix(indices(k),13);
                                            RelationMatrix(RNum,13)=LumpedMatrix(indices(k),14);
                                            RelationMatrix(RNum,14)=NewMatrix(indices(k),3);
                                            RelationMatrix(RNum,15)=LumpedMatrix(i,15);
                                            RelationMatrix(RNum,16)=LumpedMatrix(i,16);
                                            RelationMatrix(RNum,17)=SNIsolates(i);
                                            RelationMatrix(RNum,18)=1;%LumpedNodes(i).Refs(1);
                                            RelationRefs(RNum).R1=LumpedNodes(i).Refs;
                                            RelationMatrix(RNum,19)=LumpedMatrix(indices(k),15);
                                            RelationMatrix(RNum,20)=LumpedMatrix(indices(k),16);
                                            RelationMatrix(RNum,21)=SNIsolates(indices(k));
                                            RelationMatrix(RNum,22)=1;%LumpedNodes(indices(k)).Refs(1);
                                            
                                            
                                            RelationMatrix(RNum,23)=finaldeltaIntermediate;
                                            RelationMatrix(RNum,24)=NewMatrix(i,5);
                                            RelationMatrix(RNum,25)=NewMatrix(indices(k),5);
                                            
                                            RelationRefs(RNum).R2=LumpedNodes(indices(k)).Refs;
                                            RStartYear(RNum,:)=SStartYears(i,:);
                                            
                                            RNum=RNum+1;
                                            
                                        end
                                    end
                                end
                            end
                        end
                        flag5=1;
                        
                    else
                        j=j+1;
                    end
                else
                    j=j+1;
                    
                end
            end
            
        end
    end
end
[ro co]=size(RelationMatrix);
if (ro~=0)
    
    RelationMatrix(:,8)=100*RelationMatrix(:,8);
    RelationMatrix(:,11)=100*RelationMatrix(:,11);
    RelationMatrix(:,14)=100*RelationMatrix(:,14);
    RelationMatrix(:,24)=100*RelationMatrix(:,24);
    RelationMatrix(:,25)=100*RelationMatrix(:,25);
    
    
end

end