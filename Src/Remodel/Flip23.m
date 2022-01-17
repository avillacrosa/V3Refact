function [Geo_n, Geo, Dofs, Set, newgIds] = Flip23(Geo_n, Geo, Dofs, Set, newgIds)	
	for c = 1:Geo.nCells
		for f = 1:length(Geo.Cells(c).Faces)
		    Ys = Geo.Cells(c).Y;
		    Ts = Geo.Cells(c).T;
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
			Geo_backup = Geo; Geo_n_backup = Geo_n;
			for t = 1:length(Face.Tris)
				if ismember(Geo.Cells(c).globalIds(Face.Tris(t,:)),newgIds)
					nrgs(t) = 0;
				end
			end
			
			[~,idVertex]=max(nrgs);
			YsToChange = Face.Tris(idVertex,:);
			
			if max(nrgs)<Set.RemodelTol || length(unique(Face.Tris)) == 3 || ...
					CheckSkinnyTriangles(Ys(YsToChange(1),:),Ys(YsToChange(2),:),Face.Centre)
                continue
			end
			
			[Ynew, Tnew] = YFlip23(Ys, Ts, YsToChange, Geo);

			targetTets = Geo.Cells(c).T(YsToChange,:);
			Geo   = ReplaceYs(targetTets, Tnew, Ynew, Geo);
			Geo_n = ReplaceYs(targetTets, Tnew, Ynew, Geo_n);
			
			Geo   = Rebuild(Geo, Set); 
			Geo_n = Rebuild(Geo_n, Set);
			
	        Geo   = BuildGlobalIds(Geo); 
			Geo_n = BuildGlobalIds(Geo_n);
			
            if ~CheckConvexityCondition(Tnew, Geo_backup) && CheckTris(Geo)
				fprintf('=>> 23 Flip.\n');
				Dofs = GetDOFs(Geo, Set);
				[Dofs, Geo]  = GetRemodelDOFs(Tnew, Dofs, Geo);
				[Geo, Set, DidNotConverge] = SolveRemodelingStep(Geo_n, Geo, Dofs, Set);
                if DidNotConverge
					Geo   = Geo_backup;
					Geo_n = Geo_n_backup;
					fprintf('=>> 23-Flip rejected: did not converge\n');
					continue
                end
                return
			else
            	Geo   = Geo_backup;
				Geo_n = Geo_n_backup;
    		    fprintf('=>> 23-Flip rejected: is not compatible\n');
				continue
            end
		end
	end
end

