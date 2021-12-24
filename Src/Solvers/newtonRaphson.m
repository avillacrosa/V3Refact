function [g,K,Energy, Set, gr, dyr, dy] = newtonRaphson(Geo_n, Set, K, g, numStep, t)
	% TODO FIXME Add dofs
	dy=zeros(Geo_n.totalY*3, 1);
	dyr=norm(dy); gr=norm(g);
	fprintf('Step: %i,Iter: %i ||gr||= %e ||dyr||= %e dt/dt0=%.3g\n',numStep,0,gr,dyr,Set.dt/Set.dt0);
	Energy = 0;
	Set.iter=1;
    Geo = Geo_n;
	while (gr>Set.tol || dyr>Set.tol) && Set.iter<Set.MaxIter
    	dy=-K\g;
		% TODO FIXME ADD...
    	alpha = LineSearch(Geo_n, Geo, Set, g, dy);
    	%% Update mechanical nodes
    	dy_reshaped = reshape(dy * alpha, 3, (Geo.numF+Geo.numY))';
    	[Geo] = updateVertices(Geo, Set, dy_reshaped);

    	%% ----------- Compute K, g ---------------------------------------
    	[g,K,Energy]=KgGlobal(Geo_n, Geo, Set);
    	dyr=norm(dy); gr=norm(g);
    	fprintf('Step: % i,Iter: %i, Time: %g ||gr||= %.3e ||dyr||= %.3e alpha= %.3e  nu/nu0=%.3g \n',numStep,Set.iter,t,gr,dyr,alpha,Set.nu/Set.nu0);
    	Set.iter=Set.iter+1;
	end
end

