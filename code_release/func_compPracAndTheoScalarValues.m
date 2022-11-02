function func_compPracAndTheoScalarValues (x0_dir, x0_zero, paras, m_array_dir, m_array_zero)

frameRate   = paras.frameRate;
nominalFreq = paras.nominalFreq;
Tro         = paras.Tro;
fs_rounded  = paras.fs_rounded;
fps_rounded = paras.fps_rounded;

freq_band = 2;
freq_range = 0.5;

target_freq_dir_array  = [];
target_freq_zero_array = [];
P_sig_dir_array = [];
P_sig_zero_array = [];


%% target frequencies

for i = 1 : length(m_array_dir)
    m = m_array_dir(i);
    
    if mod(i, 3) == 1
        target_freq_dir = 2*nominalFreq + m*frameRate;
    elseif mod(i, 3) == 2
        target_freq_dir = m*frameRate;
    elseif mod(i, 3) == 0
        target_freq_dir = -2*nominalFreq + m*frameRate;
    end
    
    if target_freq_dir < 0
        target_freq_dir = -target_freq_dir;
    end
    
    target_freq_dir_array(i) = target_freq_dir;
end

for i = 1 : length(m_array_zero)
    m = m_array_zero(i);
    
    if mod(i, 3) == 1
        target_freq_zero = 2*nominalFreq + m*frameRate;
    elseif mod(i, 3) == 2
        target_freq_zero = m*frameRate;
    elseif mod(i, 3) == 0
        target_freq_zero = -2*nominalFreq + m*frameRate;
    end
    
    if target_freq_zero < 0
        target_freq_zero = -target_freq_zero;
    end
    
    target_freq_zero_array(i) = target_freq_zero;
end


%% empirical mag

for i =1:length(target_freq_dir_array)
    extra_param.logFreqForInterp = false;   
    [Psig_W_dir, ~, ~, ~]  = func_measureEmpiricalSNR(x0_dir, fps_rounded, target_freq_dir_array(i), freq_band, freq_range);
    [Psig_W_zero, ~, ~, ~] = func_measureEmpiricalSNR(x0_zero, fs_rounded, target_freq_zero_array(i), freq_band, freq_range);

    P_sig_dir_array  = [P_sig_dir_array Psig_W_dir];
    P_sig_zero_array = [P_sig_zero_array Psig_W_zero];
end

P_sig_dir_array  = P_sig_dir_array(:);
P_sig_zero_array = P_sig_zero_array(:);

kk = 1;
for i = 1 : length(P_sig_dir_array)
    if mod(i,3) ~= 2
        P_sig_dir_array_nonDC(kk) = P_sig_dir_array(i);
        kk = kk + 1;
    end
end

kk = 1;
for i = 1 : length(P_sig_zero_array)
    if mod(i,3) ~= 2
        P_sig_zero_array_nonDC(kk) = P_sig_zero_array(i);
        kk = kk + 1;
    end
end

P_sig_dir_array_nonDC  = P_sig_dir_array_nonDC(:);
P_sig_zero_array_nonDC = P_sig_zero_array_nonDC(:);

Am_practical_array_nonDC       = sqrt(P_sig_dir_array_nonDC);
Am_prime_practical_array_nonDC = sqrt(P_sig_zero_array_nonDC);

%% theoretical mag

L   = paras.height;
M   = L/(Tro*frameRate); 
fs  = L/Tro;

Am       = [];
Am_prime = [];

for i = 1 : length(target_freq_dir_array)
    f = target_freq_dir_array(i);
    m = m_array_dir(i);

    x = (M/L - 1)*(2*pi*f/fs) + (2*pi*m/M);
    asinc_L = sin(L*x/2)./(L*sin(x/2));
    Am_temp = abs(L/M*asinc_L.*exp(-j*(L - 1)/2.*x));
    Am(i) = Am_temp; 
end

for i = 1 : length(target_freq_zero_array)
    m = m_array_zero(i);

    x = 2*pi*m/M;
    if x == 0
        asinc_L = 1;
    else
        asinc_L = sin(L*x/2)./(L*sin(x/2));
    end
    
    Am_prime_temp = abs(L/M*asinc_L.*exp(-j*pi*m/M*(L - 1)));
    Am_prime(i) = Am_prime_temp; 
