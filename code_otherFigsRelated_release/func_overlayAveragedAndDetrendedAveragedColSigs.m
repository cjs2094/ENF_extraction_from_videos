function func_overlayAveragedAndDetrendedAveragedColSigs(img_db_path, K)

[num_of_total_imgs, col_sig_arr, img_size] = func_extractAvgColSigsFromImgSet(img_db_path);

% random image selection

ind_arr = randperm(num_of_total_imgs, K);
col_sig_arr_random = col_sig_arr(:, ind_arr);

% remove the linear trend from the col signals (detrending)
for m = 1 : size(col_sig_arr_random, 2)
    temp = detrend(col_sig_arr_random(:, m), 1);
    detrended_col_sig_arr_random(:, m) = temp(:);
end

% return envelopes
yRange = 20;
N_tap = 1300;
[env_upper, env_lower] = envelope(detrended_col_sig_arr_random, N_tap, 'peak');
env_upper_mean = mean(env_upper, 2);
env_lower_mean = mean(env_lower, 2);



%% show fig 5.(c) of the paper

figure;
hAxis(1) = subplot(2, 1, 1);
for m = 1 : size(col_sig_arr_random, 2)
    plot(1:img_size(1), col_sig_arr_random(:, m)); hold on;
end
hold off; grid on;
xticks([]);
xlim([1 img_size(1)]); ylim([0 50]);
%xlabel('Row index', 'fontsize', 15, 'interpreter', 'latex');

hAxis(2) = subplot(2, 1, 2);
for m = 1 : size(detrended_col_sig_arr_random, 2)
    plot(1:img_size(1), detrended_col_sig_arr_random(:, m)); hold on;
end
plot(1:img_size(1), env_upper_mean, 'r-', 'Linewidth', 3);
h(1)=plot(1:img_size(1), env_lower_mean, 'r-', 'Linewidth', 3); hold off;
legend(h([1]), 'upper & lower envelopes');
%pt_x = 100; pt_y = -yRange + 2 * yRange * 0.1;
%text(pt_x, pt_y, ['$L_{0,r}$/$L_{j,r}$ = ' num2str(a_ratio)], 'Color', 'red', 'FontSize', 14, 'interpreter', 'latex');
grid on;
xlabel('Row index', 'fontsize', 11);
xlim([1 img_size(1)]); ylim([-yRange+2 yRange-2]);
pos = get(hAxis(1), 'Position');
pos(2) = 0.5 ;                         % Shift down.
%pos(4) = 0.4 ;                        % Increase height.
set( hAxis(1), 'Position', pos ) ;
set(gcf, 'position', [0, 0, 400, 330])
func_tightfig;


