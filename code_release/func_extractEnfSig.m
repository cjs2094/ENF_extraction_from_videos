function func_extractEnfSig (videoFileLocation, videoFileName, x_dir, x_zero, paras, frameSize, overlapRatio)

fs          = paras.fs_downsampled;
frameRate   = paras.frameRate;
nominalFreq = paras.nominalFreq;
Tro         = paras.Tro;

freq_band = 2;
freq_range = 0.5;
enbRemoveOutliers = 1;
overlapAmount  = frameSize * overlapRatio;

targetFreq_dir_array =[];
targetFreq_zero_array =[];
enf_audio_dir_array = [];
enf_audio_zero_array = [];
SNR_dB_dir_array = [];
SNR_dB_zero_array = [];

for i = -1 : 1 : 1
    targetFreq_dir_temp   = 2*nominalFreq + round((Tro - 1/frameRate)*2*nominalFreq + i)*frameRate;
    targetFreq_zero_temp  = 2*nominalFreq + i*frameRate; 
    targetFreq_dir_array  = [targetFreq_dir_array targetFreq_dir_temp];
    targetFreq_zero_array = [targetFreq_zero_array targetFreq_zero_temp];
end


extra_param.logFreqForInterp = false;
for i = 1:length(targetFreq_dir_array)
    [enf_audio_dir, ~, localSNR_dB_dir]   = func_freqEstQuadWithSNR (x_dir, fs, frameSize, overlapAmount, targetFreq_dir_array(i), freq_band, freq_range, extra_param);    
    [enf_audio_zero, ~, localSNR_dB_zero] = func_freqEstQuadWithSNR (x_zero, fs, frameSize, overlapAmount, targetFreq_zero_array(i), freq_band, freq_range, extra_param);
    
    if enbRemoveOutliers == 1
        enf_audio_dir = func_removeOutliers(enf_audio_dir);
        enf_audio_zero = func_removeOutliers(enf_audio_zero);
    end
    
    enf_audio_dir_array = [enf_audio_dir_array enf_audio_dir];
    enf_audio_zero_array = [enf_audio_zero_array enf_audio_zero];

    SNR_dB_dir_array = [SNR_dB_dir_array localSNR_dB_dir];
    SNR_dB_zero_array = [SNR_dB_zero_array localSNR_dB_zero];
end



%% extract strongest ENF signals by each method and its neighboring ENF signals

shiftAmount    = frameSize - overlapAmount;
frameSize_secs = frameSize/fs;
overlap_size_secs = overlapAmount/fs;
nb_of_frames1 = ceil((length(x_dir) - frameSize + 1)/shiftAmount);
nb_of_frames2 = ceil((length(x_zero) - frameSize + 1)/shiftAmount);
time_vector1 = 0:nb_of_frames1 - 1;
time_vector1 = (frameSize_secs - overlap_size_secs) / 60 * time_vector1;
time_vector2 = 0:nb_of_frames2 - 1;
time_vector2 = (frameSize_secs - overlap_size_secs) / 60 * time_vector2;

fontSize = 14;
fontSize_title = 12;


