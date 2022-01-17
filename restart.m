close all; clear; clc;
load('pre90remo.mat');
while t<=Set.tend

	if Set.Remodelling && abs(t-tr)>=Set.RemodelingFrequency
        [Geo_n, Geo, Dofs, Set] = Remodeling(Geo_n, Geo, Dofs, Set);
        tr    = t;
	end
	Geo_b = Geo;
	Set.iIncr=numStep;
% 
    [Geo, Dofs] = applyBoundaryCondition(t, Geo, Dofs, Set);
% 	load('preKG');
	[g,K,Geo] = KgGlobal(Geo_n, Geo, Set); % TODO FIXME, Isn't this bad btw ?
	[Geo, g, K, Energy, Set, gr, dyr, dy] = newtonRaphson(Geo_n, Geo, Dofs, Set, K, g, numStep, t);
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
		% If all iterations where exhausted, use *3 the initial max
		% iterations, then multiply nu per 10 and recalculate
        if Set.iter == Set.MaxIter0 
            fprintf('First strategy ---> Repeating the step with higher viscosity... \n');
            Set.MaxIter=Set.MaxIter0*3;
            Set.nu=10*Set.nu0;
		% If all iterations where exhausted, w.r.t. 3*initial max
		% iterations, 
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

