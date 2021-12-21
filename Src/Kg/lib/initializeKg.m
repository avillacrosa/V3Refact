function [g, K] = initializeKg(Geo, Set)
	total1 = 0; total2 = 0;
	for c = 1:3
		total1 = total1 + length(Geo.Cells(c).Y);
		% 		total2 = total2 + length(unique(Geo.Cells(c).Faces));
	end
	dimg=(total)*3;

	g = zeros(dimg, 1);
	K = zeros(dimg, dimg);
end

