function [Geo] = updateVertices(Geo, Set, dy_reshaped)
    for c = 1:Geo.nCells
        dY = dy_reshaped(Geo.Cells(c).globalIds,:);
        Geo.Cells(c).Y = Geo.Cells(c).Y + dY;
        for f = 1:length(Geo.Cells(c).Faces)
			Geo.Cells(c).Faces(f).Centre = Geo.Cells(c).Faces(f).Centre + dy_reshaped(Geo.Cells(c).Faces(f).globalIds,:);
        end
    end
end

