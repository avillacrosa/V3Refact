function Geo = GetYFromX(Geo, Set)
	% TODO FIXME
	dim = 3;
	nummainY = 0;
	for c = 1:length(Geo.Cells)
		Tets = Geo.Cells(c).T;
		Y = zeros(size(Tets,1), dim);
		nverts = length(Tets);
		for i=1:nverts % 1 vert = 1 tet
			T = Tets(i,:);
			x = [Geo.Cells(T(1)).X; Geo.Cells(T(2)).X; ...
				 Geo.Cells(T(3)).X; Geo.Cells(T(4)).X];

			% Condition for the case where 3 nodes are ghost nodes,
			% i.e. external vertex
    		if abs(sum(ismember(T,Geo.XgID))-3)<eps 
        		Center=(sum(x,1))/4;
        		vc=Center-Geo.Cells(c).X;
        		dir=vc/norm(vc);
        		offset=Set.f*dir;
        		Y(i,:)=Geo.Cells(c).X+offset;	
			else 
        		for n=1:size(x,1)
             		Y(i,:)=Y(i,:)+x(n,:)/4;
        		end
    		end 
		end
		Geo.Cells(c).Y = Y;
		nummainY = nummainY + length(Y);
	end
	Geo.nmainY = nummainY;
end

