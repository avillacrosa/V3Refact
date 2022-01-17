function [Geo_n, Geo, Dofs, Set, newgIds] = flip23(Geo_n, Geo, Dofs, Set, newgIds)
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
		% WHOLE REMODELLING WILL BE INSIDE HERE
		for f = 1:length(Geo.Cells(c).Faces)
		    Ys = Geo.Cells(c).Y;
		    Ts = Geo.Cells(c).T;
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
			for t = 1:length(Face.Tris)
				% TODO FIXME, why make this condition so cryptic, just use
				% what's on the previous version!!!
				cond = sum(ismember(newgIds, Geo.Cells(c).globalIds(Face.Tris(t,:))))>=1;
				if cond
					nrgs(t) = 0;
				end
			end
			[~,idVertex]=max(nrgs);
            if max(nrgs)<Set.RemodelTol || length(unique(Face.Tris)) == 3
                continue
            end
			edgeToChange = Face.Tris(idVertex,:);
		    n3=Ts(edgeToChange(1),  ismember(Ts(edgeToChange(1),:), Ts(edgeToChange(2),:)));
    		n1=Ts(edgeToChange(1), ~ismember(Ts(edgeToChange(1),:),n3));
    		n2=Ts(edgeToChange(2), ~ismember(Ts(edgeToChange(2),:),n3));
    		num=[1 2 3 4];
    		num=num(Ts(edgeToChange(1),:)==n1);
			if num == 2 || num == 4
        		Tnew=[n3([1 2]) n2 n1;
              		  n3([2 3]) n2 n1;
              		  n3([3 1]) n2 n1];
    		else
        		Tnew=[n3([1 2]) n1 n2;
              		  n3([2 3]) n1 n2;
              		  n3([3 1]) n1 n2];       
			end
			
		    if CheckSkinnyTriangles(Ys(edgeToChange(1),:),Ys(edgeToChange(2),:),Face.Centre)
        		continue
    		end
			
			ghostNodes = ismember(Tnew,Geo.XgID);
    		ghostNodes = all(ghostNodes,2);
			if any(ghostNodes)
        		fprintf('=>> Flips 2-2 are not allowed for now\n');
        		return
			end
			% TODO FIXME, CheckConvexityCondition check to add
			Geo_backup = Geo;
			Geo_n_backup = Geo_n;
			fprintf('=>> 23 Flip.\n');
			% TODO FIXME IMPORTANT. X's are not updated in this current 
			% version, and so Ynew is slightly different...
        	Ynew=PerformFlip23(Ys(edgeToChange,:),Geo,n3);
        	Ynew(ghostNodes,:)=[];
			% ========== YNEW TNEW THE SAME UP TO HERE =============    
			targetTets = Geo.Cells(c).T(edgeToChange,:);

			% TODO FIXME As in Function removeFaceinRemodelling. 
			% Should probably include it there at some point...
			% TODO FIXME, is it necessary to make a full call to the object
			% or by variable renaming is enough ??

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
			
            if length(Ynew) ==3
                fprintf('Vertices number %i %i -> were replaced by -> %i %i %i.\n',edgeToChange(1),edgeToChange(2),length(Geo.Cells(c).Y)+1:length(Geo.Cells(c).Y)+size(Ynew,1));
            elseif length(Ynew) ==2
                fprintf('Vertices number %i %i -> were replaced by -> %i %i.\n',edgeToChange(1),edgeToChange(2),length(Geo.Cells(c).Y)+1:length(Geo.Cells(c).Y)+size(Ynew,1));
            end 

            % TODO FIXME, this can probablye done with only the 2
            % implicated cells, and then recalculate global Ids after all
            % flips are performed ???
%             PostProcessingVTK(Geo, Set, -1)
			[Geo, flag]= Rebuild(Geo, Set);
            if flag
                Geo = Geo_backup;
                Geo_n = Geo_n_backup;
                fprintf("=>> Flip23 is is not compatible rejected !! \n");
                continue
            end
			Geo_n = Rebuild(Geo_n, Set);

% 			PostProcessingVTK(Geo, Set, -2)
	        Geo = BuildGlobalIds(Geo);
			Geo_n = BuildGlobalIds(Geo_n);

			if CheckConvexityCondition(Tnew, Geo_backup.Cells(c).T, Geo)
            	Geo = Geo_backup;
				Geo_n= Geo_n_backup;
    			fprintf('=>> 23-Flip is not compatible rejected.\n');
				continue
			end
			% TODO FIXME, I don't like this. Possible way is to take only 
			% DOFs when computing K and g ?
			Geo.AssembleNodes = unique(Tnew);
			Dofs = GetDOFs(Geo, Set);

			% TODO FIXME THIS SHOULD ALSO BE CHANGED ACCORDINGLY!
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
				% NEW FACE CENTER DOF MISSING!
			end
            Dofs.Remodel = unique(remodelDofs, 'rows');
			newgIds(end+1:end+length(Dofs.Remodel)) = Dofs.Remodel;

            Geo.AssemblegIds  = Dofs.Remodel;
            Dofs.Remodel = 3.*(kron(Dofs.Remodel',[1 1 1])-1)+kron(ones(1,length(Dofs.Remodel')),[1 2 3]);
			Geo.Remodelling = true;
            [Geo, Set, DidNotConverge] = SolveRemodelingStep(Geo_n, Geo, Dofs, Set);
			Geo.Remodelling = false;
			if  DidNotConverge
            	Geo = Geo_backup;
				Geo_n= Geo_n_backup;
            	fprintf('=>> Local problem did not converge -> 23 Flip rejected !! \n');
            	return
			end
            return
            % TODO FIXME also update DOFS?
		end
	end
	% TODO FIXME, By now, let's force remodelling
end

%% ========================================================================
function Yn = PerformFlip23(Yo,Geo,n3)
	% the new vertices are place at a distance "Length of the line to b
	% removed" from the "center of the line to be removed" in the direction of
	% the barycenter of the corresponding tet  
	
	% Center and Length  of The line to be removed 
	len=norm(Yo(1,:)-Yo(2,:));
	center=sum(Yo,1)/2;
	
	% Stratagy Number 2
	% TODO FIXME bad, in previous code a sum was sufficient since we had
	% an array containing all x's
	center2 = 0;
	for ni = 1:length(n3)
		center2 = center2 + Geo.Cells(n3(ni)).X;
	end
	center2 = center2/3;
	
	direction = zeros(3, 3);
	n3(4) = n3(1);
	for numCoord = 1:3
    	node1 = (Geo.Cells(n3(numCoord)).X+Geo.Cells(n3(numCoord+1)).X)./2; 
    	%node1 = X(n3(1),:);
    	direction(numCoord, :) = node1-center2; 
    	direction(numCoord, :) = direction(numCoord, :)/norm(direction(numCoord, :));
	end
	
	Yn=[center+direction(1, :)*len;
    	center+direction(2, :)*len;
    	center+direction(3, :)*len];

end 
	
%% ========================================================================
function [s]=CheckSkinnyTriangles(Y1,Y2,cellCentre)
	YY12=norm(Y1-Y2);
	Y1=norm(Y1-cellCentre);
	Y2=norm(Y2-cellCentre);
	
	if YY12>2*Y1 || YY12>Y2*2
    	s=true;
	else
    	s=false;
	end
end 

