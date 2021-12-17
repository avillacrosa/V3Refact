function [Geo, Set] = InitializeGeometry3DVertex(Geo,Set)
	%% Build nodal mesh 
	X = buildTopo();
	
	%% Centre Nodal position at (0,0)
	X(:,1)=X(:,1)-mean(X(:,1));
	X(:,2)=X(:,2)-mean(X(:,2));
	X(:,3)=X(:,3)-mean(X(:,3));

	[Geo.XgID,X]=SeedWithBoundingBox(X,Set.s);

	Twg=delaunay(X);
	Twg(all(ismember(Twg,Geo.XgID),2),:)=[];

	% After removing ghost tetrahedras, some nodes become disconnected, 
	% that is, not a part of any tetrahedra. Therefore, they should be 
	% removed from X
	X    = X(unique(Twg),:);
	
	% TODO FIXME Might be bad. Ideally use length of X before selecting
	% unconnected nodes zeros(length(X),1)
	conv = zeros(max(Twg,[],"all"),1);
	conv(unique(Twg)) = 1:size(X);
	Twg = conv(Twg);

	% TODO FIXME This does not seem optimal...
	Geo.Cells = baseCellStruct(length(X));
	for c = 1:length(X)
		Geo.Cells(c).X = X(c,:);
		Geo.Cells(c).T = Twg(any(ismember(Twg,c),2),:);
	end
	Geo.Cn = BuildCn(Twg);
	Geo    = GetYFromX(Geo, Set);
	Geo	   = BuildFaces(Geo);
	
% 	[Cv,Cell]=BuildCells(T,Y,X,xInternal,H, extrapolateFaceCentre);
end