function [X]=GetXFromY(Cell,X,T,Y,XgID,Set, Yn, Tetrahedra_weights)
    % Obtain X (nodal position) from given vertex (Y) Position
    
    if Set.ObtainX == 0 && 1==2%~exist('Tetrahedra_weights', 'var')
        X_Previous = X;
        YChange = Y.DataRow - Yn.DataRow;
        
        for numX = 1:size(X, 1)
            currentTetrahedra = any(ismember(T.DataRow, numX), 2);
            if any(currentTetrahedra)
                changeOfSurroundingYs = mean(Tetrahedra_weights(currentTetrahedra, :) .* YChange(currentTetrahedra, :));
                X(numX, :) = X(numX, :) + changeOfSurroundingYs;
            end
        end
    %     Tetrahedra = T.DataRow(1:T.n, :);
    %     allXs = unique(Tetrahedra);
    %     allXs(ismember(allXs, Cell.Int)) = [];
    %     %XsToFind = sym('newX', [3 length(allXs)]);
    %     XsToFind = optimvar('newX', 3, length(allXs));
    % %     LowerBoundXs = -Inf(3, length(allXs));
    % %     LowerBoundXs(3, X(allXs, 3)>0) = 0;   
    % %     upperBoundXs = Inf(3, length(allXs));
    % %     upperBoundXs(3, X(allXs, 3)<0) = 0;
    % %     XsToFind.LowerBound = LowerBoundXs;
    % %     XsToFind.UpperBound = upperBoundXs;
    %     equations = [];
    %     
    %     for numTet = 1:T.n
    %         currentTetrahedron = T.DataRow(numTet, :);
    %         for numCoord = 1:3
    %             currentEqRightSide = Y.DataRow(numTet, numCoord)*4;
    %             currentEqLeftSide = 0;
    %             for numNode = currentTetrahedron
    %                 if ismember(numNode, Cell.Int)
    %                     currentEqRightSide = currentEqRightSide + X(numNode, numCoord);
    %                 else
    %                     currentEqLeftSide = currentEqLeftSide + XsToFind(numCoord, allXs == numNode);
    %                 end
    %             end
    %             
    %             equations = [equations, currentEqLeftSide == currentEqRightSide];
    %         end
    %         
    %     end
    % %     tic
    % %     [A,B] = equationsToMatrix(equations, XsToFind);
    % %     newXSolved = linsolve(A,B);
    % %     toc
    % %     tic
    %     prob = eqnproblem('Equations',equations);
    %     x0.newX = X_Previous(allXs, :)';
    %     [sol] = solve(prob, x0, 'solver', 'lsqnonlin');
    %     X(allXs, :) = sol.newX';
    % %     toc
    % %     tic
    % %     newXSolved = solve(equations);
    % %     toc
    %     disp('end');
        
    elseif Set.ObtainX==1
        %% The functional to be minimized (Xi =1/4)
        %  J:= (y-NN*x)'*(y-NN*x) + LM'*( X(cellcentre) - Xc)
        %  X^*=min_X (J)
        T=T.Data;
        Y=Y.Data;
        N=ones(size(T))*(1/4);
        NN=zeros(3*size(Y,1),3*size(X,1));
        ID=1:size(X,1);
        ID(XgID)=[];
        
        % Assemble NN matrix
        for numCell=1:size(Y,1)
            ii=3*(numCell-1)+1;
            for j=1:4
                jj=3*(T(numCell,j)-1)+1;
                NN(ii:ii+2,jj:jj+2)=N(numCell,j)*eye(3);
            end
        end
        
        I=zeros(3*size(X,1),3*length(ID));
        for numCell=1:length(ID)
            ii=3*(numCell-1)+1;
            jj=3*(ID(numCell)-1)+1;
            I(ii:ii+2,jj:jj+2)=eye(3);
        end
        
        % the inverse problem: minimize  J:= (y-NN*x)'*(y-NN*x)
        %  x=(NN'*NN)\(NN'*y);
        
        % the inverse problem: minimize  J:= (y-NN*x)'*(y-NN*x) + LM'*( X(cellcentre) - Xc)
        Xc=reshape(X(ID,:)',length(ID)*3,[]);
        
        A=[(NN'*NN) I;
            I'      zeros(3*length(ID))];
        
        y=reshape(Y',size(Y,1)*3,[]);
        b=[(NN'*y); Xc];
        x=A\b;
        X=reshape(x(1:size(X,1)*3),3,size(X,1))';
    elseif Set.ObtainX==2
        % The functional to be minimized
        % J := (y-N*x)'*(y-N*x) + L*(X-Xc) + (Xi-1/4)*wg + wv sum(Vol_Tet)
        %  X^*,Xi^* =min_X (J)
        
        ID=1:size(X,1);
        ID(XgID)=[];
        Xc=reshape(X(ID,:)',length(ID)*3,[]);
        
        aux=T;
        T=T.Data;
        Y=Y.Data;
        N=ones(size(T))*(1/4);
    
        TetV0=zeros(size(T,1),1);
        for numCell=1:size(T,1)
            X1=X(T(numCell,1),:);
            X2=X(T(numCell,2),:);
            X3=X(T(numCell,3),:);
            X4=X(T(numCell,4),:);
            TetV0(numCell)=(1/6)*dot(X1'-X3',cross(X2-X3,X4-X3)');
        end
        
        
        nn3=size(X,1)*size(X,2); % number of nodes*3
        nv3=size(Y,1)*size(Y,2); % number of vertices*3
        nxc=length(Xc);          % number of cell centres*3 (Lagrange multiplier)
        
        % Initial guess
        m=zeros(nn3+nv3+nxc,1);
        m(1:nn3)=reshape(X',size(X,1)*3,[]);
        m(nn3+1:nn3+nv3)=reshape(N',size(N,1)*3,[]);
        m(nn3+nv3+1:end)=1;
        
        y=reshape(Y',size(Y,1)*3,[]);
        
        F=@(m) Functional1(m,y,T,nn3,nv3,ID,Xc,TetV0);
        options = optimoptions('fsolve','Display','iter-detailed','Diagnostics','on'...
            ,'MaxFunctionEvaluations',length(m)*500,'UseParallel',true...
            ,'MaxIterations',1000,'Algorithm','levenberg-marquardt');
        
        m=fsolve(F,m,options);
        x=m(1:nn3);
        Xi=m(nn3+1:nn3+nv3);
        
        X=reshape(x,3,nn3/3)';
        Xi=reshape(Xi,3,nv3/3)';
        
        N=aux;
        N.DataRow(N.NotEmpty,:)=[Xi 1-sum(Xi,2)];
        
    elseif Set.ObtainX==3
        %% GeometricalConstruction
        % Here interior nodes are placed in the centre of cells, while exterior 
        % nodes are placed with a distance d form the cell centre in the direction of centre of the face. 
        d=1;
        % Loop over boundary nodes
        for numCell=1:length(XgID)
            nf=0; % number of cells/nodes connected to XgID(i)
            XX=zeros(3,1);
            for f=1:Cell.AllFaces.n
                aux=ismember(XgID(numCell),Cell.AllFaces.Nodes(f,:));
                if ~Cell.AllFaces.NotEmpty(f) || aux==0
                    continue
                end
                nf=nf+1;
                xi=Cell.FaceCentres.DataRow(f,:)';     
                pi=X(Cell.AllFaces.Nodes(f,Cell.AllFaces.Nodes(f,:)~=XgID(numCell)),:)';
                v=(xi-pi)/norm(xi-pi);
                XX=XX+d*v+pi;
            end
            
            if nf==1
                X(XgID(numCell),:)=d*v+pi;
            elseif nf ==0
                continue
            else
                X(XgID(numCell),:)=XX./nf;
            end
            
        end
    end

end


function [F]=Functional1(m,y,T,nn3,nv3,ID,Xc,TetV0)
    % The functional to be minimized
    % J := (y-N*x)'*(y-N*x) + LM*(X-Xc) + (Xi-1/4)*wg + wv sum(Vol_Tet)
    %  F = [dJ/dX; dJ/dXi dJ/LM]
    x=m(1:nn3);
    Xi=m(nn3+1:nn3+nv3);
    L=m(nn3+nv3+1:end);
    
    
    
    N=zeros(nv3,nn3);
    % Assemble NN matrix
    for i=1:nv3/3
        ii=3*(i-1)+1;
        Ne=zeros(4,1);
        Ne(1:3)=Xi(ii:ii+2);
        Ne(4)=1-sum(Ne(1:3));
        for j=1:4
            jj=3*(T(i,j)-1)+1;
            N(ii:ii+2,jj:jj+2)=Ne(j)*eye(3);
        end
    end
    
    
    X=reshape(x,3,nn3/3)';
    XX=zeros(nv3,nv3);
    x4=zeros(nv3,1);
    for i=1:nv3/3
        ii=3*(i-1)+1;
        XX(ii:ii+2,ii:ii+2)=[X(T(i,1),:)'-X(T(i,4),:)'...
            X(T(i,2),:)'-X(T(i,4),:)'...
            X(T(i,3),:)'-X(T(i,4),:)'];
        x4(ii:ii+2)=X(T(i,4),:);
    end
    
    
    % Assemble I matrix
    I=zeros(3*size(X,1),3*length(ID));
    for i=1:length(ID)
        ii=3*(i-1)+1;
        jj=3*(ID(i)-1)+1;
        I(ii:ii+2,jj:jj+2)=eye(3);
    end
    
    
    % Assemble dV/dX
    dVdX=zeros(nn3,1);
    wv=.01;
    for i=1:size(T,1)
        X1=X(T(i,1),:);
        X2=X(T(i,2),:);
        X3=X(T(i,3),:);
        X4=X(T(i,4),:);
        dd1=3*T(i,1);
        dd2=3*T(i,2);
        dd3=3*T(i,3);
        dd4=3*T(i,4);
        V=(1/6)*dot(X1'-X3',cross(X2-X3,X4-X3)');
        fact=wv*(V-TetV0(i)) / (3*TetV0(i)^2);
        dVdX(dd1-2:dd1)=dVdX(dd1-2:dd1)+fact *cross(X2-X3,X4-X3)';
        dVdX(dd2-2:dd2)=dVdX(dd2-2:dd2)+fact *cross(X3-X1,X4-X1)';
        dVdX(dd3-2:dd3)=dVdX(dd3-2:dd3)+fact *cross(X4-X1,X2-X1)';
        dVdX(dd4-2:dd4)=dVdX(dd4-2:dd4)+fact *cross(X2-X1,X3-X1)';
    end
    
    q=ones(size(Xi))*(1/4);
    wg=20;
    F=zeros(size(m));
    F(1:nn3)=-(N'*N)*x+ N'*y + I*L+dVdX;
    F(nn3+1:nn3+nv3)=-(XX'*XX)*Xi+ XX'*y-XX'*x4 + wg*(Xi-q);
    F(nn3+nv3+1:end)=I'*x-Xc;
end

