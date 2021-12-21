function Geo = ComputeFaceArea(Geo, Set)
	% TODO FIXME HARDCODE
	for c = 1:3
		Cell = Geo.Cells(c);
		Ys   = Geo.Cells(c).Y;
		for f = 1:length(Cell.Faces)
			Face = Cell.Faces(f);
			area = 0;
			for t = 1:length(Face.Tris)
				Tri = Face.Tris(t,:);
				YTri = [Ys(Tri,:); Face.Centre];
				T=(1/2)*norm(cross(YTri(2,:)-YTri(1,:),YTri(1,:)-YTri(3,:)));
				area = area + T;
			end
			Geo.Cells(c).Faces(f).Area = area;
		end
	end
end