clc; close all; clear;
load('flipdata.mat');
fprintf("START HERE \n");
fprintf("MINE???");
t=122;
numStep=1;
% flip23(Geo_n, Geo, Dofs, Set)
[Geo_n, Geo, Dofs] = Remodeling(Geo_n, Geo, Dofs, Set);

% load('KgTest.mat');
[g,K] = KgGlobal(Geo_n, Geo, Set); % TODO FIXME, Isn't this bad btw ?
[Geo, g, K, Energy, Set, gr, dyr, dy] = newtonRaphson(Geo_n, Geo, Dofs, Set, K, g, numStep, t);