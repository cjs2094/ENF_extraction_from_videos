function [F, P] = func_getSpectrograms(x, fs, nfft, frame_size, overlap_ratio)
    overlap_amount = frame_size*overlap_ratio;
    shift_amount = frame_size - overlap_amount;
    nb_of_frames = ceil((length(x) - frame_size + 1)/shift_amount);

    P = zeros(nfft/2 + 1, nb_of_frames);

    starting = 1;
    for frame = 1:nb_of_frames
        ending = starting + frame_size - 1;
        signal = x(starting:ending);
        [~, F, ~, P(:, frame)] = spectrogram(signal, frame_size, 0, nfft, fs);
        %[F, P(:, frame)] = STFT(signal, frame_size, nfft, fs);
        starting = starting + shift_amount;
    end
end

function [F, P] = STFT(signal, frame_size, nfft, fs)
    win = blackman(frame_size); % blackman window
    xdft = fft(signal.*win, nfft);
    psdx = abs(xdft(1:length(xdft)/2+1)).^2;
    %psdx = abs(xdft(1:length(xdft)/2+1));
    normPsdx = (1/frame_size)*psdx;
    P = normPsdx;

    F = linspace(0,1,nfft/2+1)*fs/2;
    F = F(:);
end
