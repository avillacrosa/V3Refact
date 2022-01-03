function v=ComputeCellVolume(Cell)
	v = 0;
    for f = 1:length(Cell.Faces)
		face = Cell.Faces(f);
		for t=1:length(face.Tris)
			y1 = Cell.Y(face.Tris(t,1),:);
			y2 = Cell.Y(face.Tris(t,2),:);
			Ytri = [y1; y2; face.Centre];
			v = v + det(Ytri)/6;
		end
    end
end 