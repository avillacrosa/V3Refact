function [g,K,Energy, Set, gr, dyr, dy] = newtonRaphson(Geo, Set, K, g, numStep, t)
	% TODO FIXME Add dofs
	dy=zeros(Geo.totalY*3, 1);
	dyr=norm(dy);
	gr=norm(g);
	gr0=gr;
	fprintf('Step: %i,Iter: %i ||gr||= %e ||dyr||= %e dt/dt0=%.3g\n',numStep,0,gr,dyr,Set.dt/Set.dt0);
	Energy = 0;
	Set.iter=1;
	auxgr=zeros(3,1);
	auxgr(1)=gr;
	ig=1;
	alphas = [1.4e-1, 8.2e-2, 3.1e-1, 3.2e-1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
	while (gr>Set.tol || dyr>Set.tol) && Set.iter<Set.MaxIter
    	dy=-K\g;
		% TODO FIXME ADD...
    	alpha=LineSearch(Geo, Set, g, dy);
		alpha = alphas(Set.iter);
    	%% Update mechanical nodes
    	dy_reshaped = reshape(dy * alpha, 3, (Geo.numF+Geo.numY))';
    	[Geo] = updateVertices(Geo, Set, dy_reshaped);
		PostProcessingVTK(Geo, Set)

		% TODO FIXME ???
%     	if Set.nu > Set.nu0 &&  gr<Set.tol
%         	Set.nu = max(Set.nu/2, Set.nu0);
%     	end
    	%% ----------- Compute K, g ---------------------------------------
		% TODO FIXME ADD...
%     	try
    	[g,K,Energy]=KgGlobal(Geo, Geo, Set);
%     	catch ME
%         	if (strcmp(ME.identifier,'KgBulk:invertedTetrahedralElement'))
%             	%% Correct inverted Tets
%             	[Y, Cell] = correctInvertedMechTets(ME, dy, Y, Cell, Set);
%             	
%             	% Run again
%             	[g,K,Cell,Energy]=KgGlobal(Cell, SCn, Y0, Y, Yn, Set, CellInput);
%         	else
%             	throw(ME)
%         	end
%     	end
    	dyr=norm(dy);
    	gr=norm(g);
    	fprintf('Step: % i,Iter: %i, Time: %g ||gr||= %.3e ||dyr||= %.3e alpha= %.3e  nu/nu0=%.3g \n',numStep,Set.iter,t,gr,dyr,alpha,Set.nu/Set.nu0);
	%     PostProcessingVTK(X,Y,T.Data,Cn,Cell,strcat(Set.OutputFolder,Esc,'ResultVTK_iter'),Set.iter,Set);
    	Set.iter=Set.iter+1;
    	auxgr(ig+1)=gr;
    	if ig ==2
        	ig=0;
    	else
        	ig=ig+1;
    	end
    	if (abs(auxgr(1)-auxgr(2))/auxgr(1)<1e-3 &&...
            	abs(auxgr(1)-auxgr(3))/auxgr(1)<1e-3 &&...
            	abs(auxgr(3)-auxgr(2))/auxgr(3)<1e-3)...
            	|| abs((gr0-gr)./gr0)>1e3
        	Set.iter=Set.MaxIter;
    	end
	end
end

