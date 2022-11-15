clear all; close all; clc;

%% read supply voltage measurment

[ac_measured, fs] = audioread(['.\data\power_test1.wav']);

N0 = 1;
N = 100000;

% set parameters
R = 10;
tau = 0.0019;
texp = 0.040;


%% show fig. 4 of the paper

func_genSimulatedPixelIntensitySignals(ac_measured, fs, N0, N, R, tau, texp);

