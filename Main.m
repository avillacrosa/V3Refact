close all; clear; clc;
fclose('all');
addpath(genpath('Src'));
tStart = tic;
disp('------------- SIMULATION STARTS -------------');

% Stretch
StretchBulk
% Compress

Set=SetDefault(Set);
Set=InitiateOutputFolder(Set);
Set.flog = fopen(Set.log, 'w+');

[Geo, Set] = InitializeGeometry3DVertex(Geo, Set);
Dofs = GetDOFs(Geo, Set);
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
	Geo = UpdateFacesArea(Geo);
	[g,K,E] = KgGlobal(Geo_0, Geo_n, Geo, Set); 
	[Geo, g, K, Energy, Set, gr, dyr, dy] = NewtonRaphson(Geo_0, Geo_n, Geo, Dofs, Set, K, g, numStep, t);
    if gr<Set.tol && dyr<Set.tol && all(isnan(g(Dofs.Free)) == 0) && all(isnan(dy(Dofs.Free)) == 0) && Set.nu/Set.nu0 == 1
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
        fprintf('Convergence was not achieved ... \n');
        Geo = Geo_b;
        if Set.iter == Set.MaxIter0 
            fprintf('First strategy ---> Repeating the step with higher viscosity... \n');
            fprintf(Set.flog, 'First strategy ---> Repeating the step with higher viscosity... \n');
            Set.MaxIter=Set.MaxIter0*3;
            Set.nu=10*Set.nu0;
        elseif Set.iter == Set.MaxIter && Set.iter > Set.MaxIter0 && Set.dt>Set.dt0/(2^6)
            fprintf('Second strategy ---> Repeating the step with half step-size...\n');
            fprintf(Set.flog, 'Second strategy ---> Repeating the step with half step-size...\n');
            Set.MaxIter=Set.MaxIter0;
            Set.nu=Set.nu0;
            t=tp;
            Set.dt=Set.dt/2;
            t=t+Set.dt;
        else
            fprintf('Step %i did not converge!! \n', Set.iIncr);
            fprintf(Set.flog, 'Step %i did not converge!! \n', Set.iIncr);
            break;
        end
    end
end
tEnd = duration(seconds(toc(tStart)));
tEnd.Format = 'hh:mm:ss';
fprintf("Total real run time %s \n",tEnd);
fprintf(Set.flog, "Total real run time %s \n",tEnd);