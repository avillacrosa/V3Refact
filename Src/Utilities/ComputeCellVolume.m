function [Geo]=ComputeCellVolume(Geo, Set)
	for c = 1:3
		v = 0;
		Ys = Geo.Cells(c).Y;
		for f = 1:length(Geo.Cells(c).Faces)
			face = Geo.Cells(c).Faces(f);
			for t=1:length(face.Tris)
				y1 = Ys(face.Tris(t,1),:);
				y2 = Ys(face.Tris(t,2),:);
				Ytri = [y1; y2; face.Centre];
				v = v + det(Ytri)/6;
			end
		end
		Geo.Cells(c).Vol = v;
	end
end 