close all; clear; clc;
addpath(genpath('Src'));

disp('------------- SIMULATION STARTS -------------');

% Stretch
% Compress
Extrusion
% StretchBulk
% Extrude

Set=SetDefault(Set);
InitiateOutputFolder(Set);

[Geo, Set] = InitializeGeometry3DVertex(Geo, Set);
PostProcessingVTK(Geo, Set, 0);

% TODO FIXME, this is bad, should be joined somehow
if ~Set.Substrate
    Dofs = GetDOFs(Geo, Set);
else
    Dofs = GetDOFsSubstrate(Geo, Set);
end
Geo.Remodelling = false;

t=0; tr=0; tp=0;
Geo_0   = Geo;
Geo_n   = Geo;
numStep = 1;

PostProcessingVTK(Geo, Set, numStep)
while t<=Set.tend
	if Set.Remodelling && abs(t-tr)>=Set.RemodelingFrequency
        [Geo_n, Geo, Dofs, Set] = Remodeling(Geo_0, Geo_n, Geo, Dofs, Set);
        tr    = t;
	end
	Geo_b = Geo;
	Set.iIncr=numStep;

    [Geo, Dofs] = ApplyBoundaryCondition(t, Geo, Dofs, Set);
	Geo     = UpdateMeasures(Geo);
	[g,K,E] = KgGlobal(Geo_0, Geo_n, Geo, Set); 
	[Geo, g, K, Energy, Set, gr, dyr, dy] = NewtonRaphson(Geo_0, Geo_n, Geo, Dofs, Set, K, g, numStep, t);
    if gr<Set.tol && dyr<Set.tol && all(isnan(g(Dofs.Free)) == 0) && all(isnan(dy(Dofs.Free)) == 0) 
		if Set.nu/Set.nu0 == 1
			fprintf('STEP %i has converged ...\n',Set.iIncr)

			Geo = BuildXFromY(Geo_n, Geo);
			tp=t;

			t=t+Set.dt;
			Set.dt=min(Set.dt+Set.dt*0.5, Set.dt0);
			Set.MaxIter=Set.MaxIter0;
			Set.ApplyBC=true;
			numStep=numStep+1;
			Geo_n = Geo;
			PostProcessingVTK(Geo, Set, numStep)
		else			
            Set.nu = max(Set.nu/2, Set.nu0);
		end
    else 
        fprintf('Convergence was not achieved ... \n');
        Geo = Geo_b;
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
        else
            fprintf('Step %i did not converge!! \n', Set.iIncr);
            break;
        end
    end
end

