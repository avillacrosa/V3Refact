clc; clear; close all

X = BuildTopo(3, 3, 0);

[XgID, X] = SeedWithBoundingBox(X,1.5);