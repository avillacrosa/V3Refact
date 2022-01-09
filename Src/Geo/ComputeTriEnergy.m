% TODO FIXME, should this just be an update to the Geo struct?
function [nrgs]=ComputeTriEnergy(Face, Ys, Set)
    nrgs = zeros(0,1);
	for t = 1:length(Face.Tris)
        Tri = Face.Tris(t,:);
        if length(Face.Tris)==3
            Y3 = Ys(Face.Tris(t+1,2),:);
        else
            Y3 = Face.Centre;
        end
        YTri = [Ys(Tri(1),:); Ys(Tri(2),:); Y3];
        area = (1/2)*norm(cross(YTri(2,:)-YTri(1,:),YTri(1,:)-YTri(3,:)));
        nrg  = exp(Set.lambdaB*(1-Set.Beta*area/Set.BarrierTri0));
        nrgs(end+1) = nrg;
        if length(Face.Tris)==3
            break
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
