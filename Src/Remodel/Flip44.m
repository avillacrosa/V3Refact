function [Geo_n, Geo, Dofs, Set, newgIds] = Flip44(Geo_n, Geo, Dofs, Set, newgIds)
    % flip44 Summary of this function goes here
    %   Detailed explanation goes here
    %% loop over 4-vertices-faces (Flip44)
   for c = 1:Geo.nCells
		% WHOLE REMODELLING WILL BE INSIDE HERE
		for f = 1:length(Geo.Cells(c).Faces)
% 			if f > length(Geo.Cells(c).Faces)
% 				continue
% 			end
		    Ys = Geo.Cells(c).Y;
		    Ts = Geo.Cells(c).T;
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
			if max(nrgs)<Set.RemodelTol || min(nrgs)<Set.RemodelTol*1e-4 || length(unique(Face.Tris))~=4
% 			if (max(nrgs)<Set.RemodelTol && min(nrgs)<Set.RemodelTol/1.5) || length(unique(Face.Tris))~=4
                continue
			end
			
			oV=[Face.Tris(1,1); Face.Tris(2,1); Face.Tris(3,1); Face.Tris(4,1)];

			Geo_backup = Geo;
			Geo_n_backup = Geo_n;
			fprintf('=>> 44 Flip.\n');
			side=[1 2;
            	  2 3;
            	  3 4;
            	  1 4];
			L(1)=norm(Ys(oV(1),:)-Ys(oV(2),:));
        	L(2)=norm(Ys(oV(2),:)-Ys(oV(3),:));
        	L(3)=norm(Ys(oV(3),:)-Ys(oV(4),:));
        	L(4)=norm(Ys(oV(1),:)-Ys(oV(4),:));
			[~,Jun]=min(L);
        	VJ=oV(side(Jun,:));
        	cVJ3=intersect(Ts(VJ(1),:),Ts(VJ(2),:));
			% cVJ3 is equal
        	N=unique(Ts(VJ,:)); % all nodes
        	NZ=N(~ismember(N,cVJ3));
        	NX=Face.ij;
        	Tnew1=Ts(oV(1),:);       Tnew1(ismember(Tnew1,NX(1)))=NZ(~ismember(NZ,Tnew1));
        	Tnew2=Ts(oV(2),:);       Tnew2(ismember(Tnew2,NX(2)))=NZ(~ismember(NZ,Tnew2));
        	Tnew3=Ts(oV(3),:);       Tnew3(ismember(Tnew3,NX(1)))=NZ(~ismember(NZ,Tnew3));
        	Tnew4=Ts(oV(4),:);       Tnew4(ismember(Tnew4,NX(2)))=NZ(~ismember(NZ,Tnew4));
        	Tnew=[Tnew1;Tnew2;Tnew3;Tnew4];
			Ynew=Flip44(Ys(oV,:),Tnew,L,Geo);
			if CheckConvexityCondition(Tnew,Geo_backup.Cells(c).T,Geo)
    			fprintf('=>> 44-Flip is not compatible rejected.\n');
    			continue
			end
			targetTets = Geo.Cells(c).T(oV,:);
			targetNodes = unique(targetTets);
			for n_i = 1:length(targetNodes)
				tNode = targetNodes(n_i);
				CellJ = Geo.Cells(tNode);
				hits = find(sum(ismember(CellJ.T,targetTets),2)==4);
				Geo.Cells(tNode).T(hits,:) = [];
				Geo_n.Cells(tNode).T(hits,:) = [];

				news = find(sum(ismember(Tnew,tNode)==1,2));
				Geo.Cells(tNode).T(end+1:end+length(news),:) = Tnew(news,:);
				Geo_n.Cells(tNode).T(end+1:end+length(news),:) = Tnew(news,:);
				if ~ismember(tNode, Geo.XgID)
					Geo.Cells(tNode).Y(hits,:) = [];
					Geo_n.Cells(tNode).Y(hits,:) = [];
					Geo.Cells(tNode).Y(end+1:end+length(news),:) = Ynew(news,:);
					Geo_n.Cells(tNode).Y(end+1:end+length(news),:) = Ynew(news,:);
				end
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
			
            remodelDofs = zeros(0,1);
			for ccc = 1:Geo.nCells
				news = find(sum(ismember(Tnew,ccc)==1,2));
				remodelDofs(end+1:end+length(news)) = Geo.Cells(ccc).globalIds(end-length(news)+1:end,:);
				for jj = 1:length(Geo.Cells(ccc).Faces)
					Face = Geo.Cells(ccc).Faces(jj);
					FaceTets = Geo.Cells(ccc).T(unique(Face.Tris),:);
					hits = find(sum(ismember(Tnew,FaceTets),2)==4);
					if length(hits)>3
						remodelDofs(end+1) = Face.globalIds;
					end

				end
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


