function [Geo] = flip23(Geo, Set)
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

	for c = 1:3
		Ys = Geo.Cells(c).Y;
		Ts = Geo.Cells(c).T;
		% WHOLE REMODELLING WILL BE INSIDE HERE
		for f = 1:length(Geo.Cells(c).Faces)
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
			[~,idVertex]=max(nrgs);
			edgeToChange = Face.Tris(idVertex,:);
		    n3=Ts(edgeToChange(1),  ismember(Ts(edgeToChange(1),:), Ts(edgeToChange(2),:)));
    		n1=Ts(edgeToChange(1), ~ismember(Ts(edgeToChange(1),:),n3) );
    		n2=Ts(edgeToChange(2), ~ismember(Ts(edgeToChange(2),:),n3) );
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
			ghostNodes = ismember(Tnew,Geo.XgID);
    		ghostNodes = all(ghostNodes,2);
			if any(ghostNodes)
        		fprintf('=>> Flips 2-2 are not allowed for now\n');
        		return
			end
			% TODO FIXME, CheckConvexityCondition check to add
			fprintf('=>> 23 Flip.\n');
        	Ynew=PerformFlip23(Ys(edgeToChange,:),Geo,n3);
        	Ynew(ghostNodes,:)=[];
			
			targetVerts = Geo.Cells(c).Y(edgeToChange,:);
			CellJ = Geo.Cells(Face.ij(2));
			jrem = find(sum(ismember(CellJ.Y,targetVerts),2)==3);
			% TODO FIXME As in Function removeFaceinRemodelling. 
			% Should probably include it there at some point...
			Geo.Cells(c).Y(edgeToChange,:) = [];
			Geo.Cells(c).T(edgeToChange,:) = [];

			% TODO FIXME, is it necessary to make a full call to the object
			% or by variable renaming is enough ??
			Geo.Cells(Face.ij(2)).Y(jrem,:) = [];
			Geo.Cells(Face.ij(2)).T(jrem,:) = [];
			
			% TODO FIXME as in Function addNewVerticesInRemodelling
			% Should probably include it there at some point...
			Geo.Cells(c).T(end+1:end+size(Tnew,1),:) = Tnew;
			Geo.Cells(c).Y(end+1:end+size(Ynew,1),:) = Ynew;
			Geo.Cells(Face.ij(2)).T(end+1:end+size(Tnew,1),:) = Tnew;
			Geo.Cells(Face.ij(2)).Y(end+1:end+size(Ynew,1),:) = Ynew;

			% TODO FIXME, RebuildCells, pretty sure this can be done in a 
			% cleaner and smarter way.
			Geo	= BuildFaces(Geo, Set);
			Geo = ComputeCellVolume(Geo, Set); 
			Geo = ComputeFaceArea(Geo,Set);
			for cc = 1:length(Geo.Cells)
				Geo.Cells(cc).Vol0 = Geo.Cells(cc).Vol;
				totA = 0;
				for ff = 1:length(Geo.Cells(cc).Faces)
					Geo.Cells(cc).Faces(ff).Area0 = Geo.Cells(cc).Faces(f).Area;
					totA = totA + Geo.Cells(cc).Faces(ff).Area0;
				end
				Geo.Cells(cc).Area = totA;
				Geo.Cells(cc).Area0 = totA;
			end
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

