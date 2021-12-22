function [g,K,Cell,EnergyS]=KgSurfaceCellBased(Cell,Y,Set)
% The residual g and Jacobian K of Surface  Energy
% Energy based on the total cell area W_s= sum_cell ((Ac-Ac0)/Ac0)^2

%% Initialize
if nargout > 1
    if Set.Sparse == 2 %Manual sparse
        [g, EnergyS, ncell, K, si, sj, sk, sv] = initializeKg(Cell, Set);
    else %Matlab sparse
        [g, EnergyS, ncell, K] = initializeKg(Cell, Set);
    end
else
    [g, EnergyS, ncell] = initializeKg(Cell, Set);
end

%% Loop over Cells
%     % Analytical residual g and Jacobian K
for i=1:ncell
%     if Cell.DebrisCells(i)
%         continue;
%     end
    if ~Cell.AssembleAll
        if ~ismember(Cell.Int(i),Cell.AssembleNodes)
            continue
        end
    end
    lambdaS=Set.lambdaS;
    if Set.A0eq0
        fact=lambdaS *  (Cell.SArea(i)) / Cell.SArea0(i)^2   ;
    else
        fact=lambdaS *  (Cell.SArea(i)-Cell.SArea0(i)) / Cell.SArea0(i)^2   ;
    end
    ge=zeros(size(g, 1),1); % Local cell residual
    % Loop over Cell-face-triangles
    Tris=Cell.Tris{i};
    for t=1:size(Tris,1)
        nY=Tris(t,:);
        Y1=Y.DataRow(nY(1),:);
        Y2=Y.DataRow(nY(2),:);
        if nY(3)<0
            nY(3)=abs(nY(3));
            Y3=Y.DataRow(nY(3),:);
        else
            Y3=Cell.FaceCentres.DataRow(nY(3),:);
            nY(3)=nY(3)+Set.NumMainV;
        end
        [gs,Ks,Kss]=gKSArea(Y1,Y2,Y3);
        ge=Assembleg(ge,gs,nY);
        if nargout>1
            Ks=fact*(Ks+Kss);
            if Set.Sparse == 2
                [si,sj,sv,sk]= AssembleKSparse(Ks,nY,si,sj,sv,sk);
            else
                K= AssembleK(K,Ks,nY);
            end
        end
    end
    
    g=g+ge*fact;
    if nargout>1
        if Set.Sparse == 2
            K=K+sparse((ge)*(ge')*lambdaS/(Cell.SArea0(i)^2));
        else
            K=K+(ge)*(ge')*lambdaS/(Cell.SArea0(i)^2); 
        end
        
        if Set.A0eq0
            EnergyS=EnergyS+ lambdaS/2 *((Cell.SArea(i)) / Cell.SArea0(i))^2;
        else
            EnergyS=EnergyS+ lambdaS/2 *((Cell.SArea(i)-Cell.SArea0(i)) / Cell.SArea0(i))^2;
        end
    end
end

if Set.Sparse == 2 && nargout>1
    K=sparse(si(1:sk),sj(1:sk),sv(1:sk),size(K, 1),size(K, 2))+K;
end
end