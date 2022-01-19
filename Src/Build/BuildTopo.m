function X = BuildTopo(nx, ny, nz)
	X = 0:(nx-1);
	Y = 0:(ny-1);
	[X,Y] = meshgrid(X,Y);
	X=reshape(X,size(X,1)*size(X,2),1);
    Y=reshape(Y,size(Y,1)*size(Y,2),1);
	X=[X Y zeros(length(X),1)];
end