function Geo = BuildFaces(Geo, Set)
	% TODO FIXME HARDCODE!
	gIds = 1;
	% TODO FIXME, this should go outside the build faces function
	% Essentially it is necessary to reestructure a bit from the outside
	for c = 1:3
		Tets = Geo.Cells(c).T;
		Ys   = Geo.Cells(c).Y;
		Geo.Cells(c).Faces = struct('ij',{},'YID',{},'Centre',{}, ...
							'Tris', {}, 'gID', {}, 'InterfaceType', {},...
							'Area', {}, 'Area0', {});
		Neigh_nodes = unique(Tets);
		Neigh_nodes(Neigh_nodes==c)=[];
		YKIds = zeros(length(Ys), 1);
		for j  = 1:length(Neigh_nodes)
			temp_str = struct();
			ij = [c, Neigh_nodes(j)];
			face_ids  = sum(ismember(Tets,ij),2)==2; 
			face_tets = Tets(face_ids,:);
	
			vtk_order = zeros(length(face_tets),1);
			prev_tet  = face_tets(1,:);
			for yi = 1:length(face_tets)
				i = sum(ismember(face_tets, prev_tet),2)==3;
				i = i & ~ismember(1:length(face_tets),vtk_order)';
				i = find(i);
				vtk_order(yi) = i(1);
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
			temp_str.InterfaceType = ftype;
			temp_str.Area = 0;
			temp_str.gID = -1;
			temp_str.Area0 = 0;
			
			if ~isempty(Geo.Cells(Neigh_nodes(j)).Faces)
				opp_faces = Geo.Cells(Neigh_nodes(j)).Faces;
				for of = 1:length(opp_faces)
					opp_face = opp_faces(of);
					if sum(ismember(opp_face.ij, ij)) == 2
						YKIds(face_ids) = Geo.Cells(Neigh_nodes(j)).YKIds(opp_face.YID);
					end
				end
			end
			Geo.Cells(c).Faces(j) = temp_str;
		end
		nz = length(YKIds(YKIds==0));
		YKIds(YKIds==0) = gIds:(gIds+nz-1);
		gIds = gIds + nz;
		Geo.Cells(c).YKIds = YKIds;
	end
	Geo.numY = gIds-1;
	used_ijs = zeros(0,2);
	% TODO FIXME, terrible...
	% I think this can be obtained directly from Geo.Cn ?
	for c = 1:3
		for f = 1:length(Geo.Cells(c).Faces)
			ij = Geo.Cells(c).Faces(f).ij;
% 			any(sum(ismember(a,b), 2)==2)
			if ~any(sum(ismember(used_ijs, ij),2)==2)
				Geo.Cells(c).Faces(f).gID = gIds;
				gIds = gIds + 1;
				used_ijs(end+1,:) = ij;
			else
				for f2 = 1:length(Geo.Cells(ij(2)).Faces)
					face2 = Geo.Cells(ij(2)).Faces(f2);
					if sum(ismember(face2 .ij, ij),2)==2
						Geo.Cells(c).Faces(f).gID = face2.gID;
					end
				end
			end
		end
	end
	Geo.numF = gIds-Geo.numY-1;
end