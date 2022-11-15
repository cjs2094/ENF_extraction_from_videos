function func_simulateUsingVoltageMeasurement(ac_measured, fs, N0, N, R, tau, texp)

% %% use actual specifications to get a sense of estimating tau
% img = imread('.\imgs\imgs_set15\IMG_7884.jpg'); % one of the images from "imgs_set15"
% img_gray = double(rgb2gray(img));
% A_I_e = 7.13;
% I_dc = mean(img_gray(:));
% ratio = A_I_e/I_dc;
% %omega0 = 2*pi*60/fs; % wrong
% omega0 = 2*pi*60;
% texp = 1/165; % known
% tau = 1/(2*omega0) * sqrt((sin(omega0*texp)/(omega0*texp))^2/(ratio^2) - 1);


%% simulate physical embedding process

Ts = 1/fs;
v = ac_measured(N0 : N0 + N - 1);
p_l = v.^2/R;

% exponential window
t = 0 : Ts : 5*tau;
w_exp = exp(-t/tau);

% rect window
x = 0 : Ts : texp;
rect = @(x) 0.5*(sign(x) - sign(x - 1));
w_squared = rect(x/texp);
w_squared(1) = 1;

% time domain analysis
K_l = 1;% assumed
ell = K_l * conv(p_l, w_exp);
I = conv(ell, w_squared);

% for plotting purpose
N_start = 8000;
N_end = N_start + 6500;
time_ms = Ts*[N_start : N_end]*1000;
v_plot = v(N_start : N_end);
p_l_plot = p_l(N_start : N_end);
ell_plot = ell(N_start : N_end);
I_plot   = I(N_start : N_end);

v_range = max(v_plot) - min(v_plot);
p_l_plot_range = max(p_l_plot) - min(p_l_plot);
ell_plot_range = max(ell_plot) - min(ell_plot);
I_plot_range = max(I_plot) - min(I_plot);

p_l_plot = v_range/p_l_plot_range*p_l_plot;
ell_plot = v_range/ell_plot_range*ell_plot;
I_plot = v_range/I_plot_range*I_plot;


figure;
plot(time_ms, I_plot + 0.05, '-g', 'LineWidth', 1.2); hold on;
plot(time_ms, ell_plot + 0.1, ':r', 'LineWidth', 1.5);
plot(time_ms, p_l_plot, '--b', 'LineWidth', 1.2);
plot(time_ms, v_plot, '-k', 'LineWidth', 1.2); hold off;
grid on;
xlabel('Time (ms)', 'FontSize', 11);
xlim([time_ms(1) time_ms(end)]); ylim([-0.1 0.6]);
set(gcf, 'position', [0, 0, 500, 320])  % create new figure with specified size
legend('pixel intensity $I(t)$', 'illuminance $\ell(t)$', 'inst power $p_l(t)$',...
    'voltage $v(t)$', 'FontSize', 11, 'interpreter', 'latex', 'location', 'best', 'NumColumns', 2)
set(gca, 'FontName', 'Times')
func_tightfig;



