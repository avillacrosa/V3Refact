function [g,K,EnergyNu]=KgViscosity(Geo, Set)
    K=(Set.nu/Set.dt).*eye(Geo.totalY*3);
	% TODO FIXME BAD!
    g=(Set.nu/Set.dt).*zeros(Geo.totalY*3, 1);
   
    EnergyNu=(1/2)*(g')*g/Set.nu;
end