function PostProcessingVTK(Geo, Set, Step)
	CreateVtkCell(Geo, Set, Step)
	CreateVtkFaceCentres(Geo, Set, Step)
    CreateVtkTet(Geo, Set, Step); 
end 