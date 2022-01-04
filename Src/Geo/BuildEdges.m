function edges = BuildEdges(Tets, FaceIds, FaceCentre, X, Ys)
	FaceTets = Tets(FaceIds,:);
	vtk_order = zeros(length(FaceTets),1);
	% TODO FIXME, initialize, there was a bug here. Is there a more
	% clean way to write it ?
	vtk_order(1) = 1;
	prev_tet  = FaceTets(1,:);
    if size(FaceTets,1) > 3
        for yi = 2:length(FaceTets)
		    i = sum(ismember(FaceTets, prev_tet),2)==3;
		    i = i & ~ismember(1:length(FaceTets),vtk_order)';
		    i = find(i);
		    vtk_order(yi) = i(1);
		    prev_tet = FaceTets(i(1),:);
        end
    else
        % TODO FIXME is this enough??? will it get flipped later if not
        % correct ???
        fprintf("TRIIIIIIIIIIIIIIIIIIIIII\n");
        vtk_order = [1 2 3]';
    end
	surf_ids  = 1:length(Tets); 
	surf_ids  = surf_ids(FaceIds);
	surf_ids  = surf_ids(vtk_order);
	Order=0;
	for iii=1:length(surf_ids)
		if iii==length(surf_ids)
			v1=Ys(surf_ids(iii),:)-FaceCentre;
			v2=Ys(surf_ids(1),:)-FaceCentre;
			Order=Order+dot(cross(v1,v2),FaceCentre-X)/length(surf_ids);
		else
			v1=Ys(surf_ids(iii),:)-FaceCentre;
			v2=Ys(surf_ids(iii+1),:)-FaceCentre;
			Order=Order+dot(cross(v1,v2),FaceCentre-X)/length(surf_ids);
		end
	end
	if Order<0
		surf_ids=flip(surf_ids);
	end

	edges = zeros(length(surf_ids), 2);
	for yf = 1:length(surf_ids)-1
		edges(yf,:) = [surf_ids(yf) surf_ids(yf+1)];
	end
	edges(end,:) = [surf_ids(end) surf_ids(1)];
end