Geo = struct();

Set.tend=300;
Set.Nincr=300;
Set.BC = 2;
Set.dx = 1; % compression only (2 for stretching)
Set.VPrescribed = realmax;
Set.VFixd = -1;
% Set.VFixd = 0;

% Set.RemodelTol = 5.0000e-07;
Set.lambdaS1 = 1;
Set.lambdaS2 = 0.5; % compression only. 0.8 for stretch
Set.nu_LP_Initial = 20;
Set.ApplyBC=true;

Set.OutputFolder='Result/Compress';