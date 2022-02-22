function [XgID,X]=SeedWithBoundingBox(X,s)
    nCells = size(X,1);
	r0=mean(X); 
    r=5*max(abs(max(X-r0)));

	theta=linspace(0,2*pi,5);
    phi=linspace(0,pi,5);
    [theta,phi]=meshgrid(theta,phi);
    x=r*sin(phi).*cos(theta);
    y=r*sin(phi).*sin(theta);
    z=r*cos(phi);
    x=reshape(x,size(x,1)*size(x,2),1);
    y=reshape(y,size(y,1)*size(y,2),1);
    z=reshape(z,size(z,1)*size(z,2),1);
    XgBB=[x y z];  
    XgBB=uniquetol(XgBB,'ByRows',1e-6);
    XgBB=XgBB+r0;
% 	Xg=uniquetol(Xg,'ByRows',1e-6);
    % This interpolates a sphere by intersecting 2 circles defining a plane
    % and intersecting each other
	
	%% 2) Do first Delaunay with ghost nodes
	XgID=(size(X,1)+1):(size(X,1)+size(XgBB,1));
    XgIDBB = XgID;
	X=[X;XgBB];
	Twg=delaunay(X);
	% ------------- EQUAL UP TO HERE
	%% 3) intitilize 
	Side =[	1 2 3; 1 2 4; 2 3 4; 1 3 4];
	Edges=[	1 2; 2 3; 3 4; 1 3; 1 4; 3 4; 1 4];  
	% find real tests 
    % Vol=zeros(size(Twg,1),1);
	AreaFaces=zeros(size(Twg,1)*3,4);
	LengthEdges=zeros(size(Twg,1)*3,6);
	% Volc=0;
	Arc=0;
	Lnc=0;
	
	%%  4) compute the size of Real Entities (edges, faces and tetrahedrons) 
	for i=1:size(Twg,1)  
		%----------- Area
    	for j=1:4
        	if sum(ismember(Twg(i,Side(j,:)),XgID))==0
           		AreaFaces(i,j)=AreTri(X(Twg(i,Side(j,1)),:),X(Twg(i,Side(j,2)),:),X(Twg(i,Side(j,3)),:));
           		Arc=Arc+1;
        	else 
				AreaFaces(i,j)=0;
        	end 
    	end 
    	%-----------Length
    	for j=1:6
        	if sum(ismember(Twg(i,Edges(j,:)),XgID))==0
           		LengthEdges(i,j)=norm(X(Twg(i,Edges(j,1)),:)-X(Twg(i,Edges(j,2)),:));
           		Lnc=Lnc+1;
        	else 
				LengthEdges(i,j)=0;
        	end 
    	end    
	end 
	
	%% 5) seed nodes in big Entities (based on characteristic Length h) 
	for i=1:size(Twg,1)  
    	%---- Seed according to area 
    	for j=1:4
        	if sum(ismember(Twg(i,Side(j,:)),XgID))==0
            	if AreaFaces(i,j)>(s)^2
                    % WE DO NOT ENTER HERE
                	[X,XgID]=SeedNodeTri(X,XgID,Twg(i,Side(j,:)),s);
            	end 
        	end 
    	end  
    	
    	%---- Seed according to length
    	for j=1:6
        	if sum(ismember(Twg(i,Edges(j,:)),XgID))==0 && LengthEdges(i,j)>2*s % LengthEdges(i,j)>LengthTol*mLength
	%             [X,XgID]=SeedNodeBar(X,XgID,Twg(i,Edges(j,:)),h);
                % WE DO NOT ENTER HERE
            	[X,XgID]=SeedNodeTet(X,XgID,Twg(i,:),s); 
            	break
        	end 
    	end 
	end 
	
	%% 6)  Seed on ghost Tets
    for i=1:size(Twg,1)   
    	if sum(ismember(Twg(i,:),XgID))>0 
        	[X,XgID]=SeedNodeTet(X,XgID,Twg(i,:),s);
     	end 
    end
    X(XgIDBB,:) = [];
    XgID = (nCells+1):size(X,1);
end


function [X,XgID]=SeedNodeTet(X,XgID,Twgi,h)
	XTet=X(Twgi,:);
	Center=1/4*(sum(XTet,1));
	nX=zeros(4,3);
	for i=1:4
    	vc=Center-XTet(i,:);
    	dis=norm(vc);
    	dir=vc/dis;
    	offset=h*dir;
    	if dis>norm(offset)
        	% offset
        	nX(i,:)=XTet(i,:)+offset;
    	else 
        	% barycenteric
        	nX(i,:)=XTet(i,:)+vc;
    	end      
	end 
	nX(ismember(Twgi,XgID),:)=[];
	nX=uniquetol(nX,1e-12*h,'ByRows',true);
	[nX]=CheckReplicateedNodes(X,nX,h);
	nXgID=size(X,1)+1:size(X,1)+size(nX,1);
	X=[X;nX];
	XgID=[XgID nXgID ];
end 


function  [X,XgID]=SeedNodeTri(X,XgID,Tri,h)
	XTri=X(Tri,:);
	Center=1/3*(sum(XTri,1));
	nX=zeros(3,3);
	for i=1:3
    	vc=Center-XTri(i,:);
    	dis=norm(vc);
    	dir=vc/dis;
    	offset=h*dir;
    	if dis>norm(offset)
        	% offset
        	nX(i,:)=XTri(i,:)+offset;
    	else 
        	% barycenteric
        	nX(i,:)=XTri(i,:)+vc;
    	end      
	end 
	
	nX(ismember(Tri,XgID),:)=[];
	nX=uniquetol(nX,1e-12*h,'ByRows',true);
	[nX]=CheckReplicateedNodes(X,nX,h);
	nXgID=size(X,1)+1:size(X,1)+size(nX,1);
	X=[X;nX];
	XgID=[XgID nXgID ];
end 

function  [X,XgID]=SeedNodeBar(X,XgID,Edge,h)
	XEdge=X(Edge,:);
	Center=1/2*(sum(XEdge,1));
	nX=zeros(2,3);
	for i=1:2
    	vc=Center-XEdge(i,:);
    	dis=norm(vc);
    	dir=vc/dis;
    	offset=h*dir;
    	if dis>norm(offset)
        	% offset
        	nX(i,:)=XEdge(i,:)+offset;
    	else 
        	% barycenteric
        	nX(i,:)=XEdge(i,:)+vc;
    	end      
	end 
	nX=unique(nX,'row');
	nXgID=size(X,1)+1:size(X,1)+size(nX,1);
	X=[X;nX];
	XgID=[XgID nXgID ]; Main
end 

function [nX]=CheckReplicateedNodes(X,nX,h)
	ToBeRemoved=false(size(nX,1),1);
	for jj=1:size(nX,1)
    	m=[X(:,1)-nX(jj,1) X(:,2)-nX(jj,2) X(:,3)-nX(jj,3)];
    	m=m(:,1).^2+m(:,2).^2+m(:,3).^2;
    	m=m.^(1/2);
    	m=min(m);
    	if m<1e-2*h
        	ToBeRemoved(jj)=true;
    	end 
	end 
	nX(ToBeRemoved,:)=[];
end 

function [Area]=AreTri(P1,P2,P3)
	Area =1/2*norm(cross(P2-P1,P3-P1));
end 