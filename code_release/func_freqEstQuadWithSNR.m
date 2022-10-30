function [frequency_estimates, localSNR_final, localSNR_dB_final] = func_freqEstQuadWithSNR(x, fs, frame_size, overlap_amount, target_freq, freq_band, freq_range, extra_param )
% ENF frequency estimation with quadratic interpolation.
% 03/07/2021, modified by Jisoo Choi

% prepare for extra parameters BEGIN
desired_resolution = 0.03;
if isfield(extra_param, 'power')
    if ~isempty(extra_param.desired_resolution)
        desired_resolution = extra_param.desired_resolution;
    end
end

logFreqForInterp = false;
if isfield(extra_param, 'logFreqForInterp')
    if ~isempty(extra_param.logFreqForInterp)
        logFreqForInterp = extra_param.logFreqForInterp;
    end
end
% prepare for extra parameters END

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

shift_amount = frame_size - overlap_amount;
nb_of_frames = ceil ( (length(x) - frame_size + 1) / shift_amount ) ;
frequency_estimates = zeros(nb_of_frames, 1);
starting = 1;
for frames = 1:nb_of_frames
    %% locate dominant frequencies
    ending = starting + frame_size - 1; % updated every cycle
    x_seg = x(starting:ending); % updated every cycle
    [~, F, ~, Px_WperHzBin] = spectrogram(x_seg, frame_size, 0, nfft, fs, 'psd'); % updated every cycle
    [~, idxMax] = max(Px_WperHzBin(head_sig:tail_sig));           
    
    % apply quadratic interpolation
    x_coordinate = [-1 0 1]; % do not use true frequency values to avoid ill-condition of the data matrix
    y = Px_WperHzBin ( head_sig + idxMax - 1 + x_coordinate );
    if logFreqForInterp
        y = log(y); % carry out location estimation in log freq domain.
    end
    location_normalized = ( y(1) - y(3) ) / (2*( y(1)-2*y(2)+y(3) )); % analytical form of the estimate of parabola model
    location = F(head_sig + idxMax - 1) + location_normalized * true_resolution;
    frequency_estimates(frames) = location;
    starting = starting + shift_amount;
    
    
    %% calculate empirical SNR
    PsigPlusNoise_WperHz = Px_WperHzBin(head_sig + idxMax-1); % PsigPlusNoise_W = PsigPlusNoise_WperHz
    avgPnoise_WperHz = median(Px_WperHzBin);
    Psig_WperHz = PsigPlusNoise_WperHz - avgPnoise_WperHz;
    Psig_W = Psig_WperHz;
    avgPnoise_W = avgPnoise_WperHz*(fs/2);
    
    localSNR(frames) = Psig_W / avgPnoise_WperHz;
    trueSNR(frames) = Psig_W / avgPnoise_W;
    trueSNR_dB(frames)  = 10*log10(Psig_W) - 10*log10(avgPnoise_W);
    avgPnoise_WperHz_dB(frames) = 10*log10(avgPnoise_WperHz);
    
    localSNR_dB_temp    = 10*log10(Psig_W) - 10*log10(avgPnoise_WperHz);
        
    if isreal(localSNR_dB_temp)
        localSNR_dB(frames) = localSNR_dB_temp;
    else
        localSNR_dB(frames) = NaN;
    end
    
end

localSNR_final = nanmean(localSNR(:));
localSNR_dB_final = nanmean(localSNR_dB(:));


