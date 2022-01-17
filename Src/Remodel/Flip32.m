function [Geo_n, Geo, Dofs, Set, newgIds] = Flip32(Geo_n, Geo, Dofs, Set, newgIds)
	for c = 1:Geo.nCells
		for f = 1:length(Geo.Cells(c).Faces)
    	    Ys = Geo.Cells(c).Y;
    	    Ts = Geo.Cells(c).T;
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
			Geo_backup = Geo; Geo_n_backup = Geo_n;

            if max(nrgs)<Set.RemodelTol || length(unique(Face.Tris)) ~= 3
            	continue
            end

			YsToChange=[Face.Tris(1,1); Face.Tris(2,1); Face.Tris(3,1)];
            [Ynew, Tnew] = YFlip32(Ys, Ts, YsToChange, Geo);

            targetTets = Geo.Cells(c).T(YsToChange,:);
			Geo   = ReplaceYs(targetTets, Tnew, Ynew, Geo);
			Geo_n = ReplaceYs(targetTets, Tnew, Ynew, Geo_n);

            Geo   = RemoveFaces(Face, Geo);
            Geo_n = RemoveFaces(Face, Geo_n);

			Geo   = Rebuild(Geo, Set);
			Geo_n = Rebuild(Geo_n, Set);

        	Geo   = BuildGlobalIds(Geo);
			Geo_n = BuildGlobalIds(Geo_n);
	
            if ~CheckConvexityCondition(Tnew,Geo_backup) && CheckTris(Geo)
    			fprintf('=>> 32 Flip.\n');
				Dofs = GetDOFs(Geo, Set);
				[Dofs, Geo]  = GetRemodelDOFs(Tnew, Dofs, Geo);
				[Geo, Set, DidNotConverge] = SolveRemodelingStep(Geo_n, Geo, Dofs, Set);
                for n_i = 1:length(targetNodes)
			        tNode = targetNodes(n_i);
			        news = find(sum(ismember(Tnew,tNode)==1,2));
			        if ~ismember(tNode, Geo.XgID)
				        Geo_n.Cells(tNode).Y(end-length(news)+1:end,:) = Geo.Cells(tNode).Y(end-length(news)+1:end,:);
			        end
                end
                if DidNotConverge
					Geo   = Geo_backup;
					Geo_n = Geo_n_backup;
					fprintf('=>> 32-Flip rejected: did not converge\n');
					continue
                end
        	    return
            else
                Geo   = Geo_backup;
				Geo_n = Geo_n_backup;
                fprintf('=>> 32-Flip rejected: is not compatible\n');
    			continue
            end
		end
	end
end

