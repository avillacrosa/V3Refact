function Geo = RemoveFaces(Face, Geo)
    oppfaceId = [];
    for f2 = 1:length(Geo.Cells(Face.ij(2)).Faces)
	    Faces2 = Geo.Cells(Face.ij(2)).Faces(f2);
	    if sum(ismember(Geo.Cells(c).Faces(f).ij, Faces2.ij))==2
		    oppfaceId = f2;
	    end
    end
    Geo.Cells(c).Faces(f) = [];
    if ~isempty(oppfaceId)
	    Geo.Cells(Face.ij(2)).Faces(oppfaceId) = [];
    end
end