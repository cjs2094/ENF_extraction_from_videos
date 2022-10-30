function func_drawSpectrograms(x_dir, x_zero, fs, frameRate, nfft, frameSize, overlapRatio)

overlapAmount = frameSize*overlapRatio;
tickLabels = 1:floor(0.5*fs/frameRate);
frameSize_secs = frameSize/fs;
overlapSize_secs = overlapAmount/fs;

[F1, P1] = func_getSpectrograms(x_dir, fs, nfft, frameSize, overlapRatio);
size_strips = size(P1);
time_vector1 = 0:size_strips(2)-1;
time_vector1 = (frameSize_secs-overlapSize_secs) / 60 * time_vector1; % unit: min

[F2, P2] = func_getSpectrograms(x_zero, fs, nfft, frameSize, overlapRatio);
size_strips = size(P2);
time_vector2 = 0:size_strips(2)-1;
time_vector2 = (frameSize_secs-overlapSize_secs) / 60 * time_vector2; % unit: min


fontsize = 14;
% plot spectrograms
figure;
movegui('onscreen')
surf(time_vector1, (0:size_strips(1)-1), 10*log10(P1), 'edgecolor', 'none'); hold on; colormap jet;
axis([0 max(time_vector1) 0 size_strips(1)-1]);
view(0,90)
h = colorbar
%caxis([-200 -50])
ylabel(h, 'Power spectral density (dB)', 'FontSize', fontsize);
for k = 1:length(tickLabels)
    center_indices(k) = func_findClosest(F1, frameRate*k);
end
set(gca, 'YTick', center_indices);
set(gca, 'YTickLabel', tickLabels, 'FontSize', 8);
xlabel('Time (min)', 'FontSize', fontsize); ylabel('Frequency (\times frame rate f_{c} Hz)', 'FontSize', fontsize);
title('Spectrogram generated by direct concatenation', 'FontSize', 12);


figure;
movegui('onscreen')
surf(time_vector2, (0:size_strips(1)-1), 10*log10(P2), 'edgecolor', 'none'); hold on; colormap jet;
axis([0 max(time_vector2) 0 size_strips(1)-1]);
view(0,90)
h = colorbar
%caxis([-200 -50])
ylabel(h, 'Power spectral density (dB)','FontSize', fontsize);
for k = 1:length(tickLabels)
    center_indices(k) = func_findClosest(F2, frameRate*k);
end
set(gca, 'YTick', center_indices);
set(gca, 'YTickLabel', tickLabels, 'FontSize', 8);
xlabel('Time (min)', 'FontSize', fontsize); ylabel('Frequency (\times frame rate f_{c} Hz)', 'FontSize', fontsize);
title('Spectrogram generated by periodic zeroing-out', 'FontSize', 12);

% % draw pediodograms
% meanOfP1 = mean(P1,2);
% meanOfP1_dB = 10*log10(meanOfP1);
% 
% figure
% plot(F1, meanOfP1_dB, 'k', 'linewidth',1.8); hold on;
% grid on;
% xlim([10, 100])
% ylabel('Magnitude (dB)'); xlabel('Frequency (Hz)');
% 
% meanOfP2 = mean(P2,2);
% meanOfP2_dB = 10*log10(meanOfP2);
% 
% figure
% plot(F2, meanOfP2_dB, 'k', 'linewidth',1.8); hold on;
% grid on;
% xlim([80, 170])
% ylabel('Magnitude (dB)'); xlabel('Frequency (Hz)');
