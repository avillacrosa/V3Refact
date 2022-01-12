Geo = struct();

Set.tend=300;
Set.Nincr=400;
Set.BC = 2;
Set.dx = 1; % compression only (2 for stretching)
Set.VPrescribed = 200;
Set.VFixd = -1;

Set.lambdaS1 = 1;
Set.lambdaS2 = 0.5; % compression only. 0.8 for stretch
Set.tol = 1e-14;

Set.ApplyBC=true;

Set.OutputFolder='Result/Compress';