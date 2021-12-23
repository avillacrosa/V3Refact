function [g,K,E] = KgGlobal(Geo, Geo_n, Set)
	% The residual g and Jacobian K of all energies
	%% Calculate basic information
	
	% TODO FIXME, I think this should go out of here. Either after a step
	% !!!!!!!!!!!!!!!!!!!! DEBATE DIFFERENCE BETWEEN GEO_N AND GEO!!!!!!!!!
	% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	% converged or before entering KgGlobal (last option preferred I think)
	[Geo] = ComputeCellVolume(Geo, Set);
	[Geo] = ComputeFaceArea(Geo,Set);
	% [Cell] = Cell.computeEdgeLengths(Y);
	% [Cell] = Cell.computeEdgeLocation(Y);

	%% Surface Energy
	[gs,Ks,ES]=KgSurfaceCellBasedAdhesion(Geo,Set);
	%% Volume Energy
    [gv,Kv,EV]=KgVolume(Geo,Set);	
	%% Viscous Energy
	[gf,Kf,EN]=KgViscosity(Geo,Geo_n,Set);	
	%% Plane Elasticity
	% TODO
	%% Bending Energy
	% TODO
	%% Triangle Energy Barrier
% 	[gB,KB,EB]=KgTriEnergyBarrier(Geo, Set);
	%% Propulsion Forces
	% TODO
	%% Contractility
	% TODO
	%% Substrate
	% TODO
	%% Return
	g = gs + gv + gf;
	K = Ks + Kv + Kf;
	E = ES + EV + EN;
end