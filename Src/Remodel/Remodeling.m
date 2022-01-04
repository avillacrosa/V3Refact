function [Geo]=Remodeling(Geo, Dofs, Set)


% [Cell,Y,Yn,SCn,Tetrahedra,X,Dofs,Set, Vnew] = flip44(Cell,Y0, Y,Yn,SCn,Tetrahedra,X,Set,Dofs,XgID,CellInput, Vnew);
% 
% [Cell,Y,Yn,SCn,Tetrahedra,X,Dofs,Set, Vnew] = flip32(Cell,Y0, Y,Yn,SCn,Tetrahedra,X,Set,Dofs,XgID,CellInput, Vnew);

[Geo] = flip23(Geo, Dofs, Set);


% [Cell,Y,Yn,SCn,Tetrahedra,X,Dofs,Set, Vnew] = flip23RE(Cell,Y0, Y,Yn,SCn,Tetrahedra,X,Set,Dofs,XgID,CellInput, Vnew);
%% Update
% Set.NumMainV=Y.n;
% Set.NumAuxV=Cell.FaceCentres.n;
% 
% Set.NumTotalV=Set.NumMainV + Set.NumAuxV + Set.NumCellCentroid;
% Cell.AssembleAll=true;
% 
% for ii=1:Cell.n
%     Cell.SAreaTrin{ii}=Cell.SAreaTri{ii};
%     Cell.EdgeLengthsn{ii}=Cell.EdgeLengths{ii};
% end
% 
% [Cn]=BuildCn(Tetrahedra.Data);
% [Cell,Y]=CheckOrderingOfTriangulaiton(Cell,Y,Set);


end

