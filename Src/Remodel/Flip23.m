function [Geo_n, Geo, Dofs, Set, newgIds] = Flip23(Geo_n, Geo, Dofs, Set, newgIds)
%FLIP23 Perform flip 2-3 operation, when the edge is short
%   Involves replacing the edge pq as it shorten to zero length by the new 
%   triangle ghf that is shared between cell A and B (A has been displaced 
%   upward to reveal the new interface ghf).
%
%   Consequences:
%   - 1 connection between nodes (Xs) dissappear and 1 appears.
%   - 2 vertices (and its correspondant tetrahedra) are removed.
%   - 3 vertices (and its correspondant tetrahedra) are created.

%% loop over the rest of faces (Flip23)
	
	for c = 1:Geo.nCells
		Ys = Geo.Cells(c).Y;
		Ts = Geo.Cells(c).T;
		% WHOLE REMODELLING WILL BE INSIDE HERE
		for f = 1:length(Geo.Cells(c).Faces)
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
			Geo_backup = Geo; Geo_n_backup = Geo_n;
			for t = 1:length(Face.Tris)
				if ismember(Geo.Cells(c).globalIds(Face.Tris(t,:)),newgIds)
					nrgs(t) = 0;
				end
			end
			
			[~,idVertex]=max(nrgs);
			edgeToChange = Face.Tris(idVertex,:);
			
			if max(nrgs)<Set.RemodelTol || length(unique(Face.Tris)) == 3 || ...
					CheckSkinnyTriangles(Ys(edgeToChange(1),:),Ys(edgeToChange(2),:),Face.Centre)
                continue
			end
			
			targetTets = Geo.Cells(c).T(edgeToChange,:);
			
			[Ynew, Tnew] = YFlip23(Ys, Ts, edgeToChange, Geo);
			
			Geo   = ReplaceYs(targetTets, Tnew, Ynew, Geo);
			
			Geo   = Rebuild(Geo, Set); 
			Geo_n = Rebuild(Geo_n, Set);
			
	        Geo   = BuildGlobalIds(Geo); 
			Geo_n = BuildGlobalIds(Geo_n);
			
			if ~CheckConvexityCondition(Tnew, Geo_backup.Cells(c).T, Geo) && ~flag
				fprintf('=>> 23 Flip.\n');
				Dofs = GetDOFs(Geo, Set);
				Dofs = GetRemodelDOFs(Tnew, Dofs, Geo);
				[Geo, Set, DidNotConverge] = SolveRemodelingStep(Geo_n, Geo, Dofs, Set);
				if DidNotConverge
					Geo = Geo_backup;
					Geo_n= Geo_n_backup;
					fprintf('=>> 23-Flip is not compatible rejected.\n');
					continue
				end
			else
            	Geo = Geo_backup;
				Geo_n= Geo_n_backup;
    			fprintf('=>> 23-Flip is not compatible rejected.\n');
				continue
			end
            return
		end
	end
end

