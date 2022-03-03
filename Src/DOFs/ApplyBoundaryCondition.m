function [Geo, Dofs] = applyBoundaryCondition(t, Geo, Dofs, Set)
%APPLYBOUNDARYCONDITION Summary of this function goes here
%   Detailed explanation goes here

	if t<=Set.TStopBC && t>=Set.TStartBC
		[dimP, FixIDs] = ind2sub([3, Geo.numY+Geo.numF+Geo.nCells],Dofs.FixP);
		if Set.BC==1
			Geo = UpdateDOFsStretch(FixIDs, Geo, Set);
		elseif Set.BC==2
			[Geo, Dofs] = UpdateDOFsCompress(Geo, Set);
		end
		Dofs.Free(ismember(Dofs.Free,Dofs.FixP))=[];
		Dofs.Free(ismember(Dofs.Free,Dofs.FixC))=[];
	elseif Set.BC==1 || Set.BC==2
		Dofs.Free=unique([Dofs.Free; Dofs.FixC; Dofs.FixP]);
	end
		
end

