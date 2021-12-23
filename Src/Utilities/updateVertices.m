function [Geo] = updateVertices(Geo, Set, dy_reshaped)
	for c = 1:3
		Geo.Cells(c).Y = Geo.Cells(c).Y + dy_reshaped(Geo.Cells(c).YKIds,:);
		for f = 1:length(Geo.Cells(c).Faces)
			Geo.Cells(c).Faces(f).Centre = Geo.Cells(c).Faces(f).Centre + dy_reshaped(Geo.Cells(c).Faces(f).gID,:);
		end
	end
end

