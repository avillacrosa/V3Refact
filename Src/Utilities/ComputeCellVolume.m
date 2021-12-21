function [Geo]=ComputeCellVolume(Geo, Set)
	for c = 1:length(Geo.Cells)
		v = 0;
		Ys = Geo.Cells(c).Y;
		for f = 1:length(Geo.Cells(c).Faces)
			face = Geo.Cells(c).Faces(f);
			for t=1:length(face.Tris)
				y1 = Ys(face.Tris(1),:);
				y2 = Ys(face.Tris(2),:);
				v = v + det([y1; y2; face.Centre])/6;
			end
		end
		Geo.Cells(c).Vol = v;
		% TODO FIXME BAD
		Geo.Cells(c).Vol0 = v;
	end
end 