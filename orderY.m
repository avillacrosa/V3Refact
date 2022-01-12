clc; close all; clear

load('/home/adria/Vertex3DTEST/funkyflip.mat');
load('funkyflip.mat');
aaa = Geo.Cells(1).Y; 
bbb = Geo.Cells(2).Y ; 
ccc = Geo.Cells(3).Y; 
yyy = [aaa;bbb;ccc]; 
yyy = sort(unique(yyy,"rows"));

idxs = [];
for c = 1:length(savey)
    yc = savey(c,:);
    idx = find(vecnorm(yc-yyy,2,2) < 1e-4);
    idxs(end+1) = idx;
end
res = ym(idxs,:);