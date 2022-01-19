function [Geo, Dofs] = ApplyBoundaryCondition(t, Geo, Dofs, Set)
%APPLYBOUNDARYCONDITION Summary of this function goes here
%   Detailed explanation goes here

    if Set.BC==1 && t<=Set.TStopBC && t>=Set.TStartBC && Set.ApplyBC
        % TODO FIXME, dimP, unused, but it should be...
        [dimP, numP] = ind2sub([3, Geo.numY+Geo.numF+Geo.nCells],Dofs.FixP);
        for c = 1:Geo.nCells
            prescYi  = ismember(Geo.Cells(c).globalIds, numP);
            Geo.Cells(c).Y(prescYi,2) = Geo.Cells(c).Y(prescYi,2) + Set.dx/((Set.TStopBC-Set.TStartBC)/Set.dt);
            
            % TODO FIXME, I think this is proof that face global ids
            % should be in the cell struct and not the face struct
            for gn = 1:length(numP)
                for f = 1:length(Geo.Cells(c).Faces)
                    Face = Geo.Cells(c).Faces(f);
                    if length(Face.Tris)==3
                        continue
                    end
                    if numP(gn)==Face.globalIds
                        Geo.Cells(c).Faces(f).Centre(2) = Geo.Cells(c).Faces(f).Centre(2) + Set.dx/((Set.TStopBC-Set.TStartBC)/Set.dt);
                    end
                end
            end
        end
        Dofs.Free(ismember(Dofs.Free,Dofs.FixP))=[];
        Dofs.Free(ismember(Dofs.Free,Dofs.FixC))=[];
	elseif Set.BC==2 && t<=Set.TStopBC && t>=Set.TStartBC && Set.ApplyBC
		% TODO FIXME, find a better way for this, as it is repeated in the 
		% GetDOFs function, but to extract it GetDOs should return a Set,
		% which does not seem great...
		maxY = Geo.Cells(1).Y(1,2);
		for c = 1:Geo.nCells
			hit = find(Geo.Cells(c).Y(:,2)>maxY);
			if ~isempty(hit)
				maxY = max(Geo.Cells(c).Y(hit,2));
			end
			for f = 1:length(Geo.Cells(c).Faces)
                Face = Geo.Cells(c).Faces(f);
                if length(Face.Tris)==3
                    continue
                end
				if Geo.Cells(c).Faces(f).Centre(2)>maxY
					maxY = Geo.Cells(c).Faces(f).Centre(2);
				end
			end
		end
		Set.VPrescribed = maxY-Set.dx/((Set.TStopBC-Set.TStartBC)/Set.dt);
		Dofs = GetDOFs(Geo, Set);
		[dimP, numP] = ind2sub([3, Geo.numY+Geo.numF+Geo.nCells],Dofs.FixP);
		for c = 1:Geo.nCells
            prescYi  = ismember(Geo.Cells(c).globalIds, numP);
            Geo.Cells(c).Y(prescYi,2) = Set.VPrescribed;
            
            % TODO FIXME, I think this is proof that face global ids
            % should be in the cell struct and not the face struct
            for gn = 1:length(numP)
                for f = 1:length(Geo.Cells(c).Faces)
                    Face = Geo.Cells(c).Faces(f);
                    if length(Face.Tris)==3
                        continue
                    end
                    if numP(gn)==Face.globalIds
                        Geo.Cells(c).Faces(f).Centre(2) = Set.VPrescribed;
                    end
                end
            end
		end
		Dofs.Free(ismember(Dofs.Free,Dofs.FixP))=[];
        Dofs.Free(ismember(Dofs.Free,Dofs.FixC))=[];
		1==1;
% 		fprintf("%d %d %d\n",length(Dofs.Free), length(Dofs.FixC), length(Dofs.FixP));
    elseif Set.BC==1 || Set.BC==2
        Dofs.Free=unique([Dofs.Free; Dofs.FixC; Dofs.FixP]);
    end
end

