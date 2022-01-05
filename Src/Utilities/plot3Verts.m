function plot3Verts(Geo)
	for c = 1:Geo.nCells
		Ys = Geo.Cells(c).Y;
		plot3(Ys(:,1), Ys(:,2), Ys(:,3), 'o')
		hold on
	end
end