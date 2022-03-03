function [g,K,E] = KgGlobal(Geo_0, Geo_n, Geo, Set)
	%% Surface Energy
	[gs,Ks,ES]=KgSurfaceCellBasedAdhesion(Geo,Set);
	%% Volume Energy
    [gv,Kv,EV]=KgVolume(Geo,Set);	
	%% Viscous Energy
	[gf,Kf,EN]=KgViscosity(Geo_n,Geo,Set);	
	%% Plane Elasticity
	% TODO
	%% Bending Energy
	% TODO

	g = gv+gf+gs;
	K = Kv+Kf+Ks;
	E = EV+ES+EN;
	%% Triangle Energy Barrier
    if Set.EnergyBarrier
	    [gB,KB,EB]=KgTriEnergyBarrier(Geo, Set);
        g = g + gB;
        K = K + KB;
        E = E + EB;
    end
	%% Propulsion Forces
	% TODO
	%% Contractility
	% TODO
	%% Substrate
	% TODO
	%% Return
%     if nargout > 1
% 	    fprintf("%.16f %.16f %.16f %.16f\n", norm(Ks), norm(Kv), norm(Kf), norm(KB));
% 	    fprintf("%.16f %.16f %.16f %.16f\n", norm(gs), norm(gv), norm(gf), norm(gB));
%     end
end