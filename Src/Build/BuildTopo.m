function X = buildTopo()
    X=0;
    Y=0:2;
    [X,Y]=meshgrid(X,Y);
    X=reshape(X,size(X,1)*size(X,2),1);
    Y=reshape(Y,size(Y,1)*size(Y,2),1);
    X=[X Y zeros(length(X),1)+rand(length(X),1)*0];
end