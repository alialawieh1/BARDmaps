function [SiteVec SiteMatrix]= GetSiteVectors (xls_fileName)
% refer to the GetBactVectors since this function applies the same concepts
[ndata, text, SiteList] = xlsread(xls_fileName);
SiteVec=[];
[N M]=size(SiteList);
N=N-1;
SiteMatrix=[];
SiteVec=SiteList(2,7);

for i=1:N
[truefalse1, index1] = ismember(SiteList(i+1,7), SiteVec);
if (truefalse1==0)
SiteVec=[SiteVec , SiteList(i+1,7)];
[truefalse1, index1] = ismember(SiteList(i+1,7), SiteVec);
end

SiteMatrix=[SiteMatrix;index1];

end
