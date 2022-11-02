function [rowSig_zeroingOut] = func_zeroingOutVerOfRowSig(rowSig, L, M)

temp         = zeros(M, size(rowSig, 2));
temp(1 : L, :) = rowSig;

rowSig_zeroingOut = temp(:);
