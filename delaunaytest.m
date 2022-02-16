rng default;
x = rand([20,1]);
y = rand([20,1]);
z = rand([20,1]);
DT = delaunay(x,y,z);
% triplot(DT,x,y);
trisurf(DT,x,y,z);
hold on

DT2 = delaunay(x+1,y+1,z);
% triplot(DT2,x+1,y+1);
trisurf(DT2,x+1,y+1,z);