function [g,K,EnergyBulk]=KgBulk(Geo_0, Geo, Set)

	[g, K] = initializeKg(Geo, Set);
	
	EnergyBulk=0;
	errorInverted = [];

	for c=1:Geo.nCells
		if Geo.Remodelling
			if ~ismember(c,Geo.AssembleNodes)
        		continue
			end
		end
		ge=zeros(size(g, 1), 1);
		Ys  = Geo.Cells(c).Y;
		Ys_0 = Geo_0.Cells(c).Y;
		for f=1:length(Geo.Cells(c).Faces)
			Tris = Geo.Cells(c).Faces(f).Tris;
			for t=1:length(Tris)
				y1   = Ys(Tris(t,1),:);
				y1_0 = Ys_0(Tris(t,1),:);
				y2   = Ys(Tris(t,2),:);
				y2_0 = Ys_0(Tris(t,2),:);
				if length(Tris) == 3
					y3 = Ys(Tris(t+1,2),:);
					y3_0 = Ys_0(Tris(t+1,2),:);
					n3 = Geo.Cells(c).globalIds(Tris(t+1,2));
				else
					y3 = Geo.Cells(c).Faces(f).Centre;
					y3_0 = Geo_0.Cells(c).Faces(f).Centre;
					n3 = Geo.Cells(c).Faces(f).globalIds;
				end
				currentTet     = [y1; y2; y3; Geo.Cells(c).X];
				currentTet0    = [y1_0; y2_0; y3_0; Geo_0.Cells(c).X];
				currentTet_ids = [Geo.Cells(c).globalIds(Tris(t,:))', n3, Geo.Cells(c).cglobalIds];
				if Geo.Remodelling
					if ~any(ismember(currentTet_ids,Geo.AssemblegIds))
                        if length(Tris) == 3
                            break
                        else
                		    continue
                        end
					end
				end
				try
					[gB, KB, Energye] = KgBulkElem(currentTet, currentTet0, Set.mu_bulk, Set.lambda_bulk);
					EnergyBulk=EnergyBulk+Energye;
					ge=Assembleg(ge,gB,currentTet_ids);
					K = AssembleK(K,KB,currentTet_ids);
				catch ME
					if (strcmp(ME.identifier,'KgBulkElem:invertedTetrahedralElement'))
						errorInverted = [errorInverted; currentTet_ids];
					else
						ME.rethrow();
					end
				end
				if length(Tris) == 3
					break
				end
			end
		end
		g=g+ge;
	end
	if isempty(errorInverted) == 0
		warning('Inverted Tetrahedral Element [%s]', sprintf('%d;', errorInverted'));
	end
end