function mae = func_calcMAE(x, y) % mean absolute error
%% Jisoo Choi, 6/17/2019

[y_hat] = func_transformAffine(x, y);

x1 = x;
y1 = y_hat;
%x1 = x - mean(x);
%y1 = y_hat - mean(y_hat);

diff = abs(x1 - y1);

mae = mean(diff);
