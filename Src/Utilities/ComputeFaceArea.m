function area = ComputeFaceArea(Face, Y)
	area = 0;
	for t = 1:length(Face.Edges)
		Tri = Face.Edges(t,:);
		YTri = [Y(Tri,:); Face.Centre];
		T=(1/2)*norm(cross(YTri(2,:)-YTri(1,:),YTri(1,:)-YTri(3,:)));
		area = area + T;
	end
end