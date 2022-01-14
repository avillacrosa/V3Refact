clc; close all; clear

load('/home/doctorantlacan/Vertex3DTEST/weirdF.mat');
load('weird.mat');
faces = getFaces(Geo);

idxs = [];
for c = 1:length(weirdF)
    yc = weirdY(c,:);
    idx = find(vecnorm(yc-faces,2,2) < 1e-4);
    idxs(end+1) = idx;
end
resY = faces(idxs,:);

save('myY','resF')