function [Geo, Dofs] = applyBoundaryCondition(t, Geo, Dofs, Set)
%APPLYBOUNDARYCONDITION Summary of this function goes here
%   Detailed explanation goes here
    if Set.BC==1 && t<=Set.TStopBC && t>=Set.TStartBC && Set.ApplyBC
        for c = 1:Geo.nCells
            [nP, dP] = ind2sub(size(Geo.Cells(c).Y'),Dofs.FixP);
            [nPf, dPf] = ind2sub([length(Geo.Cells(c).Faces),3]',Dofs.FixP);
            Geo.Cells(c).Y(nP,dP)=Geo.Cells(c).Y(nP,dP)+Set.dx/((Set.TStopBC-Set.TStartBC)/Set.dt);
            for f = 1:length(Geo.Cells(c).Faces)
                Geo.Cells(c).Faces(f).Centre(nPf,dPf)=Geo.Cells(c).Faces(f).Centre(nPf,dPf)+Set.dx/((Set.TStopBC-Set.TStartBC)/Set.dt);
            end
        end
        Dofs.Free(ismember(Dofs.Free,Dofs.FixP))=[];
        Dofs.Free(ismember(Dofs.Free,Dofs.FixC))=[];
    elseif Set.BC==1 || Set.BC==2
        Dofs.Free=unique([Dofs.Free; Dofs.FixC; Dofs.FixP]);
    end
end

