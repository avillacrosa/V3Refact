function Face = BuildFace(ci, cj, Cell, CellJ, XgID, Set)
	
	ij			= [ci, cj];
	face_ids	= sum(ismember(Cell.T,ij),2)==2; 

	Face				= struct();
	Face.ij				= ij;
	Face.globalIds		= -1; % ???
	Face.InterfaceType	= BuildInterfaceType(ij, XgID);
	Face.Centre			= BuildFaceCentre(ij, Cell.X, Cell.Y(face_ids,:), Set.f);
	Face.Edges			= BuildEdges(Cell.T, face_ids, Face.Centre, Cell.X, Cell.Y);
	Face.Area			= ComputeFaceArea(Face, Cell.Y);
	Face.Area0			= 0; % TODO FIXME how to deal with this ???
end