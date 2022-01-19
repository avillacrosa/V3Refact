Geo.nx = 1;
Geo.ny = 3;

Set.lambdaV = 5;

Set.tend=50;
Set.Nincr=50;
Set.BC = 1;
Set.dx = 2; 

Set.mu_bulk     = 0; % deformation term
Set.lambda_bulk = 1e-4; % volume term
Set.InPlaneElasticity = true;

Set.lambdaS1 = 1;
Set.lambdaS2 = 0.8; 
Set.tol = 1e-7;
Set.OutputFolder='Result/StretchBulk';