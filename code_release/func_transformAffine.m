function [s_m_tr, hatOfBeta] = func_transformAffine(s_n, s_m)
%% 5/24/2019, by Jisoo Choi

[M,N] = size(s_m);

x = s_m;
y = s_n;

y = y(:);
x = x(:);
vec1 = ones(length(y), 1);

X = [vec1 x];
Y = [y];
hatOfBeta = (X' * X)\(X' * Y);

hatOfy = hatOfBeta(2)*x + hatOfBeta(1);

s_m_tr = reshape(hatOfy, [M, N]);