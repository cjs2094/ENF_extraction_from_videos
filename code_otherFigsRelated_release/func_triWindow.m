function [win, win_start, win_end] = func_triWindow(x)
%% 08/07/2019, Jisoo Choi
%x = 0:3000;
W = x(ceil(0.5*length(x)));

a1 = x <= W;
b1 = x > W;

a2 = a1.*x/W;
b2 = -b1.*x/W;
b2(ceil(0.5*length(x))+1:end) = b2(ceil(0.5*length(x)) + 1 : end) + 2;

win = a2 + b2;

win_start = win;
win_start(1 : W) = 1;
win_end = win;
win_end(W : end) = 1;

