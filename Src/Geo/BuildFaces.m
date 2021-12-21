function Geo = BuildFaces(Geo, Set)
	% TODO FIXME HARDCODE!
	face_count = 1;
	for c = 1:3
		Tets = Geo.Cells(c).T;
		Ys   = Geo.Cells(c).Y;
		Geo.Cells(c).Faces = struct('ij',{},'YID',{},'Centre',{}, ...
							'Tris', {}, 'gID', {}, 'InterfaceType', {},...
							'Area', {}, 'Area0', {});
		Neigh_nodes = unique(Tets);
		Neigh_nodes(Neigh_nodes==c)=[];
		for j  = 1:length(Neigh_nodes)
			temp_str = struct();
			ij = [c, Neigh_nodes(j)];
			face_ids  = sum(ismember(Tets,ij),2)==2; 
			face_tets = Tets(face_ids,:);
	
			vtk_order = zeros(length(face_tets),1);
			prev_tet  = face_tets(1,:);
			for f = 1:length(face_tets)
				i = sum(ismember(face_tets, prev_tet),2)==3;
				i = i & ~ismember(1:length(face_tets),vtk_order)';
				i = find(i);
				vtk_order(f) = i(1);
				prev_tet = face_tets(i(1),:);
			end
			surf_ids  = 1:length(Tets); 
			surf_ids  = surf_ids(face_ids);
			surf_ids  = surf_ids(vtk_order);

			tris = zeros(length(surf_ids), 2);
			for yf = 1:length(surf_ids)-1
				tris(yf,:) = [surf_ids(yf) surf_ids(yf+1)];
			end
			
			if any(ismember(ij, Geo.XgID))
				ftype = 0;
			else
				ftype = 1;
			end

			tris(end,:) = [surf_ids(end) surf_ids(1)];
			temp_str.ij  = ij;
			temp_str.YID = surf_ids;
			temp_str.Centre = BuildFaceCentre(ij, Geo.Cells(c).X, Ys(face_ids,:), Set.f);
			temp_str.Tris  = tris;
			temp_str.gID   = face_count + Geo.nmainY;
			temp_str.InterfaceType = ftype;
			temp_str.Area = 0;
			temp_str.Area0 = 0;
			Geo.Cells(c).Faces(j) = temp_str;

			face_count = face_count + 1;
		end
	end
end