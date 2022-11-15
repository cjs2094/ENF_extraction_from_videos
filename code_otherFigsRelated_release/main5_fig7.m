%% show fig. 7(a)

img = imread('.\data\fig1a.jpg');
[img, dim] = func_putImgToLandscape(img);
img_gray = double(rgb2gray(img));

y21_s = 1;
y21_t = 3024;
x21_s = 1;
x21_t = 500;
y22_s = 1;
y22_t = 3024;
x22_s = 501;
x22_t = 4032;

figure;
imshow(img); hold on;
rectangle('Position', [x21_s, y21_s, x21_t - x21_s, y21_t - y21_s], 'EdgeColor', 'k', 'LineWidth', 3, 'LineStyle', '--');
rectangle('Position', [x22_s, y22_s, x22_t - x22_s, y22_t - y22_s], 'EdgeColor', 'r', 'LineWidth', 3, 'LineStyle', '-'); hold off;


%% show fig. 7(b)

rows = 1:size(img_gray, 1);

figure;
plot(rows, img_gray(:, 2000), 'r'); hold on;
plot(rows, img_gray(:, 300), 'k'); hold off;
grid on;
legend('nonsmooth region', 'smooth region', 'fontsize', 14)
xlim([0 3024]); ylim([0 255]);
xlabel('Row index', 'fontsize', 18);
ylabel('Pixel intensity', 'fontsize', 18);


