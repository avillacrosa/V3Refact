function [Geo_n, Geo, Dofs, Set]=Remodeling(Geo_n, Geo, Dofs, Set)

	newgIds = [];

	[Geo_n, Geo, Dofs, Set, newgIds] = Flip44(Geo_n, Geo, Dofs, Set, newgIds);

	[Geo_n, Geo, Dofs, Set, newgIds] = Flip32(Geo_n, Geo, Dofs, Set, newgIds);

	[Geo_n, Geo, Dofs, Set, newgIds] = Flip23(Geo_n, Geo, Dofs, Set, newgIds);

end

