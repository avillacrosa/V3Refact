function [g,K,E] = KgGlobal(Geo_n, Geo, Set)
	% The residual g and Jacobian K of all energies
	%% Calculate basic information
	
	% TODO FIXME, I think this should go out of here. Either after a step
	% !!!!!!!!!!!!!!!!!!!! DEBATE DIFFERENCE BETWEEN GEO_N AND GEO!!!!!!!!!
	% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	% converged or before entering KgGlobal (last option preferred I think)
    for c = 1:Geo.nCells
        Cell = Geo.Cells(c);
        for f = 1:length(Cell.Faces)
            Face = Geo.Cells(c).Faces(f);
	        [Geo.Cells(c).Faces(f).Area, Geo.Cells(c).Faces(f).TrisArea] = ComputeFaceArea(Face, Cell.Y);
        end
        Geo.Cells(c).Vol = ComputeCellVolume(Cell);
    end
	% [Cell] = Cell.computeEdgeLengths(Y);
	% [Cell] = Cell.computeEdgeLocation(Y);

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
	%% Triangle Energy Barrier
	[gB,KB,EB]=KgTriEnergyBarrier(Geo, Set);
	%% Propulsion Forces
	% TODO
	%% Contractility
	% TODO
	%% Substrate
	% TODO
	%% Return
	g = gs + gv + gf + gB;
	K = Ks + Kv + Kf + KB;
	E = ES + EV + EN + EB;
end