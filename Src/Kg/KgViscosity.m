function [g,K,EnergyNu]=KgViscosity(Geo, Set)
    K=(Set.nu/Set.dt).*eye((Geo.numF+Geo.numY)*3);
	g = zeros((Geo.numF+Geo.numY)*3,1);
	% TODO FIXME BAD!
	for c = 1:3
		Cell = Geo.Cells(c);
		% TODO FIXME Bad. Should define Y0 at some point
		g(Cell.YKIds) = (Set.nu/Set.dt).*(Cell.Y-Cell.Y);
		for f = 1:length(Cell.Faces)
			Face = Cell.Faces(f);
			% TODO FIXME Bad. Should define Centre0 at some point
			g(f.gID) = (Set.nu/Set.dt).*(Face.Centre-Face.Centre);
		end
	end
    EnergyNu=(1/2)*(g')*g/Set.nu;
end