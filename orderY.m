clc; close all; clear

load('/home/adria/Nursery/Stable/YMalik.mat');
load('YMine.mat');

idxs = [];
for c = 1:length(savey)
    yc = savey(c,:);
    idx = find(vecnorm(yc-ym,2,2) < 1e-4);
    idxs(end+1) = idx;
end
res = ym(idxs,:);