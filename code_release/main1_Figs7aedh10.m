clear all; clc; close all;

%% set parameters

% NOTE1: Fig.7.(a)(e)(d)(h) was generated using 'iPhoneVideo8'
% NOTE2: Fig.10 was generated using 'iPhoneVideo0'

% choose video
videoFileName = ['iPhoneVideo8'];

% define variables
nfft          = 2^15;
frameSize     = 12000; % ms
overlapRatio  = 0.9;


%% [step 1] generate or load row signals

videoFileLocation = [pwd, '\vids\', videoFileName];

[~, ~, rowSig_dirConcat_1k, rowSig_zeroingOut_1k, paras]...
    = func_linearizationWithDirConcatAndZeroingOut(videoFileLocation, videoFileName);

x_dir  = rowSig_dirConcat_1k;
x_zero = rowSig_zeroingOut_1k;


%% [step 2] draw spectrogram - related to Fig.7(a)(e) in the paper

func_drawSpectrograms(x_dir, x_zero, paras.fs_downsampled, paras.frameRate, nfft, frameSize, overlapRatio);


%% [step 3] extract ENF signals with SNR - related to Fig.7(d)(h), Fig. 10 in the paper 

func_extractEnfSig(videoFileLocation, videoFileName, x_dir, x_zero, paras, frameSize, overlapRatio);





