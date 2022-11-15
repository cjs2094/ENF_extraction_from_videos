function func_genSimulatedPixelIntensitySignals(ac_measured, fs, N0, N, R, tau, texp)

v = ac_measured(N0 : N0 + N - 1);
Ts = 1/fs;
time_ms = Ts*[1 : N]*1000; % ms


%% tau estimate
%img = imread('.\imgs\imgs_set20\IMG_8701.jpg');
%img = imread('.\imgs\imgs_set15\IMG_7884.jpg');
%img_gray = double(rgb2gray(img));

% use specifications for "imgs_set20" as below
% ac = 0.03;
% dc = mean(double(img(:)));
%A_I_e = 7.13;
%I_dc = mean(img_gray(:));
 % assumed
%ratio = ac/dc;
%ratio = A_I_e/I_dc;
%omega0 = 2*pi*60;
% t_exp = 1/198; % 5*10^{-3} sec
%t_exp = 1/165;

%tau = 1/(2*omega0) * sqrt((sin(omega0*texp)/(omega0*texp))^2/(ratio^2) - 1);

 
%% voltage preprocess

% voltage with constant frequency and amplitude (CFCA)
[v_fitted] = func_genACVolWithCFCA(v);

% voltage with varying frequency and constant amplitude (VFCA)
frame_size = 300; % reasonable value: frame_size = 735 for fs = 44100 Hz
[v_fitted_segBySegWithVaryingFreqAndFixedAmp] = func_genACVolWithVFCA(v, frame_size);

% voltage with varying frequency and amplitude (VFVA)
[v_fitted_segBySegWithVaryingFreqAndAmp] = func_genACVolWithVFVA(v, frame_size);

% fn0 = ['.\mat_results\mat_' audioName '.mat'];
% save(fn0, 'v', 'fs', 'v_fitted', 'frame_size', 'v_fitted_segBySegWithVaryingFreqAndFixedAmp',...
%   'v_fitted_segBySegWithVaryingFreqAndAmp');


%% simulate pixel intensity signals

for i = 0 : 3
  
  if i == 0
    p_supply = v.^2 / R;
  elseif i == 1
    p_supply = v_fitted.^2 / R;
  elseif i == 2
    p_supply = v_fitted_segBySegWithVaryingFreqAndFixedAmp.^2 / R;
  elseif i == 3
    p_supply = v_fitted_segBySegWithVaryingFreqAndAmp.^2 / R;
  end
  
  t = 0 : Ts : 1;
  
  % exponential window
  w_exp = exp(-t/tau);
  
  % create a rect window
  x = 0 : Ts : texp;
  rect = @(x) 0.5*(sign(x) - sign(x-1));
  w_squared = rect(x/texp);
  w_squared(1) =1;
  
  % time domain analysis
  y1 = conv(p_supply, w_exp);
  y2 = conv(y1, w_squared);
  
  if i == 0
    I_0 = y2;
  elseif i == 1
    I_1 = y2;
  elseif i == 2
    I_2 = y2;
  elseif i == 3
    I_3 = y2;
  end
  
end

len = length(I_0);
time_ms = Ts*[1 : len]*1000; % ms

%% show fig. 4.(a) of the paper

% figure;
% plot(time_ms, I_0, 'k')
% grid on;
% xlabel('Time (ms)', 'FontSize', 18', 'interpreter', 'latex');
% ylabel('$\ell(t)$', 'FontSize', 18, 'interpreter', 'latex');
% set(gcf, 'position', [0, 0, 500, 200])  % create new figure with specified size


Nmin = min([length(I_1) length(I_2) length(I_3)]);
time_ms = Ts*[1 : Nmin]*1000; % ms


figure;
plot(time_ms, I_2(1 : Nmin), 'r'); hold on;
plot(time_ms, I_3(1 : Nmin) - 2, 'b');
plot(time_ms, I_1(1 : Nmin) - 4, 'k'); hold off;
grid on;
xlim([500 1800]); ylim([29.5 38]);
xlabel('Time (ms)', 'fontsize', 18, 'interpreter', 'latex');
ylabel('Pixel intensity signal $I(t)$', 'fontsize', 18, 'interpreter', 'latex');
legend('\textrm{VarFreq-ConAmp}', '\textrm{VarFreq-VarAmp}', '\textrm{ConFreq-ConAmp}',...
  'fontsize', 14, 'interpreter', 'latex')
set(gcf, 'position', [0, 0, 500, 400])
%tightfig;


% %% one segment
% 
% figure;
% plot(time_ms, I_3(1:Nmin), 'b');
% xlim([1840 1870])
% ylim([29 40])
% grid on;
% xlabel('Time (ms)', 'fontsize', 18, 'interpreter', 'latex');
% ylabel('Pixel intensity signal $I(t)$', 'fontsize', 18, 'interpreter', 'latex');
% set(gcf, 'position', [0, 0, 500, 400]);


%% show fig. 4.(b) of the paper - multiple segments

y_min = 33.2;
y_max = 36;

figure;
subplot(3, 1, 1)
cycle = 2;
n_st = 80000;
n_ed = n_st + round((735/2)*cycle);
t_st = time_ms(n_st);
t_ed = time_ms(n_ed);
plot(time_ms - t_st, I_2(1 : Nmin), 'r'); hold on;
plot(time_ms - t_st, I_3(1 : Nmin) - 0.3, 'b'); hold off;
x_min = t_st - t_st;
x_max = t_ed - t_st; 
xlim([x_min x_max]); ylim([y_min y_max]);
grid on;
text(0.83*x_max, y_min + 0.85*(y_max - y_min), [num2str(cycle), ' cycles']);

subplot(3, 1, 2)
cycle = 2.5;
n_st = 11000;
n_ed = n_st + round((735/2)*cycle);
t_st = time_ms(n_st);
t_ed = time_ms(n_ed);
plot(time_ms - t_st, I_2(1 : Nmin), 'r'); hold on;
plot(time_ms - t_st, I_3(1 : Nmin) - 0.5, 'b'); hold off;
x_min = t_st - t_st;
x_max = t_ed - t_st; 
xlim([x_min x_max]); ylim([y_min y_max]);
grid on;
text(0.83*x_max, y_min + 0.85*(y_max - y_min), [num2str(cycle), ' cycles']);

subplot(3, 1, 3)
cycle = 3;
n_st = 13000;
n_ed = n_st + round((735/2)*cycle);
t_st = time_ms(n_st);
t_ed = time_ms(n_ed);
plot(time_ms - t_st, I_2(1 : Nmin), 'r'); hold on;
plot(time_ms - t_st, I_3(1 : Nmin)-0.3, 'b'); hold off;
x_min = t_st - t_st;
x_max = t_ed - t_st; 
xlim([x_min x_max]); ylim([y_min y_max]);
grid on;
text(0.83*x_max, y_min + 0.85*(y_max - y_min), [num2str(cycle), ' cycles']);
xlabel('Time (ms)', 'fontsize', 18, 'interpreter', 'latex');
set(gcf, 'position', [0, 0, 500, 400])


