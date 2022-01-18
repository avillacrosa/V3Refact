function Geo = UpdateFacesArea(Geo)
	for c = 1:Geo.nCells
    	for f = 1:length(Geo.Cells(c).Faces)
        	[Geo.Cells(c).Faces(f).Area, Geo.Cells(c).Faces(f).TrisArea] = ComputeFaceArea(Geo.Cells(c).Faces(f), Geo.Cells(c).Y);
    	end
    	Geo.Cells(c).Vol = ComputeCellVolume(Geo.Cells(c));
	end
end