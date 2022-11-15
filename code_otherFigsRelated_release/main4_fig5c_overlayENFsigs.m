clear all; close all; clc;

%% show fig. 5.(c) of the paper - overlay averaged and detrended averaged column signals

img_db_path = '.\imgs_set\';
K = 200; % number of signals to be overlayed

func_overlayAveragedAndDetrendedAveragedColSigs(img_db_path, K);
