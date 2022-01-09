function Geo = Rebuild(Geo, Set)
	for cc = 1:Geo.nCells
        Cell = Geo.Cells(cc);
        Neigh_nodes = unique(Geo.Cells(cc).T);
        Neigh_nodes(Neigh_nodes==cc)=[];
		for j  = 1:length(Neigh_nodes)
	        cj    = Neigh_nodes(j);
            ij			= [cc, cj];
            face_ids	= sum(ismember(Cell.T,ij),2)==2; 
            if cc == 2 && j == 30
                1 == 1;
            end
            if isstring(Geo.Cells(cc).Faces(j).Centre)
                Geo.Cells(cc).Faces(j).Centre = BuildFaceCentre(ij, Cell.X, Cell.Y(face_ids,:), Set.f);
                Geo.Cells(cc).Faces(j).Centre = BuildFaceCentre(ij, Cell.X, Cell.Y(face_ids,:), Set.f);
            end
            if size(Cell.T(face_ids,:),1)==3
                
                fprintf("TRIIIIIIIIIIII");
                Geo.Cells(cc).Faces(j).Centre = "empty";
            end
            Geo.Cells(cc).Faces(j).Tris	= BuildEdges(Cell.T, face_ids, Cell.Faces(j).Centre, Cell.X, Cell.Y);
			[Geo.Cells(cc).Faces(j).Area, Geo.Cells(cc).Faces(j).TrisArea]  = ComputeFaceArea(Geo.Cells(cc).Faces(j), Cell.Y);
		end
		Geo.Cells(cc).Area  = ComputeCellArea(Geo.Cells(cc));
        Geo.Cells(cc).Vol   = ComputeCellVolume(Geo.Cells(cc));
	end
end