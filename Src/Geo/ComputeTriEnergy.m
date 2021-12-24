function [Geo]=ComputeTriEnergy(Geo,Set)
    nrgs = zeros(0,1);
    for c = 1:3
        Cell = Geo.Cells(c);
        Ys = Cell.Y;
        for f = 1:length(Cell.Faces)
            Face = Cell.Faces(f);
            for t = 1:length(Face.Tris)
                Tri = Face.Tris(t);
                YTri = [Ys(Tri(1),:), Ys(Tri(2),:), Face.Centre];
                area = (1/2)*norm(cross(YTri(2,:)-YTri(1,:),YTri(1,:)-YTri(3,:)));
                nrg  = exp(Set.lambdaB*(1-Set.Beta*area/Set.BarrierTri0));
                nrgs(end+1) = nrg;
            end
        end
    end

%     for i=1:obj.n
%         if obj.NotEmpty(i)
%             if length(obj.Vertices{i})==3
%                 obj.EnergyTri{i}=exp(Set.lambdaB*(1-Set.Beta*obj.AreaTri{i}/Set.BarrierTri0));
%                 obj.Energy(i)=sum(obj.EnergyTri{i});
%             else 
%                 obj.EnergyTri{i}=zeros(size(obj.Vertices{i}));
%             for j=1:length(obj.Vertices{i})
%                 obj.EnergyTri{i}(j)= exp(Set.lambdaB*(1-Set.Beta*obj.AreaTri{i}(j)/Set.BarrierTri0));
%             end
%                 obj.Energy(i)=sum(obj.EnergyTri{i});
%             end 
%         else 
%         obj.EnergyTri{i}=[];
%         obj.Energy(i)=0;
%         end 
%     end
end