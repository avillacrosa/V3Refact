function Geo = BuildGlobalIds(Geo)
	gIdsTot = 1;
	for ci = 1:Geo.nCells
		Cell = Geo.Cells(ci);
		gIds = zeros(length(Cell.Y), 1);
		% TODO FIXME, maybe we could iterate over neighbors only?
		for cj = 1:ci-1 
			ij = [ci, cj];
			CellJ = Geo.Cells(cj);
			face_ids_i	= sum(ismember(Cell.T,ij),2)==2;
			face_ids_j	= sum(ismember(CellJ.T,ij),2)==2;
			gIds(face_ids_i) = CellJ.globalIds(face_ids_j);
		end
		nz = length(gIds(gIds==0));
		gIds(gIds==0) = gIdsTot:(gIdsTot+nz-1);
		Geo.Cells(ci).globalIds = gIds;
		globalIdsf = gIds + Geo.numV;%?
		for f = 1:length(Geo.Cells(ci).Faces)
			Geo.Cells(ci).Faces(f).globalIds = globalIdsf(f);
		end
		gIdsTot = gIdsTot + nz;
	end
end