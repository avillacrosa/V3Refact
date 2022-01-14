function [Geo_n, Geo, Dofs, Set]=Remodeling(Geo_n, Geo, Dofs, Set)

newgIds = [];

[Geo_n, Geo, Dofs, Set, newgIds] = flip44(Geo_n, Geo, Dofs, Set, newgIds);

[Geo_n, Geo, Dofs, Set, newgIds] = flip32(Geo_n, Geo, Dofs, Set, newgIds);

[Geo_n, Geo, Dofs, Set, newgIds] = flip23(Geo_n, Geo, Dofs, Set, newgIds);

end

