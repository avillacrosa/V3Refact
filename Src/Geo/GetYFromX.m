function Geo = GetYFromX(Geo, Set)
	% TODO FIXME
	dim = 3;
	for c = 1:length(Geo.Cells)
		Tets = Geo.Cells(c).T;
		Y = zeros(size(Tets,1), dim);
		X = Geo.Cells(c).X;
		nverts = length(Tets);
		for i=1:nverts % 1 vert = 1 tet
			T = Tets(i,:);
			% Condition for the case where 3 nodes are ghost nodes,
			% i.e. external vertex
			x = [Geo.Cells(T(1)).X; Geo.Cells(T(2)).X; ...
				 Geo.Cells(T(3)).X; Geo.Cells(T(4)).X];
    		if abs(sum(ismember(T,Geo.XgID))-3)<eps 
        		Center=1/4*(sum(x,1));

        		vc=Center-X;
        		dis=norm(vc);
        		dir=vc/dis;
        		offset=Set.f*dir;
        		Y(i,:)=X+offset;	
			else 
        		for n=1:size(x,2)
             		Y(i,1:3)=Y(i,1:3)+(1/4)*x(n,1:3);
        		end
    		end 
		end
		Geo.Cells(c).Y = Y;
	end
end

