function [rowSig_downsampled] = func_downsample(rowSig, fs, fs_downsampled)

[N, D] = rat(fs_downsampled/fs); % rational fraction approximation
% Check = [fs_downsampled/fs, N/D] % approximation accuracy check
rowSig_downsampled = resample(rowSig, N, D);

end