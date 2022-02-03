function [Ys] = allY(Geo)
	Ys = [];
	for c = 1:length(Geo.Cells)
		Ys = [Ys;Geo.Cells(c).Y];
	end
	Ys = Ys{1};
end