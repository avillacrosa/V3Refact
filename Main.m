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

PostProcessingVTK(Geo, Set)
