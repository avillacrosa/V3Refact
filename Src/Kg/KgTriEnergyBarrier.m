function [g,K,EnergyB]=KgTriEnergyBarrier(Geo,Set)
	% The residual g and Jacobian K of  Energy Barrier
	% Energy  WBexp = exp( Set.lambdaB*  ( 1 - Set.Beta*At/Set.BarrierTri0 )  );

	[g, K] = initializeKg(Geo, Set);
	EnergyB = 0;
	for c=1:Geo.nCells
		Cell = Geo.Cells(c);
		Ys = Cell.Y;
		lambdaB=Set.lambdaB;
		for f = 1:length(Cell.Faces)
            Face = Cell.Faces(f);
			Tris = Cell.Faces(f).Tris;
			for t = 1:length(Tris)
				fact=-((lambdaB*Set.Beta)/Set.BarrierTri0)* ... % * ...
				                    exp(lambdaB*(1-Set.Beta*Face.TrisArea(t)/Set.BarrierTri0));
				fact2=fact*-((lambdaB*Set.Beta)/Set.BarrierTri0);
				y1 = Ys(Tris(t,1),:);
				y2 = Ys(Tris(t,2),:);
				if length(Tris) == 3
					y3 = Ys(Tris(t+1,2),:);
					n3 = Cell.globalIds(Tris(t+1,2));
				else
					y3 = Cell.Faces(f).Centre;
					n3 = Cell.Faces(f).globalIds;
				end
                [gs,Ks,Kss]=gKSArea(y1,y2,y3);
				nY = [Cell.globalIds(Tris(t,:))', n3];
	        	g=Assembleg(g,gs*fact,nY);	
				Ks=(gs)*(gs')*fact2+Ks*fact+Kss*fact;
				K= AssembleK(K,Ks,nY);
				EnergyB=EnergyB+ exp(lambdaB*(1-Set.Beta*Face.TrisArea(t)/Set.BarrierTri0));
				if length(Tris) == 3
					break
				end
			end
		end
	end
end
