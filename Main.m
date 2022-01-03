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
Dofs       = GetDOFs(Geo, Set);

% TODO FIXME HARDCODE FOR COMPARISON. Good definition is the minimum of
% areatri and barriertri inside initialize geometry
Set.BarrierTri0 = 0.0012;
t=0;
numStep=1;

% PostProcessingVTK(Geo, Set)
while t<=Set.tend
    [Geo, Dofs] = applyBoundaryCondition(t, Geo, Dofs, Set);

%     [Geo] = Remodeling(Geo, Set);
	[g,K] = KgGlobal(Geo, Geo, Set);
    
	[Geo, g,K,Energy, Set, gr, dyr, dy] = newtonRaphson(Geo, Set, K, g, numStep, t);

%     for c = 1:Geo.nCells
% 		Geo.Cells(c).X     = BuildXFromY(Geo.Cells(c), Geo.Cells, ...
% 													Geo.XgID, Set);
%     end
    t=t+Set.dt;
    numStep=numStep+1;
end