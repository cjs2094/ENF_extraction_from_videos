%% show fig. 1(d)

clear all; close all; clc;

img = imread('.\data\fig1a.jpg');
img_gray = double(rgb2gray(img));
enf_raw1 = mean(img_gray, 2);

img = imread('.\data\fig1b.jpg');
img_gray = double(rgb2gray(img));
enf_raw2 = mean(img_gray, 2);

img = imread('.\data\fig1c.jpg');
img_gray = double(rgb2gray(img));
enf_raw3 = mean(img_gray, 2);

rows = 1:size(img_gray,1);

figure;
plot(rows, enf_raw1, 'k', 'LineWidth', 1); hold on;
plot(rows, enf_raw2, 'b--', 'LineWidth', 1);
plot(rows, enf_raw3, 'r:', 'LineWidth', 1.5); hold off;
grid on;
legend('Fig. 1(a)', 'Fig. 1(b)', 'Fig. 1(c)', 'fontsize', 14)
xlim([0 rows(end)]); ylim([0 255]);
xlabel('Row index', 'fontsize', 18);
ylabel('Averaged column values', 'fontsize', 18);


%% show fig. 1(e)

% load entropy mini results applied on figs
load('.\data\res_60Hz_Jisoo8_fitting_results_flag0_colRandOnOverall_cols32.mat');

enf_est_sinusoidal1 = test_results(6).sinusoidalPartEnf_entropy;
enf_est_sinusoidal2 = test_results(11).sinusoidalPartEnf_entropy;
enf_est_sinusoidal3 = test_results(1).sinusoidalPartEnf_entropy;

figure;
plot(rows, enf_est_sinusoidal1, 'k', 'LineWidth', 1); hold on;
plot(rows, enf_est_sinusoidal2, 'b--', 'LineWidth', 1);
plot(rows, enf_est_sinusoidal3, 'r:', 'LineWidth', 1.5); hold off;
grid on;
legend('Fig. 1(a)', 'Fig. 1(b)', 'Fig. 1(c)', 'fontsize', 14)
xlim([0 rows(end)]); ylim([-60 60]);
xlabel('Row index', 'fontsize', 18);
ylabel('Sinusoidal part of estimated ENF traces', 'fontsize', 16);


