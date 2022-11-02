function func_compDirectConcatAndPeriodicZeroingOut(videoFileName_arr, targetLocalSNR_dB_arr, numOfRealizations, enbSameLength)

enbRemoveOutliers = 1;

localSNR_dB_dir_arr = [];
localSNR_dB_zero_arr = [];
corr_dir_arr  = [];
corr_zero_arr = [];
rmse_dir_arr  = [];
rmse_zero_arr = [];
mae_dir_arr   = [];
mae_zero_arr  = [];
pvalue_corr_arr = [];
pvalue_rmse_arr = [];
pvalue_mae_arr = [];


%% [step 1] generate noisy row signals

for vid_ind = 1 : length(videoFileName_arr)
    videoFileName = cell2mat(videoFileName_arr(vid_ind));
        
    videoFileLocation = [pwd, '\vids\', videoFileName];
        
    %% load variables
    [rowSig_dirConcat, ~, rowSig_dirConcat_1k, ~, paras]...
        = func_linearizationWithDirConcatAndZeroingOut(videoFileLocation, videoFileName);
    
    nominalFreq = paras.nominalFreq;
    Tro         = paras.Tro;
    frameRate   = paras.frameRate;
    height      = paras.height;
    numOfZeros  = paras.numOfZeros;
    fps_rounded = paras.fps_rounded;
    fs_rounded  = paras.fs_rounded;
    fs          = paras.fs_downsampled;
    
    x_dir     = rowSig_dirConcat;
    [x_power] = func_loadPowerSig(videoFileLocation, videoFileName); % load power reference sig
    
    numOfFrames = length(x_dir) / height;
    
    
    %% define variables
    frame_size = 12000;
    overlap_ratio = 0.9;
    overlap_amount = frame_size*overlap_ratio;

    freq_band = 2;
    freq_range = 0.5;   
    target_freq_dir = 2*nominalFreq + round((Tro - 1/frameRate)*2*nominalFreq)*frameRate;
    target_freq_zero = 2*nominalFreq;
    
    % when measuring empirical SNR, we use raw ver. of row sig. instead of downsampled ver. of row sig.
    extra_param.logFreqForInterp = false;
    [Psig0_W, avgPnoise0_WperHz, ~, ~] = func_measureEmpiricalSNR(x_dir, fps_rounded, target_freq_dir, freq_band, freq_range);

    BW = fps_rounded/2;
    avgPnoise0_W = avgPnoise0_WperHz*BW;
    

    %% add awgn to row signals    
    for snr_ind = 1 : length(targetLocalSNR_dB_arr)
        targetLocalSNR_dB = targetLocalSNR_dB_arr(snr_ind);
        targetSNR_dB = targetLocalSNR_dB - 10*log10(BW);
        targetAvgPnoise_W  = (Psig0_W) * 10^(-targetSNR_dB/10); % power [W]
        PaddedNoise_W = targetAvgPnoise_W - avgPnoise0_W;
        variance = PaddedNoise_W;

        for realization_ind = 1 : numOfRealizations
            % add awgn to row signals
            x_dir_awgn  = x_dir  + sqrt(variance)*randn(size(x_dir)); 
            x_dir_awgn_frameWise = reshape (x_dir_awgn, height, numOfFrames);
            x_zero_awgn_frameWise = zeros(height + numOfZeros, numOfFrames);
            x_zero_awgn_frameWise(1:height, :) = x_dir_awgn_frameWise;
            x_zero_awgn = x_zero_awgn_frameWise(:); 
            
            % downsample row signals to 1kHz
            [N, D] = rat(fs / fps_rounded);
            x_dir_awgn_downsampled = resample(x_dir_awgn, N, D);
            [N, D] = rat(fs / fs_rounded);
            x_zero_awgn_downsampled = resample(x_zero_awgn, N, D);
                       
            % remove DC component
            x_dir_awgn_downsampled  = x_dir_awgn_downsampled - mean(x_dir_awgn_downsampled);
            x_zero_awgn_downsampled = x_zero_awgn_downsampled - mean(x_zero_awgn_downsampled);
            

            if enbSameLength == 1
                % make their lenghts the same assuming that power sig was captured simutaneously with video recording
                min_len = min([length(x_power), length(x_dir_awgn_downsampled), length(x_zero_awgn_downsampled)]);
                %min_len = min(length(x_dir_awgn_downsampled), length(x_zero_awgn_downsampled)]);

                % take first "min_len" samples from each signal
                x_power = x_power(1 : min_len);
                x_dir_awgn_downsampled   = x_dir_awgn_downsampled(1 : min_len);
                x_zero_awgn_downsampled  = x_zero_awgn_downsampled(1 : min_len);
            end
            
            
            
            %% extract strongest ENF signal segments with matching criteria
            
            extra_param.logFreqForInterp = false;
            enf_power = func_freqEstQuad (x_power, fs, frame_size, overlap_amount, nominalFreq, freq_range, extra_param);
            
            [enf_audio_dir] = func_freqEstQuadWithSNR(x_dir_awgn_downsampled, fs, frame_size, overlap_amount, target_freq_dir, freq_band, freq_range, extra_param);
            [Psig_W_dir, avgPnoise_WperHz_dir, localSNR_dB_dir, SNR_dB_dir] = func_measureEmpiricalSNR(x_dir_awgn, fps_rounded, target_freq_dir, freq_band, freq_range);
            [enf_audio_zero] = func_freqEstQuadWithSNR(x_zero_awgn_downsampled, fs, frame_size, overlap_amount, target_freq_zero, freq_band, freq_range, extra_param);
            [Psig_W_zero, avgPnoise_WperHz_zero, localSNR_dB_zero, SNR_dB_zero] = func_measureEmpiricalSNR(x_zero_awgn, fs_rounded, target_freq_zero, freq_band, freq_range);
            
            if enbRemoveOutliers == 1
                enf_power = func_removeOutliers(enf_power);
                enf_audio_dir = func_removeOutliers(enf_audio_dir);
                enf_audio_zero = func_removeOutliers(enf_audio_zero);
            end
            
            [corr_dir, rmse_dir, mae_dir] = func_performanceMearsure(enf_power, enf_audio_dir);
            [corr_zero, rmse_zero, mae_zero] = func_performanceMearsure(enf_power, enf_audio_zero);            
            
            corr_dir_arr ((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = corr_dir;
            corr_zero_arr((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = corr_zero;
            rmse_dir_arr ((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = rmse_dir;
            rmse_zero_arr((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = rmse_zero;
            mae_dir_arr  ((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = mae_dir;
            mae_zero_arr ((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = mae_zero;
            
            localSNR_dB_dir_arr ((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = localSNR_dB_dir;
            localSNR_dB_zero_arr((vid_ind - 1)*numOfRealizations + realization_ind, snr_ind) = localSNR_dB_zero;
        end
        
    end
    
end


%% [Substep 3] Do paired t-test
for k = 1 : length(targetLocalSNR_dB_arr)
    [~, pvalue_corr] = ttest(corr_dir_arr(:, k), corr_zero_arr(:, k));
    [~, pvalue_rmse] = ttest(rmse_dir_arr(:, k), rmse_zero_arr(:, k));
    [~, pvalue_mae]  = ttest(mae_dir_arr(:, k), mae_zero_arr(:, k));
    
    pvalue_corr_arr(1, k) = pvalue_corr;
    pvalue_rmse_arr(1, k) = pvalue_rmse;
    pvalue_mae_arr (1, k) = pvalue_mae;
end


%% [Substep 4] Summarize results via boxplots
% ref: https://www.graphpad.com/support/faq/what-is-the-meaning-of--or--or--in-reports-of-statistical-significance-from-prism-or-instat/

close all;
fontsize_xy = 18;
fontsize_legend = 16;

plotColors = {[0.55 0.71 0] [0.2 0.4 0.5] 'c' [0.5 0 0.5] 'b' [1 0.5 0]};
legendEntries = {'Direct concatenation' 'Periodic zeroing-out'};

N = 2;
delta = linspace(-.1, .1, N); 
width = .6; 
labels = {'30 dB' '25 dB' '20 dB' '15 dB' '10 dB'};


figure;
boxplot(corr_dir_arr, 'Color', plotColors{1}, 'boxstyle', 'filled', 'MedianStyle', 'target', ...
     'position', (1 : numel(labels)) + delta(1), 'widths', width, 'labels', labels); hold on
plot(NaN, 1, 'color', plotColors{1}); %// dummy plot for legend
xt_dir = get(gca, 'XTick'); yt_dir = get(gca, 'YTick');
boxplot(corr_zero_arr, 'Color', plotColors{2}, 'boxstyle', 'filled', 'MedianStyle', 'target', ...
     'position', (1 : numel(labels)) + delta(2), 'widths', width, 'labels', labels);
plot(NaN,1, '-', 'color', plotColors{2}); %// dummy plot for legend
xt_zero = get(gca, 'XTick'); yt_zero = get(gca, 'YTick');
yt_max = max([max(yt_dir), max(yt_zero)]);
yt_min = min([min(yt_dir), min(yt_zero)]);
for k = 1 : length(targetLocalSNR_dB_arr)
plot([xt_dir(k) xt_zero(k)], [1 1]*yt_max, '-k', mean([xt_dir(k) xt_zero(k)]), yt_max, 'k')
text(min([xt_dir(k) xt_zero(k)]) - 0.2, yt_max + 0.1, [num2str(pvalue_corr_arr(1, k), '%.4f')], 'FontSize', 14)
end
hold off
ylim([yt_min - 0.2 yt_max + 0.2]);
xlabel('Local SNR', 'FontSize', fontsize_xy); ylabel('NCC', 'FontSize', fontsize_xy); grid on;
%xlim([1+2*delta(1) numel(labels)+legWidth+2*delta(N)]) %// adjust x limits, with room for legend
legend(legendEntries, 'Location', 'SouthWest', 'FontSize', fontsize_legend);


figure;
boxplot(rmse_dir_arr, 'Color', plotColors{1}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
    'position', (1 : numel(labels)) + delta(1), 'widths', width, 'labels', labels); hold on
plot(NaN,1,'color', plotColors{1}); %// dummy plot for legend
xt_dir = get(gca, 'XTick'); yt_dir = get(gca, 'YTick');
boxplot(rmse_zero_arr, 'Color', plotColors{2}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
    'position', (1 : numel(labels)) + delta(2), 'widths', width, 'labels', labels);
plot(NaN, 1, '-', 'color', plotColors{2}); %// dummy plot for legend
xt_zero = get(gca, 'XTick'); yt_zero = get(gca, 'YTick');
yt_max = max([max(yt_dir), max(yt_zero)]);
yt_min = min([min(yt_dir), min(yt_zero)]);
for k = 1 : length(targetLocalSNR_dB_arr)
    plot([xt_dir(k) xt_zero(k)], [1 1]*yt_max, '-k', mean([xt_dir(k) xt_zero(k)]), yt_max, 'k')
    text(min([xt_dir(k) xt_zero(k)])-0.2, yt_max + 0.002, [num2str(pvalue_rmse_arr(1, k), '%.4f')], 'FontSize', 14)
end
hold off
ylim([yt_min - 0.1 yt_max + 0.005]);
xlabel('Local SNR', 'FontSize', fontsize_xy); ylabel('RMSE', 'FontSize', fontsize_xy); grid on;
%xlim([1+2*delta(1) numel(labels)+legWidth+2*delta(N)]) %// adjust x limits, with room for legend
legend(legendEntries, 'Location', 'SouthEast', 'FontSize', fontsize_legend);
ax = gca;
ax.YAxis.Scale = "log";


figure;
boxplot(mae_dir_arr, 'Color', plotColors{1}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
    'position', (1 : numel(labels)) + delta(1), 'widths', width, 'labels', labels); hold on
plot(NaN,1,'color', plotColors{1}); %// dummy plot for legend
xt_dir = get(gca, 'XTick'); yt_dir = get(gca, 'YTick');
boxplot(mae_zero_arr, 'Color', plotColors{2}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
    'position', (1 : numel(labels)) + delta(2), 'widths', width, 'labels',labels);
plot(NaN,1, '-', 'color', plotColors{2}); %// dummy plot for legend
xt_zero = get(gca, 'XTick'); yt_zero = get(gca, 'YTick');
yt_max = max([max(yt_dir), max(yt_zero)]);
yt_min = min([min(yt_dir), min(yt_zero)]);
for k = 1 : length(targetLocalSNR_dB_arr)
    plot([xt_dir(k) xt_zero(k)], [1 1]*yt_max, '-k', mean([xt_dir(k) xt_zero(k)]), yt_max, 'k')
    text(min([xt_dir(k) xt_zero(k)]) - 0.2, yt_max + 0.002, [num2str(pvalue_mae_arr(1, k), '%.4f')], 'FontSize', 14)
end
hold off
ylim([yt_min - 0.1 yt_max + 0.005]);
xlabel('Local SNR', 'FontSize', fontsize_xy); ylabel('MAE', 'FontSize', fontsize_xy); grid on;
%xlim([1+2*delta(1) numel(labels)+legWidth+2*delta(N)]) %// adjust x limits, with room for legend
legend(legendEntries, 'Location', 'SouthEast', 'FontSize', fontsize_legend);
ax = gca;
ax.YAxis.Scale = "log";

