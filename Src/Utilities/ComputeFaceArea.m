function [area, trisArea] = ComputeFaceArea(Face, Y)
	area = 0;
    trisArea = zeros(length(Face.Tris),1);
	for t = 1:length(Face.Tris)
		Tri = Face.Tris(t,:);
		YTri = [Y(Tri,:); Face.Centre];
		T=(1/2)*norm(cross(YTri(2,:)-YTri(1,:),YTri(1,:)-YTri(3,:)));
        trisArea(t) = T;
		area = area + T;
	end
end