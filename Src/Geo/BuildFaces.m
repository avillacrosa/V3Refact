function Geo = BuildFaces(Geo)
	for c = 1:length(Geo.Cells)
		Tets = Geo.Cells(c).T;
		Ys   = Geo.Cells(c).Y;
		Geo.Cells(c).Faces = struct('ij',{},'YID',{},'Centre',{}, 'Tris', {});
		Neigh_nodes = unique(Tets);
		Neigh_nodes(Neigh_nodes==c)=[];
		for j  = 1:length(Neigh_nodes)
			temp_str = struct();
			ij = [c, Neigh_nodes(j)];
			face_ids  = sum(ismember(Tets,ij),2)==2;
			surf_ids  = 1:length(Tets);
			surf_ids  = surf_ids(face_ids);
			tris = zeros(length(surf_ids)-1, 3);
			% TODO FIXME This can be probably done with modulus?
			for tri = 2:length(surf_ids)
				if j == 1
					tris(tri-1,:) = [surf_ids(tri-1) surf_ids(tri) Neigh_nodes(1)];
				else
					tris(tri-1,:) = [surf_ids(tri-1) surf_ids(tri) Neigh_nodes(j-1)];
				end

			end
		
			temp_str.ij  = ij;
			temp_str.YID = surf_ids;
			temp_str.Centre = BuildFaceCentre(Ys(face_ids,:));
			temp_str.Tris  = tris;

			Geo.Cells(c).Faces(j) = temp_str;
		end
	end
end