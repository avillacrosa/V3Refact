function Geo = Rebuild(Geo, Set)
	for cc = 1:Geo.nCells
        Cell = Geo.Cells(cc);
        Neigh_nodes = unique(Geo.Cells(cc).T);
        Neigh_nodes(Neigh_nodes==cc)=[];
		for j  = 1:length(Neigh_nodes)
	        cj    = Neigh_nodes(j);
            ij			= [cc, cj];
            face_ids	= sum(ismember(Cell.T,ij),2)==2;
			if j > length(Geo.Cells(cc).Faces)
				Geo.Cells(cc).Faces(end+1) = BuildFace(cc, cj, Geo.Cells(cc), Geo.Cells(j), Geo.XgID, Set);
				Geo.Cells(cc).Faces(end).Centre=sum(Geo.Cells(cc).Y(face_ids,:),1)/length(face_ids);
			else
        		Geo.Cells(cc).Faces(j).Tris	= BuildEdges(Geo.Cells(cc).T, face_ids, Geo.Cells(cc).Faces(j).Centre, Geo.Cells(cc).X, Geo.Cells(cc).Y);
				[Geo.Cells(cc).Faces(j).Area, Geo.Cells(cc).Faces(j).TrisArea]  = ComputeFaceArea(Geo.Cells(cc).Faces(j), Geo.Cells(cc).Y);
			end
		end
		Geo.Cells(cc).Area  = ComputeCellArea(Geo.Cells(cc));
        Geo.Cells(cc).Vol   = ComputeCellVolume(Geo.Cells(cc));
	end
end