function [Geo, Dofs] = applyBoundaryCondition(t, Geo, Dofs, Set)
%APPLYBOUNDARYCONDITION Summary of this function goes here
%   Detailed explanation goes here

    if Set.BC==1 && t<=Set.TStopBC && t>=Set.TStartBC && Set.ApplyBC
        % TODO FIXME, dimP, unused, but it should be...
        [dimP, numP] = ind2sub([3, Geo.numY+Geo.numF],Dofs.FixP);
        for c = 1:Geo.nCells
            prescYi  = ismember(Geo.Cells(c).globalIds, numP);
            Geo.Cells(c).Y(prescYi,2) = Geo.Cells(c).Y(prescYi,2) + Set.dx/((Set.TStopBC-Set.TStartBC)/Set.dt);
            
            % TODO FIXME, I think this is proof that face global ids
            % should be in the cell struct and not the face struct
            for gn = 1:length(numP)
                for f = 1:length(Geo.Cells(c).Faces)
                    Face = Geo.Cells(c).Faces(f);
                    if numP(gn)==Face.globalIds
                        Geo.Cells(c).Faces(f).Centre(2) = Geo.Cells(c).Faces(f).Centre(2) + Set.dx/((Set.TStopBC-Set.TStartBC)/Set.dt);
                    end
                end
            end
        end
        Dofs.Free(ismember(Dofs.Free,Dofs.FixP))=[];
        Dofs.Free(ismember(Dofs.Free,Dofs.FixC))=[];
    elseif Set.BC==1 || Set.BC==2
        Dofs.Free=unique([Dofs.Free; Dofs.FixC; Dofs.FixP]);
    end
end

