function [Geo] = flip44(Geo, Dofs, Set)
    % flip44 Summary of this function goes here
    %   Detailed explanation goes here
    %% loop over 4-vertices-faces (Flip44)
   for c = 1:Geo.nCells
		% WHOLE REMODELLING WILL BE INSIDE HERE
		for f = 1:length(Geo.Cells(c).Faces)
		    Ys = Geo.Cells(c).Y;
		    Ts = Geo.Cells(c).T;
			Face = Geo.Cells(c).Faces(f);
			nrgs = ComputeTriEnergy(Face, Ys, Set);
			[~,idVertex]=max(nrgs);
            if max(nrgs)<Set.RemodelTol
                continue
			end
			oV=unique(Geo.Cells(c).Faces(f).Tris);
			fprintf('=>> 44 Flip.\n');
			side=[1 2;
            	  2 3;
            	  3 4;
            	  1 4];
			L(1)=norm(Ys(oV(1),:)-Ys(oV(2),:));
        	L(2)=norm(Ys(oV(2),:)-Ys(oV(3),:));
        	L(3)=norm(Ys(oV(3),:)-Ys(oV(4),:));
        	L(4)=norm(Ys(oV(1),:)-Ys(oV(4),:));
			[~,Jun]=min(L);
        	VJ=oV(side(Jun,:));
        	cVJ3=intersect(Ts(VJ(1),:),Ts(VJ(2),:));
        	N=unique(Ts(VJ,:)); % all nodes
        	NZ=N(~ismember(N,cVJ3));
        	NX=Face.ij;
        	Tnew1=Ts(oV(1),:);       Tnew1(ismember(Tnew1,NX(1)))=NZ(~ismember(NZ,Tnew1));
        	Tnew2=Ts(oV(2),:);       Tnew2(ismember(Tnew2,NX(2)))=NZ(~ismember(NZ,Tnew2));
        	Tnew3=Ts(oV(3),:);       Tnew3(ismember(Tnew3,NX(1)))=NZ(~ismember(NZ,Tnew3));
        	Tnew4=Ts(oV(4),:);       Tnew4(ismember(Tnew4,NX(2)))=NZ(~ismember(NZ,Tnew4));
        	Tnew=[Tnew1;Tnew2;Tnew3;Tnew4];
			Ynew=Flip44(Ys(oV,:),Tnew,L,Geo);
		end
   end
        % copy data
        Cellp=Cell; Yp=Y; Ynp=Yn;  SCnp=SCn; Tp=T; Xp=X; Dofsp=Dofs; Setp=Set; Vnewp=Vnew;
        fprintf('=>> 44 Flip.\n');
        oV=Cell.AllFaces.Vertices{i};
        
        side=[1 2;
            2 3;
            3 4;
            1 4];
        
        % The new connectivity
        % Faces Edges
        L(1)=norm(Y.DataRow(oV(1),:)-Y.DataRow(oV(2),:));
        L(2)=norm(Y.DataRow(oV(2),:)-Y.DataRow(oV(3),:));
        L(3)=norm(Y.DataRow(oV(3),:)-Y.DataRow(oV(4),:));
        L(4)=norm(Y.DataRow(oV(1),:)-Y.DataRow(oV(4),:));
        [~,Jun]=min(L);
        VJ=oV(side(Jun,:));
        cVJ3=intersect(T.DataRow(VJ(1),:),T.DataRow(VJ(2),:));
        N=unique(T.DataRow(VJ,:)); % all nodes
        NZ=N(~ismember(N,cVJ3));
        NX=Cell.AllFaces.Nodes(i,:);
        Tnew1=T.DataRow(oV(1),:);       Tnew1(ismember(Tnew1,NX(1)))=NZ(~ismember(NZ,Tnew1));
        Tnew2=T.DataRow(oV(2),:);       Tnew2(ismember(Tnew2,NX(2)))=NZ(~ismember(NZ,Tnew2));
        Tnew3=T.DataRow(oV(3),:);       Tnew3(ismember(Tnew3,NX(1)))=NZ(~ismember(NZ,Tnew3));
        Tnew4=T.DataRow(oV(4),:);       Tnew4(ismember(Tnew4,NX(2)))=NZ(~ismember(NZ,Tnew4));
        Tnew=[Tnew1;Tnew2;Tnew3;Tnew4];
        
        % Check Convexity Condition
        % Changed by Adria. Missing input variable X
        [IsNotConvex,~]=CheckConvexityCondition(Tnew,T,X);
        if IsNotConvex
            fprintf('=>> 44-Flip is is not compatible rejected.\n');
            continue
        end
        
        % The new vertices
        Ynew=Flip44(Y.DataRow(oV,:),Tnew,L,X);
        
        % Remove the face
        [T, Y, Yn, SCn, Cell] = removeFaceInRemodelling(T, Y, Yn, SCn, Cell, oV, i);
        
        % add new vertices 
        [T, Y, Yn, Cell, nV, Vnew, nC, SCn, Set, flag] = addNewVerticesInRemodelling(T, Tnew, Y, Ynew, Yn, Cell, Vnew, X, SCn, XgID, Set);
      
        if ~flag
            fprintf('Vertices number %i %i %i %i -> were replaced by -> %i %i %i %i.\n',oV(1),oV(2),oV(3),oV(4),nV(1),nV(2),nV(3),nV(4));
            if ~isnan(Set.BC)
                [Dofs] = GetDOFs(Y,Cell,Set, isempty(Set.InputSegmentedImage) == 0);
            else
                [Dofs]=GetDOFsSubsrtate(Y,Cell,Set);
            end
            [Dofs] = updateRemodelingDOFs(Dofs, nV, nC, Y);
            
            Cell.RemodelledVertices=[nV; nC+Y.n];
            
            % Changed by Adria. As in flip23, SolveRemodellingStep has
            % inconsistent input variables
    %         [Cell,Y,Yn,SCn,X,Dofs,Set,~,DidNotConverge]=SolveRemodelingStep(Cell,Y0,Y,X,Dofs,Set,Yn,SCn,CellInput);
            [Geo, Set, DidNotConverge] = SolveRemodelingStep(Geo, DofsR, Set);
            Yn.DataRow(nV,:)=Y.DataRow(nV,:);
        else
            error('check Flip44 flag');
        end
        
        if  DidNotConverge || flag %|| NotConvexCell(Cell,Y)
            [Cell, Y, Yn, SCn, T, X, Dofs, Set, Vnew] = backToPreviousStep(Cellp, Yp, Ynp, SCnp, Tp, Xp, Dofsp, Setp, Vnewp);
            fprintf('=>> Local problem did not converge -> 44 Flip rejected !! \n');
            Set.N_Rejected_Transfromation=Set.N_Rejected_Transfromation+1;
        else
            Set.N_Accepted_Transfromation=Set.N_Accepted_Transfromation+1;
        end
    end
end

%%
function Yn=Flip44(Y,Tnew,L,Geo)
	center=sum(Y,1)./4;
	% L=mean(L)/2;
	L=mean(L);
	
	c1=sum(Geo.X(Tnew(1,:),:),1)./4;
	c2=sum(Geo.X(Tnew(2,:),:),1)./4;
	c3=sum(Geo.X(Tnew(3,:),:),1)./4;
	c4=sum(Geo.X(Tnew(4,:),:),1)./4;
	Lc1=c1-center; Lc1=Lc1/norm(Lc1);
	Lc2=c2-center; Lc2=Lc2/norm(Lc2);
	Lc3=c3-center; Lc3=Lc3/norm(Lc3);
	Lc4=c4-center; Lc4=Lc4/norm(Lc4);
	Y1=center+L.*Lc1;
	Y2=center+L.*Lc2;
	Y3=center+L.*Lc3;
	Y4=center+L.*Lc4;
	Yn=[Y1;Y2;Y3;Y4];
end