end

Am = Am(:);
Am_prime = Am_prime(:);

kk = 1;
for i = 1 : length(Am)
    if mod(i, 3) ~= 2
        Am_nonDC(kk) = Am(i);
        kk = kk + 1;
    end
end

kk = 1;
for i = 1 : length(Am_prime)
    if mod(i,3) ~= 2
        Am_prime_nonDC(kk) = Am_prime(i);
        kk = kk + 1;
    end
end

Am_nonDC       = Am_nonDC(:);
Am_prime_nonDC = Am_prime_nonDC(:);


%% plot practical scalar values versus theoretical scalar values for all aliased ENF components

% perform linear regression
[~, x_line, y_line] = func_linearRegression(Am_practical_array_nonDC, Am_nonDC);

fontSize_label = 14;

figure;
movegui('onscreen')
plot(Am_practical_array_nonDC, Am_nonDC, 'ko', 'linewidth', 1.8); hold on
plot(x_line, y_line, 'k--', 'linewidth', 1.8); hold off
grid on;
legend('data', 'linear regression line', 'FontSize', 12, 'location', 'southeast');
xlim([min(Am_practical_array_nonDC(:)), max(Am_practical_array_nonDC(:))]);
xlabel('Practical magnitude', 'FontSize', fontSize_label);
ylabel('Theoretical magnitude', 'FontSize', fontSize_label);
title('Practical mag by direct concatenation vs. theoretical mag');

% perform linear regression
[~, x_line, y_line] = func_linearRegression(Am_prime_practical_array_nonDC, Am_prime_nonDC);

figure; movegui('onscreen')
plot(Am_prime_practical_array_nonDC, Am_prime_nonDC, 'ko', 'linewidth', 1.8); hold on
plot(x_line, y_line, 'k--', 'linewidth', 1.8); hold off
grid on;
legend('data', 'linear regression line', 'FontSize', 12, 'location', 'southeast');
xlim([min(Am_prime_practical_array_nonDC(:)), max(Am_prime_practical_array_nonDC(:))]);
xlabel('Practical magnitude', 'FontSize', fontSize_label);
ylabel('Theoretical magnitude', 'FontSize', fontSize_label);
title('Practical mag by periodic zeroing-out vs. theoretical mag');


%% plot log scale ver.

% perform linear regression
[~, x_line, y_line] = func_linearRegression(Am_practical_array_nonDC, Am_nonDC);

figure;
movegui('onscreen')
loglog(Am_practical_array_nonDC, Am_nonDC, 'ko', 'linewidth', 1.8); hold on
loglog(x_line, y_line, 'k--', 'linewidth', 1.8); hold off
grid on;
legend('data', 'linear regression line', 'FontSize', 12, 'location', 'southeast');
xlim([min(Am_practical_array_nonDC(:)), max(Am_practical_array_nonDC(:))]);
xlabel('Practical magnitude', 'FontSize', fontSize_label);
ylabel('Theoretical magnitude', 'FontSize', fontSize_label);
title('Practical mag by direct concatenation vs. theoretical mag (log scales)');

% perform linear regression
[~, x_line, y_line] = func_linearRegression(Am_prime_practical_array_nonDC, Am_prime_nonDC);

figure;
movegui('onscreen')
loglog(Am_prime_practical_array_nonDC, Am_prime_nonDC, 'ko', 'linewidth', 1.8); hold on
loglog(x_line, y_line, 'k--', 'linewidth', 1.8); hold off
grid on;
legend('data', 'linear regression line', 'FontSize', 12, 'location', 'southeast');
xlim([min(Am_prime_practical_array_nonDC(:)), max(Am_prime_practical_array_nonDC(:))]);
xlabel('Practical magnitude', 'FontSize', fontSize_label);
ylabel('Theoretical magnitude', 'FontSize', fontSize_label);
title('Practical mag by periodic zeroing-out vs. theoretical mag (log scales)');

