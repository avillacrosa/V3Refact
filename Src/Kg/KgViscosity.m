function [g,K,EnergyF]=KgViscosity(Geo_n, Geo, Set)
    K=(Set.nu/Set.dt).*eye((Geo.numF+Geo.numY)*3);
	% TODO FIXME placeholder...
	g = zeros((Geo.numF+Geo.numY)*3,1);
	dY = zeros(Geo.numF+Geo.numY,3);
	% TODO FIXME BAD!
	for c = 1:Geo.nCells
		if ~ismember(c,Geo.AssembleNodes)
        	continue
		end
		Cell = Geo.Cells(c);
		Cell_n = Geo_n.Cells(c);
		dY(Cell.globalIds,:) = (Cell.Y-Cell_n.Y);
		for f = 1:length(Cell.Faces)
			Face = Cell.Faces(f);
			Face_n = Cell_n.Faces(f);
			dY(Face.globalIds,:) = (Face.Centre-Face_n.Centre);
		end
	end
	g = (Set.nu/Set.dt).*reshape(dY', (Geo.numF+Geo.numY)*3, 1);
	EnergyF = (1/2)*(g')*g/Set.nu;

end