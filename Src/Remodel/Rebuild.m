function Geo = Rebuild(Geo)
	for cc = 1:Geo.nCells
        Cell = Geo.Cells(cc);
        Neigh_nodes = unique(Geo.Cells(cc).T);
        Neigh_nodes(Neigh_nodes==cc)=[];
		for j  = 1:length(Neigh_nodes)
	        cj    = Neigh_nodes(j);
            ij			= [cc, cj];
            face_ids	= sum(ismember(Cell.T,ij),2)==2; 
            Geo.Cells(cc).Faces(j).Tris	= BuildEdges(Cell.T, face_ids, Cell.Faces(j).Centre, Cell.X, Cell.Y);
			[Geo.Cells(cc).Faces(j).Area, Geo.Cells(cc).Faces(j).TrisArea]  = ComputeFaceArea(Geo.Cells(cc).Faces(j), Cell.Y);
		end
		Geo.Cells(cc).Area  = ComputeCellArea(Geo.Cells(cc));
        Geo.Cells(cc).Vol   = ComputeCellVolume(Geo.Cells(cc));
	end
end