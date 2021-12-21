function [g,K,E] = KgGlobal(Geo, Set)
	% The residual g and Jacobian K of all energies
	%% Calculate basic information

	% TODO FIXME, I think this should go out of here. Either after a step
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
	[gn,Kn,EN]=KgViscosity(Geo,Set);	
	%% Plane Elasticity
	% TODO
	%% Bending Energy
	% TODO
	%% Triangle Energy Barrier
	[gB,KB,EB]=KgTriEnergyBarrier(Geo, Set);
	%% Propulsion Forces
	% TODO
	%% Contractility
	% TODO
	%% Substrate
	% TODO
	%% Return
	g = gs + gv + gn + gB;
	K = Ks + Kv + Kn + KB;
	E = ES + EV + EN + EB;
end