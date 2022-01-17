function [Geo_n, Geo, Dofs, Set, newgIds] = flip32(Geo_n, Geo, Dofs, Set, newgIds)
	%FLIP32 Summary of this function goes here
	%   Detailed explanation goes here
	%% loop over 3-vertices-faces (Flip32)
	
	DidNotConverge = false;
	for c = 1:Geo.nCells
		% WHOLE REMODELLING WILL BE INSIDE HERE
		for f = 1:length(Geo.Cells(c).Faces)
	    	Ys = Geo.Cells(c).Y;
	    	Ts = Geo.Cells(c).T;
% 			if f > length(Geo.Cells(c).Faces)
% 				continue
% 			end
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
	
			if max(nrgs)<Set.RemodelTol || length(unique(Face.Tris)) ~= 3
            	continue
			end

			Geo_backup = Geo;
			Geo_n_backup = Geo_n;
			fprintf('=>> 32 Flip.\n');
			oV=[Face.Tris(1,1); Face.Tris(2,1); Face.Tris(3,1)];
			n=intersect(intersect(Ts(oV(1),:),Ts(oV(2),:)),Ts(oV(3),:));
			N=unique(Ts(oV,:)); % all nodes
			N=N(~ismember(N,n));
	
			N3=N(~ismember(N,Ts(oV(1),:)));
			Tnew1=Ts(oV(1),:); Tnew2=Tnew1;
			Tnew1(ismember(Ts(oV(1),:),n(2)))=N3;
			Tnew2(ismember(Ts(oV(1),:),n(1)))=N3;
			Tnew=[Tnew1;
      		  	Tnew2];
	
			% The new vertices 
			Xs = zeros(length(n),3);
			for ni = 1:length(n)
				Xs(ni,:) = Geo.Cells(n(ni)).X;
			end
			Ynew=Flip32(Ys(oV,:),Xs);

			if CheckConvexityCondition(Tnew,Geo_backup.Cells(c).T,Geo)
    			fprintf('=>> 32-Flip is not compatible rejected.\n');
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

%% ========================================================================
function [Yn]=Flip32(Y,X12)
length=[norm(Y(1,:)-Y(2,:)) norm(Y(3,:)-Y(2,:)) norm(Y(1,:)-Y(3,:))];
length=min(length);
perpen=cross(Y(1,:)-Y(2,:),Y(3,:)-Y(2,:));
Nperpen=perpen/norm(perpen);
center=sum(Y,1)./3;
Nx=X12(1,:)-center; Nx=Nx/norm(Nx);
if dot(Nperpen,Nx)>0
    Y1=center+(length).*Nperpen;
    Y2=center-(length).*Nperpen;
else
    Y1=center-(length).*Nperpen;
    Y2=center+(length).*Nperpen;
end 
% Y1=center+(length).*Nperpen;
% Y2=center-(length).*Nperpen;
Yn=[Y1;Y2];
end

