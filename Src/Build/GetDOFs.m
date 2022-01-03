function [Dofs]=GetDOFs(Geo, Set)
    % Define free and constrained vertices:
    %   1) Vertices with y-coordinates > Set.VPrescribed are those to be prescribed (pulled)
    %   2) Vertices with y-coordinates < Set.VFixed are those to be fixed
    %   3) the rest are set to be free
    % TODO FIXME HARDCODE
    dim = 3;
    gconstrained = zeros((Geo.numY+Geo.numF)*3, 1);
    gprescribed  = zeros((Geo.numY+Geo.numF)*3, 1);
    for c = 1:Geo.nCells
        Y     = Geo.Cells(c).Y;
        gIDsY = Geo.Cells(c).globalIds;
        for f = 1:length(Geo.Cells(c).Faces)
            Face = Geo.Cells(c).Faces(f);
            if Face.Centre(2) < Set.VFixd
                gconstrained(dim*(Face.globalIds-1)+2) = 1;
            elseif Face.Centre(2) > Set.VPrescribed
                gprescribed(dim*(Face.globalIds-1)+2) = 1;
            end
        end
        fixY = Y(:,2) < Set.VFixd;
        preY = Y(:,2) > Set.VPrescribed;
        gconstrained(dim*(gIDsY(fixY)-1)+2) = 1;
        gprescribed(dim*(gIDsY(preY)-1)+2) = 1;
    end
    Dofs.Free = find(gconstrained==0 & gprescribed==0);
    Dofs.Fix  = [find(gconstrained); find(gprescribed)];
    Dofs.FixP = find(gprescribed);
    Dofs.FixC = find(gconstrained);
end