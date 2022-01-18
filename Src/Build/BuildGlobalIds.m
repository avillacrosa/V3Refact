% TODO FIXME, this probably can and should be better...
function Geo = BuildGlobalIds(Geo)
	gIdsTot = 1;
    gIdsTotf = 1;
    for ci = 1:Geo.nCells
		Cell = Geo.Cells(ci);
		gIds  = zeros(length(Cell.Y), 1);
        gIdsf = zeros(length(Cell.Faces), 1);
		for cj = 1:ci-1 
			ij = [ci, cj];
			CellJ = Geo.Cells(cj);
			face_ids_i	= sum(ismember(Cell.T,ij),2)==2;
			face_ids_j	= sum(ismember(CellJ.T,ij),2)==2;
			gIds(face_ids_i) = CellJ.globalIds(face_ids_j);

            for f = 1:length(Cell.Faces)
                Face = Cell.Faces(f);
                if sum(ismember(Face.ij, ij),2) == 2
                    for f2 = 1:length(CellJ.Faces)
                        FaceJ = CellJ.Faces(f2);
                        if sum(ismember(FaceJ.ij, ij),2) == 2
                            gIdsf(f) = FaceJ.globalIds;
                        end
                    end
                end
            end
		end
		nz = length(gIds(gIds==0));
		gIds(gIds==0) = gIdsTot:(gIdsTot+nz-1);
		Geo.Cells(ci).globalIds = gIds;

        nzf = length(gIdsf(gIdsf==0));
		gIdsf(gIdsf==0) = gIdsTotf:(gIdsTotf+nzf-1);
        for f = 1:length(Cell.Faces)
                Geo.Cells(ci).Faces(f).globalIds = gIdsf(f);
        end
        
		gIdsTot = gIdsTot + nz;
        gIdsTotf = gIdsTotf + nzf;
    end
    Geo.numY = gIdsTot - 1;
    for c = 1:Geo.nCells
        for f = 1:length(Geo.Cells(c).Faces)
            Geo.Cells(c).Faces(f).globalIds = Geo.Cells(c).Faces(f).globalIds + Geo.numY;
        end
    end
    Geo.numF = gIdsTotf - 1;
end