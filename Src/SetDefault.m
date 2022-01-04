function Set = SetDefault(Set)
    DSet = struct();
    %% =============================  Topology ============================
    DSet.SeedingMethod				= 1;
    DSet.s							= 1.5;
    DSet.ObtainX					= 0;
    %% 2D input image to obtain  the initial topology of the cells
    DSet.InputSegmentedImage		= [];
    DSet.CellAspectRatio			= 1;
    DSet.zScale						= 1;
    DSet.TotalCells					= 9;
    %% ===========================  Add Substrate =========================
    DSet.Substrate					= false;
    DSet.kSubstrate					= 0;
    %% ============================ Time ==================================
    DSet.tend						= 200;
    DSet.Nincr						= 200;
    %% ============================ Mechanics =============================
    DSet.lambdaV					= 1;
    DSet.lambdaV_Debris				= 0.001;
    DSet.SurfaceType				= 1;
    DSet.A0eq0						= true;
    DSet.lambdaS1					= 0.5;
    DSet.lambdaS2					= 0.1;
    DSet.lambdaS1CellFactor			= [];
    DSet.lambdaS2CellFactor			= [];
    DSet.lambdaS3CellFactor			= [];
    DSet.lambdaS4CellFactor			= [];
    DSet.EnergyBarrier				= true;
    DSet.lambdaB					= 5;
    DSet.Beta						= 1;
    DSet.Bending					= false;
    DSet.lambdaBend					= 0.01;
    DSet.BendingAreaDependent		= true;
    DSet.Propulsion					= false;
    DSet.Confinement				= false;
    %% ============================ Viscosity =============================
    DSet.nu							= 0.05;
    DSet.LocalViscosityEdgeBased	= false;
    DSet.nu_Local_EdgeBased			= 0;
    DSet.LocalViscosityOption		= 2;
    %% =========================== Remodelling ============================
    DSet.Remodelling				= true;
    DSet.RemodelTol					= .5e-6;
    DSet.RemodelingFrequency		= 2;
    %% ============================ Solution ==============================
    DSet.tol						= 1e-10;
    DSet.MaxIter					= 200;
    DSet.Parallel					= false;
    DSet.Sparse						= false;
    %% ================= Boundary Condition and loading setting ===========
    DSet.BC							= 1;
    DSet.VFixd						= -1.5;
    DSet.VPrescribed				= 1.5;
    DSet.dx							= 2;
    DSet.TStartBC					= 20;
    DSet.TStopBC					= 200;
	%% =========================== PostProcessing =========================
    DSet.diary						= false;
    DSet.OutputRemove				= true;
    DSet.VTK						= true;
    DSet.gVTK						= false;
    DSet.VTK_iter					= false;
% 	DSet.analysisDir				= strcat(Set.OutputFolder,Esc,'Analysis',Esc);
	DSet.SaveWorkspace				= false;
	DSet.SaveSetting				= false;
	%% ====================== Add missing fields to Set ===================
	Set = addDefault(Set, DSet);
	%% ========================= Derived variables ========================
    Set.lambdaS3					= Set.lambdaS2;
    Set.lambdaS4					= Set.lambdaS2;
    Set.f							= Set.s/2;
    Set.CellHeight					= DSet.CellAspectRatio*DSet.zScale; %!
    Set.nu_LP_Initial				= 50*Set.nu; %!
    Set.BarrierTri0					= 1e-3*Set.s; %!
	Set.nu0                         = Set.nu;
	Set.dt0=Set.tend/Set.Nincr;
	Set.dt=Set.dt0;
end