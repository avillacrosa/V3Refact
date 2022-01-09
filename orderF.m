clc; close all; clear

load('KgTest.mat');
faces = zeros(0,3);
for c = 1:Geo.nCells
    for f = 1:length(Geo.Cells(c).Faces)
        faces(end+1,:) = Geo.Cells(c).Faces(f).Centre;
    end
end
faces = unique(faces,'rows');
load('/home/adria/Nursery/Stable/FMalik.mat');

idxs = [];
for c = 1:length(malikFaces)
    yc = malikFaces(c,:);
    idx = find(vecnorm(yc-faces,2,2) < 1e-4);
    idxs(end+1) = idx;
end
resF = faces(idxs,:);