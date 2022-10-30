function [s_m_tr, hatOfBeta] = func_transformLinear(s_n, s_m)
%% 5/24/2019, by Jisoo Choi

[M,N] = size(s_m);

x = s_m;
y = s_n;

y = y(:);
x = x(:);

X = [x];
Y = [y];
hatOfBeta = (X' * X) \ (X' * Y);

hatOfy = hatOfBeta*x;

s_m_tr = reshape(hatOfy, [M,N]);