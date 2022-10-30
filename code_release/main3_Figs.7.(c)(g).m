clear all; clc; close all;

%% set parameters

% NOTE: Figs.7.(c)(g) were generated using 'iPhoneVideo8'

% choose video
videoFileName = ['iPhoneVideo8'];

% define variables
nfft         = 2^15;
frameSize    = 12000; % ms
overlapRatio = 0.9;

%% [step 1] generate or load row signals

videoFileLocation = [pwd, '\vids\', videoFileName];

[rowSig_dirConcat, rowSig_zeroingOut, ~, ~, paras]...
    = func_linearizationWithDirConcatAndZeroingOut (videoFileLocation, videoFileName);

x0_dir  = rowSig_dirConcat;
x0_zero = rowSig_zeroingOut;


%% [step 2] compare practical scalar values versus theoretical scalar values for all aliased ENF components - related to Fig.7.(c)(g)

% NOTE: m_array_dir, m_array_zero should be manually assigned by user and they have
% to be of the same size. The assignment of the following m_array_dir,
% m_array_zero is only for 'iPhoneVideo8', which is detailed in Figs.7.(b)(f) in the paper.

m_array_dir  = [-1 4 9 -2 3 8 -3 2 7 -4 1 6]; % Refer to Fig.7.(b). The order of elements should be for +ve, dc, -ve, +ve, dc, ...
m_array_zero = [2 7 12 1 6 11 0 5 10 -1 4 9]; % Refer to Fig.7.(f). The order of elements should be for +ve, dc, -ve, +ve, dc, ...

func_compPracAndTheoScalarValues (x0_dir, x0_zero, paras, m_array_dir, m_array_zero);








