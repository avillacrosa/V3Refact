clc; close all; clear;
load('flip32data.mat');
t=122;
numStep=1;
flip32(Geo_n, Geo, Dofs, Set);