figure;
movegui('onscreen')
subplot(3,1,1);
x_txt = time_vector1;
y_txt = enf_audio_dir_array(:,3);
plot(time_vector1, enf_audio_dir_array(:,3), 'k', 'linewidth',0.5);
text(x_txt(10), min(y_txt)+0.005, ['local SNR=',num2str(SNR_dB_dir_array(3),'%.1f'),' dB'], 'fontSize', fontSize_title);
xlim([0 max(time_vector1)]); ylim([min(y_txt)-0.005 max(y_txt)+0.005]);
xlabel('Time (min)', 'fontSize', fontSize); ylabel('Freq (Hz)', 'fontSize', fontSize);
grid on;
subplot(3,1,2);
y_txt = enf_audio_dir_array(:,2);
plot(time_vector1, enf_audio_dir_array(:,2), 'k', 'linewidth',0.5);
text(x_txt(10), min(y_txt)+0.005, ['local SNR=',num2str(SNR_dB_dir_array(2),'%.1f'),' dB'], 'fontSize', fontSize_title);
xlim([0 max(time_vector1)]); ylim([min(y_txt)-0.005 max(y_txt)+0.005]);
xlabel('Time (min)', 'fontSize', fontSize); ylabel('Freq (Hz)', 'fontSize', fontSize);
grid on;
subplot(3,1,3);
y_txt = enf_audio_dir_array(:,1);
plot(time_vector1, enf_audio_dir_array(:,1), 'k', 'linewidth',0.5);
text(x_txt(10), min(y_txt)+0.01, ['local SNR=',num2str(SNR_dB_dir_array(1),'%.1f'),' dB'], 'fontSize', fontSize_title);
xlim([0 max(time_vector1)]); ylim([min(y_txt)-0.005 max(y_txt)+0.005]);
xlabel('Time (min)', 'fontSize', fontSize); ylabel('Freq (Hz)', 'fontSize', fontSize);
sgtitle({'Theoretically strongest ENF signal and ', 'its neighboring ENF signals by direct concatenation'});
grid on;


figure;
movegui('onscreen')
subplot(3,1,1);
x_txt = time_vector2;
y_txt = enf_audio_zero_array(:,3);
plot(time_vector2, enf_audio_zero_array(:,3), 'k', 'linewidth',0.5);
text(x_txt(10), min(y_txt)+0.005, ['local SNR=',num2str(SNR_dB_zero_array(3),'%.1f'),' dB'], 'fontSize', fontSize_title);
xlim([0 max(time_vector2)]); ylim([min(y_txt)-0.005 max(y_txt)+0.005]);
xlabel('Time (min)', 'fontSize', fontSize); ylabel('Freq (Hz)', 'fontSize', fontSize);
grid on;
subplot(3,1,2);
y_txt = enf_audio_zero_array(:,2);
plot(time_vector2, enf_audio_zero_array(:,2), 'k', 'linewidth',0.5);
text(x_txt(10), min(y_txt)+0.01, ['local SNR=',num2str(SNR_dB_zero_array(2),'%.1f'),' dB'], 'fontSize', fontSize_title);
xlim([0 max(time_vector2)]);
xlabel('Time (min)', 'fontSize', fontSize); ylabel('Freq (Hz)', 'fontSize', fontSize);
grid on;
subplot(3,1,3);
y_txt = enf_audio_zero_array(:,1); ylim([min(y_txt)-0.005 max(y_txt)+0.005]);
plot(time_vector2, enf_audio_zero_array(:,1), 'k', 'linewidth',0.5);
text(x_txt(10), min(y_txt)+0.005, ['local SNR=',num2str(SNR_dB_zero_array(1),'%.1f'),' dB'], 'fontSize', fontSize_title);
xlim([0 max(time_vector2)]); ylim([min(y_txt)-0.005 max(y_txt)+0.005]);
xlabel('Time (min)', 'fontSize', fontSize); ylabel('Freq (Hz)', 'fontSize', fontSize);
sgtitle({'Theoretically strongest ENF signal and ', 'its neighboring ENF signals by periodic zeroing-out'});
grid on;



%% if power ref signal is available, compare each strongest ENF signal with power ref 

% load power reference sig
[x_power] = func_loadPowerSig(videoFileLocation, videoFileName);


