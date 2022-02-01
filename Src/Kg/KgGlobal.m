function [gT,KT,ET] = KgGlobal(Geo_0, Geo_n, Geo, Set)
	%% Surface Energy
	[g.gs,K.Ks,E.ES]=KgSurfaceCellBasedAdhesion(Geo,Set);
	%% Volume Energy
    [g.gv,K.Kv,E.EV]=KgVolume(Geo,Set);	
	%% Viscous Energy
	[g.gf,K.Kf,E.EN]=KgViscosity(Geo_n,Geo,Set);
	%% Plane Elasticity
	if Set.InPlaneElasticity, [g.gt, K.Kt, E.EBulk]=KgBulk(Geo_0, Geo, Set); end
	%% Bending Energy
	% TODO
	%% Triangle Energy Barrier
	if Set.EnergyBarrier, [g.gB,K.KB,E.EB]=KgTriEnergyBarrier(Geo, Set); end
	%% Propulsion Forces
	% TODO
	%% Contractility
	% TODO
	%% Substrate
	% TODO
	%% Return
	gT = zeros(size(g.gs)); KT = zeros(size(K.Ks)); ET = 0;
	gnames = fieldnames(g); Knames = fieldnames(K); Enames = fieldnames(E);
	for f = 1:length(fieldnames(g))
		gT = gT + g.(gnames{f});
		KT = KT + K.(Knames{f});
		ET = ET + E.(Enames{f});
	end
end