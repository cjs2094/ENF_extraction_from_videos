function [Psig_W, avgPnoise_WperHz, localSNR_dB, trueSNR_dB] = func_measureEmpiricalSNR (x, fs, target_freq, freq_band, freq_range)
% 03/06/2021, by Jisoo Choi

x = x(:);
modifiedVer_flag = 0;
desired_resolution = 0.03;
nfft = round(fs/desired_resolution);
exponent = nextpow2(nfft);
if (2^exponent - nfft) > (nfft - 2^(exponent - 1))
    nfft = 2^(exponent - 1);
else
    nfft = 2^(exponent);
end
true_resolution = fs/nfft;

head_sig = round ( (target_freq - freq_range) / true_resolution );
tail_sig = round ( (target_freq + freq_range) / true_resolution );
head_noise_sec1 = round ( (target_freq - freq_band) / true_resolution );
tail_noise_sec1 = round ( (target_freq - freq_range) / true_resolution );
head_noise_sec2 = round ( (target_freq + freq_range) / true_resolution );
tail_noise_sec2 = round ( (target_freq + freq_band) / true_resolution );

window= rectwin(length(x)); %window= hanning(length(x));
[~, F, ~, Px_WperHzBin] = spectrogram(x, window, 0, nfft, fs, 'psd'); % periodogram
[~, idxMax] = max(Px_WperHzBin(head_sig:tail_sig));

if modifiedVer_flag == 1
% As a result, practically due to this finite nature of the frequency bins,
% the original frequency present in the signal might fall within two adjacent bins.
% This leads to biased estimate of the frequency, and might also result in biased amplitude estimate.
% To avoid it, we may consider to sum several adjacent bins around the
% targeted bin.
    [~, idxMax] = max(Px_WperHzBin(head_sig:tail_sig));
    PsigPlusNoise_WperHz = Px_WperHzBin(idxMax - 2:idxMax + 2);
else
    PsigPlusNoise_WperHz = Px_WperHzBin(head_sig + idxMax-1); % PsigPlusNoise_W = PsigPlusNoise_WperHz
end

%%%%%%%%%%%%%%%%% MAJOR PREMISE %%%%%%%%%%%%%%%%%
% [Adi's empirical SNR measurement]
% Empirical SNR assumes that signal and noise freq components only exist at
% a certain frequency which corresponds to "one bin". In other words,
% Psig_W = Psig_WperHz.
% Also, we should have avgPnoise_W = avgPnoise_WperHz*(fs/2).

% [Another way of empirical SNR measurement (I think it is more practical)]: 
% Empirical SNR assumes that only signal freq components only exist at
% a certain frequency which corresponds to "one bin". However, we assume
% noise components are spreaded over [-fs/2 fs/2].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%avgPnoise_WperHz = 0.5*mean(Px_WperHzBin(head_noise_sec1:tail_noise_sec1)) + 0.5*mean(Px_WperHzBin(head_noise_sec2:tail_noise_sec2));

%%%%%%%%%%%%%%%%% 나의 발견 %%%%%%%%%%%%%%%%%%%
avgPnoise_WperHz = median(Px_WperHzBin);
%%%%%%%%%%%%%%%%% 나의 발견 %%%%%%%%%%%%%%%%%%%

% Pnoise_WperHz = sum(Px_WperHzBin(head_noise_sec1:tail_noise_sec1)) + sum(Px_WperHzBin(head_noise_sec2:tail_noise_sec2));
% numOfBins = length(Px_WperHzBin(head_noise_sec1:tail_noise_sec1)) + length(Px_WperHzBin(head_noise_sec2:tail_noise_sec2))
% avgPnoise_W = Pnoise_WperHz*(fs/numOfBins)
% avgPnoise_WperHz = avgPnoise_W/fs
% 10*log10(avgPnoise_WperHz)


%% final result
Psig_WperHz = PsigPlusNoise_WperHz - avgPnoise_WperHz;
Psig_W = Psig_WperHz;
avgPnoise_W = avgPnoise_WperHz*(fs/2);

localSNR = Psig_W / avgPnoise_WperHz;
trueSNR = Psig_W / avgPnoise_W;
localSNR_dB = 10*log10(Psig_W) - 10*log10(avgPnoise_WperHz);
trueSNR_dB = 10*log10(Psig_W) - 10*log10(avgPnoise_W);

avgPnoise_WperHz_dB = 10*log10(avgPnoise_WperHz);

% figure;
% plot(F, 10*log10(Px_WperHzBin));
% %yline(10*log10(Psig_W), 'LineWidth', 1.5);
% yline(10*log10(avgPnoise_WperHz), 'LineWidth', 1.5);
% grid on
% %ylim([-90 10])
% legend('sig PSD', ['avg noise PSD of sig (', num2str(10*log10(avgPnoise_WperHz)), ' dB)'])
% xlabel('F [Hz]'); ylabel('PSD [dBW/Hz]');
% sgtitle(['True SNR = ', num2str(trueSNR_dB), ' dB']);


