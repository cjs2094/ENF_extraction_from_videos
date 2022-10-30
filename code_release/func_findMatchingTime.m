function [lag, corr_final, range1, range2, longerSigId] = func_findMatchingTime(sig1, sig2)
% Improved cross-correlation matching function
% This function is capable of searching the location of correlation peak for 
% two input signals. No restriction is on the signal lengths.
% Output: 
%   lag: amount by which sig1 lags sig2.
%   matchedCorr: highest sample correlation achieved when sig1 is shifted
%   to the left by #(lags) steps.
%   range1, range2: index sets of overlapped region
%   longerSigId: the idx of longer (ref) signal
% Chau-Wai Wong, Dec. 2014

% mask signal must be shorter than the reference signal
len_sig1 = length(sig1);
len_sig2 = length(sig2);
if len_sig1 < 5 || len_sig2 < 5
    error('Signal should be not less than 5 points');
end
if len_sig1 < len_sig2
    mask = sig1;
    ref = sig2;
    len_mask = len_sig1;
    len_ref = len_sig2;
    lagInverse = false;
    longerSigId = 2;
else %len_sig1 >= len_sig2
    mask = sig2;
    ref = sig1;
    len_mask = len_sig2;
    len_ref = len_sig1;
    lagInverse = true;
    longerSigId = 1;
end

% shortest length for sample correlation that is considered significant 
% (avoid false high correlation due to short segment)
short = min(len_sig1, len_sig2);
long  = max(len_sig1, len_sig2);
thres = ceil ( min ( [long/10 short] ) );

% mask on the left of the reference signal
% note: overlapped ranges for each case are carefully derived. no need to
% check. if insist, calculating from scratch would be faster.
shift_arr_left = -(len_mask-1) : -1 ;
corr_arr_left = zeros(1,length(shift_arr_left));
cnt = 0;
for shift = shift_arr_left
    cnt = cnt + 1;
    sh = -shift;
    s1 = mask(sh+1:len_mask);
    s2 = ref(1:len_mask-sh);
    if length(s1)<thres
        corr_arr_left(cnt) = NaN;
    else
        corr_arr_left(cnt) = func_calcPearsonCorr(s1(:), s2(:));
    end
end
% mask on the right of the reference signal
shift_arr_right =  (len_ref-len_mask+1) : (len_ref-1) ;
corr_arr_right = zeros(1,length(shift_arr_right));
cnt = 0;
for shift = shift_arr_right
    cnt = cnt + 1;
    sh = shift - (len_ref-len_mask);
    % sh = 1 : len_mask-1
    s1 = mask(1:len_mask-sh);
    s2 = ref(end-(len_mask-sh-1):end);
    if length(s1)<thres
        corr_arr_left(cnt) = NaN;
    else
        corr_arr_right(cnt) = func_calcPearsonCorr(s1(:), s2(:));
    end
end
% mask at the center of the reference signal
shift_arr_center =  0 : (len_ref-len_mask) ;
corr_arr_center = zeros(1,length(shift_arr_center));
cnt = 0;
for shift = shift_arr_center
    cnt = cnt + 1;
    s1 = mask;
    s2 = ref( 1+shift : len_mask+shift );
    corr_arr_center(cnt) = func_calcPearsonCorr(s1(:), s2(:));
end

shift = [shift_arr_left  shift_arr_center  shift_arr_right];
corr = [corr_arr_left   corr_arr_center   corr_arr_right];

% For diff-length signal with power ref signal
[corr_final, lagIdx] = max(corr);
lag = shift(lagIdx);

% For same-length signal with power ref signal
% lagIdx = length(sig1);
% corr_final = corr(lagIdx);
% lag = shift(lagIdx);

% recalculate the two index sets of the overlapped region using the same
% range details as used above
if sum(lag==shift_arr_left)
    sh = -lag;
    range1 = [sh+1, len_mask];
    range2 = [1, len_mask-sh];
elseif sum(lag==shift_arr_right)
    sh = lag - (len_ref-len_mask);
    range1 = [1, len_mask-sh];
    range2 = [len_ref-(len_mask-sh-1), len_ref];
elseif sum(lag==shift_arr_center)
    range1 = [1, len_mask];
    range2 = [1+lag, len_mask+lag];
else
    error('Algorithmic error. Check code.');
end

if lagInverse
    lag = -lag;
    tmp = range1;
    range1 = range2;
    range2 = tmp;
end

