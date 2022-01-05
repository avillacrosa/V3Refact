function [g,K,EnergyV]=KgVolume(Geo, Set)
	% The residual g and Jacobian K of Volume Energy 
	% Energy W_s= sum_cell lambdaV ((V-V0)/V0)^2
	
	[g, K] = initializeKg(Geo, Set);
	EnergyV = 0;
	
	%% Loop over Cells 
	% Analytical residual g and Jacobian K
	% TODO FIXME hard code
	Set.lambdaV = 5;
	for c=1:Geo.nCells
		Cell = Geo.Cells(c);
		Ys = Cell.Y;
    	lambdaV=Set.lambdaV;
    	fact=lambdaV*(Cell.Vol-Cell.Vol0)/Cell.Vol0^2;
    	
    	ge=zeros(size(g, 1), 1);
		ntris = 0;
		for f = 1:length(Cell.Faces)
			Tris = Cell.Faces(f).Tris;
            for t=1:length(Tris)
				y1 = Ys(Tris(t,1),:);
				y2 = Ys(Tris(t,2),:);
				if length(Tris) == 3
					y3 = Ys(Tris(t+1,2),:);
					n3 = Cell.globalIds(Tris(t+1,2));
				else
					y3 = Cell.Faces(f).Centre;
					n3 = Cell.Faces(f).globalIds;
				end
				[gs,Ks]=gKDet(y1, y2, y3); % gs is equal everytime
				nY = [Cell.globalIds(Tris(t,:))', n3];
				ge=Assembleg(ge,gs,nY); % but this assembly is fucked, only for the 3rd cell?
				K = AssembleK(K,Ks*fact/6,nY);
				ntris = ntris + 1;
				if length(Tris) == 3
					break
				end
            end
%             if c == 3
%                 disp(norm(ge));
%             end
		end
    	g=g+ge*fact/6; % Volume contribution of each triangle is det(Y1,Y2,Y3)/6
    	geMatrix = lambdaV*((ge)*(ge')/6/6/Cell.Vol0^2);
    	K=K+geMatrix;
    	EnergyV=EnergyV+lambdaV/2 *((Cell.Vol-Cell.Vol0)/Cell.Vol0)^2;    
	end
end
%%
% TODO FIXME: Move this to lib?
function [gs,Ks]=gKDet(Y1,Y2,Y3)
	% Returns residual and  Jacobian of det(Y)=y1'*cross(y2,y3)
	% gs=[der_y1 det(Y) der_y2 det(Y) der_y3 det(Y)]
	% Ks=[der_y1y1 det(Y) der_y1y2 det(Y) der_y1y3 det(Y)
	%     der_y2y1 det(Y) der_y2y2 det(Y) der_y2y3 det(Y)
	%     der_y3y1 det(Y) der_y3y2 det(Y) der_y3y3 det(Y)]
	dim=length(Y1);
	gs=[cross(Y2,Y3)'; % der_Y1 (det(Y1,Y2,Y3)) 
    	cross(Y3,Y1)';
    	cross(Y1,Y2)'];
	Ks=[ zeros(dim) -Cross_mex(Y3)   Cross_mex(Y2) % g associated to der wrt vertex 1
    	Cross_mex(Y3)   zeros(dim) -Cross_mex(Y1)
    	-Cross_mex(Y2)   Cross_mex(Y1)  zeros(dim)];
end


