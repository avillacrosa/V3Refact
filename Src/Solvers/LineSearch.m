function [alpha]=LineSearch(Geo_n, Geo, Set, gc, dy)
	
	%% Update mechanical nodes
	dy_reshaped = reshape(dy, 3, (Geo.numF+Geo.numY))';
	
	% TODO FIXME why ???
	[Geo] = updateVertices(Geo, Set, dy_reshaped);
	
	try
    	[g,~,~]=KgGlobal(Geo_n, Geo, Set);
	catch ME
		ME.rethrow();
%     	if (strcmp(ME.identifier,'KgBulk:invertedTetrahedralElement'))
%         	%% Correct inverted Tets
%         	[Y, Cell] = correctInvertedMechTets(ME, dy, Y, Cell, Set);
%         	
%         	% Run again
%         	[g]=KgGlobal(Cell, SCn, Y0, Y, Yn, Set, CellInput);
%     	else
%         	ME.rethrow();
%     	end
	end
	% TODO FIXME...
	dof = 1:length(g);
	gr0=norm(gc(dof));   
	gr=norm(g(dof)); 
	% TODO FIXME, small differences in gr are due 
	
	if gr0<gr
    	R0=dy(dof)'*gc(dof);
    	R1=dy(dof)'*g(dof);
    	
    	R=(R0/R1);
    	alpha1=(R/2)+sqrt((R/2)^2-R);
    	alpha2=(R/2)-sqrt((R/2)^2-R);
    	
    	
    	if isreal(alpha1) && alpha1<2 && alpha1>1e-3
        	alpha=alpha1;
    	elseif isreal(alpha2) && alpha2<2 && alpha2>1e-3
        	alpha=alpha2;
    	else
        	alpha=0.1;
    	end
	else
    	alpha=1;
	end

end