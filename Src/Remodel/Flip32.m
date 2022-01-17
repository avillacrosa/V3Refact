function [Geo_n, Geo, Dofs, Set, newgIds] = Flip32(Geo_n, Geo, Dofs, Set, newgIds)
	%FLIP32 Summary of this function goes here
	%   Detailed explanation goes here
	%% loop over 3-vertices-faces (Flip32)
	
	DidNotConverge = false;
	for c = 1:Geo.nCells
		for f = 1:length(Geo.Cells(c).Faces)
	    	Ys = Geo.Cells(c).Y;
	    	Ts = Geo.Cells(c).T;
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
	
			if max(nrgs)<Set.RemodelTol || length(unique(Face.Tris)) ~= 3
            	continue
			end

			Geo_backup = Geo;
			Geo_n_backup = Geo_n;
			fprintf('=>> 32 Flip.\n');
			oV=[Face.Tris(1,1); Face.Tris(2,1); Face.Tris(3,1)];


			if CheckConvexityCondition(Tnew,Geo_backup.Cells(c).T,Geo)
    			fprintf('=>> 32-Flip is not compatible rejected.\n');
    			continue
			end
	
			
			% TODO FIXME, is this sustainable? I think so no ?
			oppfaceId = [];
			for f2 = 1:length(Geo.Cells(Face.ij(2)).Faces)
				Faces2 = Geo.Cells(Face.ij(2)).Faces(f2);
				if sum(ismember(Geo.Cells(c).Faces(f).ij, Faces2.ij))==2
					oppfaceId = f2;
				end
			end
            Geo.Cells(c).Faces(f) = [];
			Geo_n.Cells(c).Faces(f) = [];
			if ~isempty(oppfaceId)
				Geo.Cells(Face.ij(2)).Faces(oppfaceId) = [];
				Geo_n.Cells(Face.ij(2)).Faces(oppfaceId) = [];
			end
% 			f = f-1;
			
			[Geo, flag]= Rebuild(Geo, Set);
            if flag
                Geo = Geo_backup;
                Geo_n = Geo_n_backup;
                continue
            end
			Geo_n = Rebuild(Geo_n, Set);

	% 			PostProcessingVTK(Geo, Set, -2)
        	Geo = BuildGlobalIds(Geo);
			Geo_n = BuildGlobalIds(Geo_n);
	
			% TODO FIXME, I don't like this. Possible way is to take only 
			% DOFs when computing K and g ?
			Geo.AssembleNodes = unique(Tnew);
			Dofs = GetDOFs(Geo, Set);
	
			% TODO FIXME THIS SHOULD ALSO BE CHANGED ACCORDINGLY!
			remodelDofs = zeros(0,1);
			for ccc = 1:Geo.nCells
				news = find(sum(ismember(Tnew,ccc)==1,2));
				remodelDofs(end+1:end+length(news),:) = Geo.Cells(ccc).globalIds(end-length(news)+1:end,:);
				for jj = 1:length(Geo.Cells(ccc).Faces)
					Face = Geo.Cells(ccc).Faces(jj);
					FaceTets = Geo.Cells(ccc).T(unique(Face.Tris),:);
					hits = find(sum(ismember(Tnew,FaceTets),2)==4);
					if length(hits)>3
						remodelDofs(end+1,:) = Face.globalIds;
					end

				end
				% NEW FACE CENTER DOF MISSING!
			end
        	Dofs.Remodel = unique(remodelDofs, 'rows');
			newgIds(end+1:end+length(Dofs.Remodel)) = Dofs.Remodel;
			Geo.AssemblegIds  = Dofs.Remodel;
        	Dofs.Remodel = 3.*(kron(Dofs.Remodel',[1 1 1])-1)+kron(ones(1,length(Dofs.Remodel')),[1 2 3]);
			Geo.Remodelling = true;
        	[Geo, Set, DidNotConverge] = SolveRemodelingStep(Geo_n, Geo, Dofs, Set);
			Geo.Remodelling = false;
			for n_i = 1:length(targetNodes)
				tNode = targetNodes(n_i);
				news = find(sum(ismember(Tnew,tNode)==1,2));
				if ~ismember(tNode, Geo.XgID)
					Geo_n.Cells(tNode).Y(end-length(news)+1:end,:) = Geo.Cells(tNode).Y(end-length(news)+1:end,:);
				end
			end
			if  DidNotConverge || flag
            	Geo = Geo_backup;
				Geo_n= Geo_n_backup;
            	fprintf('=>> Local problem did not converge -> 23 Flip rejected !! \n');
			end
        	return
		end
	end
end

