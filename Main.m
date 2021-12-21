close all; clear; clc;
addpath(genpath("Src"));

disp('------------- SIMULATION STARTS -------------');

Set=struct(); Geo=struct(); % TO DELETE!
Set.OutputFolder='Result/test'; % TO DELETE!

Set=SetDefault(Set);

InitiateOutputFolder(Set);

%% Mesh generation
fprintf('Generating geometry\n')
[Geo, Set] = InitializeGeometry3DVertex(Geo,Set);

t=0;
numStep=1;

PostProcessingVTK(Geo, Set)
while t<=Set.tend
	[g,K]=KgGlobal(Geo, Set);
	[g,K,Cell, Y, Energy, Set, gr, dyr, dy] = newtonRaphson(Geo, Set, K, g, numStep, t);
end