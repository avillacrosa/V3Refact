close all; clear; clc;
addpath(genpath("Src"));

disp('------------- SIMULATION STARTS -------------');

Set=struct(); Geo=struct(); % TO DELETE!
Set.OutputFolder='Result/test'; % TO DELETE!

Set=SetDefault(Set);
% TODO FIXME, HARDCODE, but it is also on the previous version
Set.ApplyBC=true;
% TODO FIXME, HARDCODE, but it is also on the previous version
Set.MaxIter0 = Set.MaxIter;

InitiateOutputFolder(Set);

%% Mesh generation
fprintf('Generating geometry\n')
[Geo, Set] = InitializeGeometry3DVertex(Geo,Set);
Dofs       = GetDOFs(Geo, Set);

% TODO FIXME HARDCODE FOR COMPARISON. Good definition is the minimum of
% areatri and barriertri inside initialize geometry
Set.BarrierTri0 = 0.0012;
t=0;
tr=0;
numStep=1;

% PostProcessingVTK(Geo, Set, numStep)
while t<=Set.tend

    if Set.Remodelling && abs(t-tr)>=Set.RemodelingFrequency
        [Geo] = Remodeling(Geo, Dofs, Set);
        tr=t;
    end

    [Geo, Dofs] = applyBoundaryCondition(t, Geo, Dofs, Set);
	[g,K] = KgGlobal(Geo, Geo, Set); % TODO FIXME, Isn't this bad btw ?
    
	[Geo, g, K, Energy, Set, gr, dyr, dy] = newtonRaphson(Geo, Dofs, Set, K, g, numStep, t);
    if gr<Set.tol && dyr<Set.tol && all(isnan(g(Dofs.Free)) == 0) && all(isnan(dy(Dofs.Free)) == 0) && Set.nu/Set.nu0 == 1
        t=t+Set.dt;
        numStep=numStep+1;
%         PostProcessingVTK(Geo, Set, numStep)
    else 
        fprintf('Convergence was not achieved ... \n');
        Y=Yp;
        Cell=Cellp;
        if Set.iter == Set.MaxIter0 
            fprintf('First strategy ---> Repeating the step with higher viscosity... \n');

            Set.MaxIter=Set.MaxIter0*3;
            Set.nu=10*Set.nu0;
        elseif Set.iter == Set.MaxIter && Set.iter > Set.MaxIter0 && Set.dt>Set.dt0/(2^6)
            fprintf('Second strategy ---> Repeating the step with half step-size...\n');

            Set.MaxIter=Set.MaxIter0;
            Set.nu=Set.nu0;
            t=tp;
            Set.dt=Set.dt/2;
            t=t+Set.dt;
            StepSize(numStep)=Set.dt;
        else
            fprintf('Step %i did not converge!! \n', Set.iIncr);
            break;
        end
    end
end

