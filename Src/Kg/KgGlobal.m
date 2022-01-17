function [g,K,Geo,E] = KgGlobal(Geo_n, Geo, Set)
	% The residual g and Jacobian K of all energies
	%% Calculate basic information
	
	% TODO FIXME, I think this should go out of here. Either after a step
	% converged or before entering KgGlobal (last option preferred I think)
    for c = 1:Geo.nCells
        for f = 1:length(Geo.Cells(c).Faces)
	        [Geo.Cells(c).Faces(f).Area, Geo.Cells(c).Faces(f).TrisArea] = ComputeFaceArea(Geo.Cells(c).Faces(f), Geo.Cells(c).Y);
% 			Geo.Cells(c).Faces(f).Area, Geo.Cells(c).Faces(f).TrisArea
        end
        Geo.Cells(c).Vol = ComputeCellVolume(Geo.Cells(c));
%         fprintf("%.8f ", Geo.Cells(c).Vol)
    end
%     fprintf("\n")
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