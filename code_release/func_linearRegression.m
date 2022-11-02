function [hatOfy, x_line, y_line] = func_linearRegression(x, y)
%% Jisoo Choi, 6/17/2019

y = y(:);
x = x(:);
vec1 = ones(length(y), 1);

X = [vec1 x];
Y = [y];
hatOfBeta = (X'*X)\(X'*Y);
hatOfy = hatOfBeta(2)*x + hatOfBeta(1);

x_line = linspace(min(x), max(x), 100);
y_line = hatOfBeta(2)*x_line + hatOfBeta(1);