if exist('x_power', 'var')    
    % extract strongest ENF signal
    enf_audio_dir_strongest  = enf_audio_dir_array (:,2);
    enf_audio_zero_strongest = enf_audio_zero_array(:,2);
    
    extra_param.logFreqForInterp = false;
    enf_power = func_freqEstQuad (x_power, fs, frameSize, overlapAmount, nominalFreq, freq_range, extra_param);
    
    if enbRemoveOutliers == 1
        enf_power = func_removeOutliers(enf_power);
    end
    
    nb_of_frames = ceil((length(x_power) - frameSize + 1)/shiftAmount);
    time_vector = 0:nb_of_frames - 1;
    time_vector = (frameSize_secs-overlap_size_secs) / 60 * time_vector;
    
    
    %% compare ENF signal extracted by direct concatenation method with power ref
    [~, corr_dir, sig_power_dir_R, sig_dir_R, longerSigId]...
        = func_findMatchingTime(enf_power, enf_audio_dir_strongest);
    sig_power_dir = enf_power(sig_power_dir_R(1):sig_power_dir_R(2));
    sig_dir       = enf_audio_dir_strongest(sig_dir_R(1):sig_dir_R(2));
    [sig_dir_hat] = func_transformAffine(sig_power_dir, sig_dir);
    
    % calc rmse, mae after affine transformation
    rmse_dir = func_calcRMSE(sig_power_dir, sig_dir);
    mae_dir  = func_calcMAE(sig_power_dir, sig_dir);
    
    if longerSigId==2
        dispLimit = sig_dir_R;
    else % longerSigId==1
        dispLimit = sig_power_dir_R;
    end
    
    enf_variation_power_dir = sig_power_dir;
    enf_variation_dir = sig_dir_hat;
    
    ymax = max(enf_variation_power_dir);
    ymin = min(enf_variation_power_dir);
    delta = (ymax - ymin)*0.1;
    time_vector_plot = time_vector(dispLimit(1):dispLimit(2));
    
    
    figure;
    movegui('onscreen')
    plot(time_vector_plot, enf_variation_power_dir, 'k-','linewidth', 1.5); hold on;
    plot(time_vector_plot , enf_variation_dir, 'g-.', 'linewidth', 2.0); hold off;
    xlim([time_vector_plot(1), time_vector_plot(end)])
    ylim([ymin - delta ymax + 4*delta])
    xlabel('Time (min)', 'FontSize', 12); ylabel('ENF (Hz)', 'FontSize', 12);
    legend('ENF estimated from power signal', 'ENF estimated from direct concatenation (DCC)', 'location', 'northwest', 'FontSize', 11);
    text(time_vector_plot(round(length(time_vector_plot)*0.7)), ymin + (ymax - ymin)*0.15, strcat('NCC = \color{green}', num2str(corr_dir, '%0.4f')));
    text(time_vector_plot(round(length(time_vector_plot)*0.7)), ymin + (ymax - ymin)*0.15 - 0.003, strcat('RMSE = \color{green}',num2str(rmse_dir, '%0.4f')));
    text(time_vector_plot(round(length(time_vector_plot)*0.7)), ymin + (ymax - ymin)*0.15 - 0.006, strcat('MAE = \color{green}',num2str(mae_dir, '%0.4f')));
    title('Comparison of strongest ENF signal by DCC with referece ENF signal');
    grid on;
    drawnow
    
    
    %% compare ENF signal extracted by periodic zeroing-out method with power ref
    [~, corr_zero, sig_power_zero_R, sig_zero_R, ~]...
        = func_findMatchingTime(enf_power, enf_audio_zero_strongest);
    sig_power_zero = enf_power(sig_power_zero_R(1):sig_power_zero_R(2));
    sig_zero       = enf_audio_zero_strongest(sig_zero_R(1):sig_zero_R(2));
    
    % calc rmse, mae after affine transformation
    [sig_zero_hat] = func_transformAffine(sig_power_zero, sig_zero);
    rmse_zero = func_calcRMSE(sig_power_zero, sig_zero);
    mae_zero = func_calcMAE(sig_power_zero, sig_zero);
    
    if longerSigId==2
        dispLimit = sig_dir_R;
    else % longerSigId==1
        dispLimit = sig_power_zero_R;
    end
    
    enf_variation_power_zero = sig_power_zero;
    enf_variation_zero = sig_zero_hat;
    
    ymax = max(enf_variation_power_zero);
    ymin = min(enf_variation_power_zero);
    delta = (ymax - ymin)*0.1;
    time_vector_plot = time_vector(dispLimit(1):dispLimit(2));

    figure;
    movegui('onscreen')
    plot(time_vector_plot, enf_variation_power_zero, 'k-','linewidth',1.5); hold on;
    plot(time_vector_plot, enf_variation_zero, 'r:','linewidth',1.5); hold off;
    xlim([time_vector_plot(1), time_vector_plot(end)])
    ylim([ymin - delta ymax + 4*delta])
    xlabel('Time (min)', 'FontSize', 12); ylabel('ENF (Hz)', 'FontSize', 12);
    legend('ENF estimated from power reference signal', 'ENF estimated from periodic zeroing-out (PZ)', 'location', 'northwest', 'FontSize', 11);
    text(time_vector2(round(length(time_vector2)*0.7)), ymin + (ymax - ymin)*0.15, strcat('NCC = \color{red}',num2str(corr_zero, '%0.4f')));
    text(time_vector2(round(length(time_vector2)*0.7)), ymin + (ymax - ymin)*0.15 - 0.003, strcat('RMSE = \color{red}',num2str(rmse_zero, '%0.4f')));
    text(time_vector2(round(length(time_vector2)*0.7)), ymin + (ymax - ymin)*0.15 - 0.006, strcat('MAE = \color{red}',num2str(mae_zero, '%0.4f')));
    title('Comparison of strongest ENF signal by PZ with reference ENF signal');
    grid on;
    drawnow
    
    
    %% When overlapped regions are equal, display all ENF signals in one plot
    
    if sig_power_dir_R == sig_power_zero_R
        ymax = max(max(enf_variation_power_dir), max(enf_variation_power_zero));
        ymin = min(min(enf_variation_power_dir), min(enf_variation_power_zero));
        delta = (ymax - ymin)*0.1;
        
        % Plot 3 - Strongest ENF signals aligned with ENF estimated from power signal
        figure;
        movegui('onscreen')
        plot(time_vector_plot, enf_variation_power_dir, 'k-','linewidth',1.5); hold on;
        plot(time_vector_plot, enf_variation_dir, 'g-.','linewidth',2.0);
        plot(time_vector_plot, enf_variation_zero, 'r:','linewidth',1.5); hold off;
        xlim([time_vector_plot(1), time_vector_plot(end)])
        ylim([ymin - delta ymax + 4*delta])
        xlabel('Time (min)', 'FontSize', 12); ylabel('ENF (Hz)', 'FontSize', 12);
        legend('ENF estimated from power reference signal', 'ENF estimated from direct concatenation (DCC)', 'ENF estimated from periodic zeroing-out (PZ)', 'location', 'northwest', 'FontSize', 11);
        text(time_vector_plot(round(length(time_vector_plot)*0.55)), ymin + (ymax - ymin)*0.15, strcat('NCC = \color{green}',num2str(corr_dir, '%0.4f'),'; \color{red}',num2str(corr_zero, '%0.4f')));
        text(time_vector_plot(round(length(time_vector_plot)*0.55)), ymin + (ymax - ymin)*0.15 - 0.003, strcat('RMSE = \color{green}',num2str(rmse_dir, '%0.4f'),'; \color{red}',num2str(rmse_zero, '%0.4f')));
        text(time_vector_plot(round(length(time_vector_plot)*0.55)), ymin + (ymax - ymin)*0.15 - 0.006, strcat('MAE = \color{green}',num2str(mae_dir, '%0.4f'),'; \color{red}',num2str(mae_zero, '%0.4f')));
        title('Comparison of strongest ENF signals by DCC and PZ with reference ENF signal');
        grid on;
        drawnow
        
    end
    
    
end

