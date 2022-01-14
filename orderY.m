clc; close all; clear
load('weird.mat');

load('/home/doctorantlacan/Vertex3DTEST/weirdY.mat');
load('/home/doctorantlacan/Vertex3DTEST/weirdF.mat');

yyy = unique([Geo.Cells(1).Y; Geo.Cells(2).Y; Geo.Cells(3).Y],'rows');

idxs = [];
for c = 1:length(weirdY)
    yc = weirdY(c,:);
    idx = find(vecnorm(yc-yyy,2,2) < 1e-4);
    idxs(end+1) = idx;
end
resY = yyy(idxs,:);

faces = getFaces(Geo);

idxs = [];
for c = 1:length(weirdF)
    yc = weirdF(c,:);
    idx = find(vecnorm(yc-faces,2,2) < 1e-4);
    idxs(end+1) = idx;
end
resF = faces(idxs,:);

resCellArea0=zeros(0,1);
for c = 1:3
	resCellArea0(end+1) = Geo.Cells(c).Area0;
end

% resFacesA = zeros(0,1)
% for c = 1:3
% 	for f = 1:length(Geo.Cells(c).Faces)
% 		resFacesA(end+1,:) = Geo.Cells(c).Faces(f).Area;
% 	end
% end
% resFacesA = resFacesA(idxs,:);


save('myY','resY', 'resF','resCellArea0', 'resFacesA')