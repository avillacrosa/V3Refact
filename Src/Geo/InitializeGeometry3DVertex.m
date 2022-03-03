function [Geo, Set] = InitializeGeometry3DVertex(Geo,Set)
	%% Build nodal mesh 
	X = BuildTopo();
	Geo.nCells = length(X);

	%% Centre Nodal position at (0,0)
	X(:,1)=X(:,1)-mean(X(:,1));
	X(:,2)=X(:,2)-mean(X(:,2));
	X(:,3)=X(:,3)-mean(X(:,3));

	[Geo.XgID,X]=SeedWithBoundingBox(X,Set.s);

	Twg=delaunay(X);
	Twg(all(ismember(Twg,Geo.XgID),2),:)=[];
	% After removing ghost tetrahedras, some nodes become disconnected, 
	% that is, not a part of any tetrahedra. Therefore, they should be 
	% removed from X
	X    = X(unique(Twg),:);

	conv = zeros(max(max(Twg)),1);

	conv(unique(Twg)) = 1:size(X);
	Twg = conv(Twg);

	% TODO FIXME This does not seem optimal...
	CellFields = ["X", "T", "Y", "Faces", "Vol", "Vol0", "Area", "Area0", "globalIds", "cglobalIds"];
	FaceFields = ["ij", "Centre", "Tris", "globalIds", "InterfaceType", "Area", "Area0", "TrisArea"];

	Geo.Cells = BuildStructArray(length(X), CellFields);
	for c = 1:length(X)
		Geo.Cells(c).X     = X(c,:);
		Geo.Cells(c).T     = Twg(any(ismember(Twg,c),2),:);
	end

	for c = 1:Geo.nCells
		Geo.Cells(c).Y     = BuildYFromX(Geo.Cells(c), Geo.Cells, ...
													Geo.XgID, Set);
	end

	for c = 1:Geo.nCells
		Neigh_nodes = unique(Geo.Cells(c).T);
		Neigh_nodes(Neigh_nodes==c)=[];
		Geo.Cells(c).Faces = BuildStructArray(length(Neigh_nodes), FaceFields);
        for j  = 1:length(Neigh_nodes)
			cj    = Neigh_nodes(j);
			CellJ = Geo.Cells(cj);
			Geo.Cells(c).Faces(j) = BuildFace(c, cj, Geo.Cells(c), CellJ, Geo.XgID, Set);
            Geo.Cells(c).Faces(j).Area0 = Geo.Cells(c).Faces(j).Area;
        end
        Geo.Cells(c).Area  = ComputeCellArea(Geo.Cells(c));
        Geo.Cells(c).Area0 = Geo.Cells(c).Area;
        Geo.Cells(c).Vol   = ComputeCellVolume(Geo.Cells(c));
        Geo.Cells(c).Vol0  = Geo.Cells(c).Vol;
	end
	Geo = BuildGlobalIds(Geo);
	% TODO FIXME bad
	Geo.AssembleNodes = 1:Geo.nCells;
    Set.BarrierTri0=realmax; 
    for c = 1:Geo.nCells
        Cell = Geo.Cells(c);
        for f = 1:length(Geo.Cells(c).Faces)
            Face = Cell.Faces(f);
            Set.BarrierTri0=min([Face.TrisArea; Set.BarrierTri0]);
        end
    end
    Set.BarrierTri0=Set.BarrierTri0/10;
end