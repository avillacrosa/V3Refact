function [g,K,EnergyS]=KgSurfaceCellBasedAdhesion(Geo, Set)
	[g, K] = initializeKg(Geo, Set);
	EnergyS = 0;
	% TODO FIXME BAD!
	Set.lambdaS1 = 1;
	Set.lambdaS2 = 0.8;
	for c = 1:3
		Cell  = Geo.Cells(c);
		Ys    = Geo.Cells(c).Y;
		ge	  = zeros(size(g, 1), 1);
		fact0 = 0;
		for f=1:length(Cell.Faces)
			face = Cell.Faces(f);
			if c == 2
				fprintf("%f %f %f \n", face.Centre);
			end
			if face.InterfaceType==0
				% TODO FIXME ADAPT THIS
				Lambda=Set.lambdaS1*1;
			elseif face.InterfaceType==1
				% TODO FIXME ADAPT THIS
				Lambda=Set.lambdaS2*1;
			elseif face.InterfaceType==2
				% TODO FIXME ADAPT THIS
				Lambda=Set.lambdaS3*1;
			end
			fact0=fact0+Lambda*face.Area;
		end
		fact=fact0/Cell.Area0^2;
		test = [];
		for f=1:length(Cell.Faces)
			face = Cell.Faces(f);
			Tris=Cell.Faces(f).Tris;
			if face.InterfaceType==0
				% TODO FIXME ADAPT THIS
				Lambda=Set.lambdaS1*1;
			elseif face.InterfaceType==1
				% TODO FIXME ADAPT THIS				
				Lambda=Set.lambdaS2*1;
			elseif face.InterfaceType==2
				% TODO FIXME ADAPT THIS
				Lambda=Set.lambdaS3*1;
			end
			for t = 1:length(Tris)
				y1 = Ys(Tris(t,1),:);
				y2 = Ys(Tris(t,2),:);
				% TODO FIXME, y2 and y1 order might be relevant because of
				% the cross product inside gKSArea
				[gs,Ks,Kss]=gKSArea(y1,y2,face.Centre);
				gs=Lambda*gs;
% 				if(c==2)
% 					face.Centre
% 					fprintf("SUM %e %d %d %d \n",sum(gs), f, t, c);
% 					[y1;y2;face.Centre]
% 				end
				nY = [Cell.YKIds(Tris(t,:))', face.gID];
            	ge=Assembleg(ge,gs,nY);
				Ks=fact*Lambda*(Ks+Kss);
				K = AssembleK(K,Ks,nY);
			end
% 			fprintf("%d %e\n", f, sum(ge));
		end
		g=g+ge*fact;
		K=K+(ge)*(ge')/(Cell.Area0^2);
    	EnergyS=EnergyS+ (1/2)*fact0*fact;
	end
end
