function [g,K,EnergyB]=KgTriEnergyBarrier(Geo,Set)
	% The residual g and Jacobian K of  Energy Barrier
	% Energy  WBexp = exp( Set.lambdaB*  ( 1 - Set.Beta*At/Set.BarrierTri0 )  );

	[g, K] = initializeKg(Geo, Set);
	EnergyB = 0;
	for c=1:3
		Cell = Geo.Cells(c);
		Ys = Cell.Y;
		lambdaB=Set.lambdaB;
		for f = 1:length(Cell.Faces)
			Tris = Cell.Faces(f).Tris;
			for t = 1:length(Tris)
				fact=-((lambdaB*Set.Beta)/Set.BarrierTri0);% * ...
				% TODO FIXME, killed :(
% 					exp(lambdaB*(1-Set.Beta*Cell.SAreaTri{i}(t)/Set.BarrierTri0));
				fact2=fact*-((lambdaB*Set.Beta)/Set.BarrierTri0);
				y1 = Ys(Tris(t,1),:);
				y2 = Ys(Tris(t,2),:);
				nY = [Tris(t,:), Cell.Faces(f).gID];
				[gs,Ks,Kss]=gKSArea(y1,y2,Cell.Faces(f).Centre);
	        	g=Assembleg(g,gs*fact,nY);	
				Ks=(gs)*(gs')*fact2+Ks*fact+Kss*fact;
				K= AssembleK(K,Ks,nY);
				% TODO FIXME, killed :(				
% 				EnergyB=EnergyB+ exp(lambdaB*(1-Set.Beta*Cell.SAreaTri{i}(t)/Set.BarrierTri0));
			end
		end
	end
end
