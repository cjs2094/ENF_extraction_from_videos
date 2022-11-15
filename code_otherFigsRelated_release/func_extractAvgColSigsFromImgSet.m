function [num_of_total_imgs, col_sig_arr, img_size] = func_extractAvgColSigsFromImgSet(img_db_path)
%% 08/01/2019, Jisoo Choi

D = dir([img_db_path '*.jpg']);
num_of_total_imgs = length(D);
img_size = [];
col_sig_arr = [];

t_start = tic;
for m = 1 : num_of_total_imgs
    fn = [D(m).folder '\' D(m).name];
    img_rgb = imread(fn);
    img_rgb = func_putImgToLandscape(img_rgb);
    img_gray = double(rgb2gray(img_rgb));
    
    col_sig = mean(img_gray, 2);
    col_sig_arr(:, m) = col_sig(:);
    
    %% show progress
    if mod(m, 49) == 0
        t_passed = toc(t_start);
        eta = m / num_of_total_imgs;
        t_remaining = t_passed / eta - t_passed;
        disp(sprintf('time remaining: %.0f secs', t_remaining));
    end
end

img_size = size(img_gray);
