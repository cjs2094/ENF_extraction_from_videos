function [  frequency_estimates ] = func_freqEstQuad( x, fs, frame_size, overlap_amount, target_freq, freq_range, extra_param )
% ENF frequency estimation with quadratic interpolation.

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

shift_amount = frame_size - overlap_amount;
nb_of_frames = ceil ( (length(x) - frame_size + 1) / shift_amount ) ;
frequency_estimates = zeros(nb_of_frames, 1);


nfft = round(fs/desired_resolution);
exponent = nextpow2(nfft);
if (2^exponent - nfft) > (nfft - 2^(exponent - 1))
    nfft = 2^(exponent - 1);
else
    nfft = 2^(exponent);
end
true_resolution = fs/nfft;

starting = 1;
for frames = 1:nb_of_frames
    ending = starting + frame_size - 1;
    signal = x(starting:ending);
    [~, f, ~, p] = spectrogram(signal, frame_size, 0, nfft, fs);
    head = round ( (target_freq-freq_range) / true_resolution );
    tail = round ( (target_freq+freq_range) / true_resolution );
    
    [~, idxMax] = max(p(head:tail));
    x_coordinate = [-1 0 1]; % do not use true frequency values to avoid ill-condition of the data matrix
    y = p ( head + idxMax-1 + x_coordinate );
    if logFreqForInterp
        y = log(y); % carry out location estimation in log freq domain.
    end
    location_normalized = ( y(1)-y(3) ) / (2*( y(1)-2*y(2)+y(3) )); % analytical form of the estimate of parabola model
    location = f(head+idxMax-1) + location_normalized * true_resolution;
    frequency_estimates(frames) = location;

%     % [Chau-Wai Wong] The following code uses a fixed x-coordinate [-1 0 1]
%     % instead of the coordinate of the true frequency [f_(i-1) f_i f_(i+1)]
%     % to fit a parabola. This can avoid the data matrix of linear
%     % regression being ill-conditioned when the frequency values f_i's are
%     % closely spaced in very high frequency resolution cases.
%     [~, idxMax] = max(p(head:tail));
%     x_coordinate = [-1 0 1]; % do not use true frequency values to avoid ill-condition of the data matrix
%     p_for_est = p ( head + idxMax-1 + x_coordinate );
%     est_coeff = polyfit(x_coordinate(:), p_for_est, 2); % fit a1 x^2 + a2 x + a3 to the 3 points
%     location_normalized = est_coeff(2)/(-2*est_coeff(1)); % location of the axis of symmetry as the estimate
%     location = f(head+idxMax-1) + location_normalized * true_resolution;
%     frequency_estimates(frames) = location;

%     % [Chau-Wai Wong] The following code directly using the true
%     % frequencies to form a data matrix is not suggested. The data matrix
%     % can be ill-conditioned when the frequency values are closely spaced
%     % in very high frequency resolution cases. (The whole section can be 
%     % removed for publishing purposes.)
%     [c, i] = max(p(head:tail));
%     indices = head + [i-1, i, i+1] - 1;
%     f_wanted = f(indices);
%     p_wanted = p(indices);
%     a_coeff = polyfit(f_wanted, p_wanted, 2); % a1 x^2 + a2 x + a3
%     b_coeff = zeros(3, 1); % b1 ( x - b2)^2 + b3
%     b_coeff(1) = a_coeff(1);
%     b_coeff(2) = a_coeff(2)/(-2*b_coeff(1));
%     frequency_estimates(frames) = b_coeff(2);

    starting = starting + shift_amount;
end
