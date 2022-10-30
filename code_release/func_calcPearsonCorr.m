function corr = calcPearsonCorr(x, y) % normalized cross-correlation
% When only correlation value is needed, this function is about 30% faster
% than the Matlab build-in function corr(x,y)
% Oct. 2014, Chau-Wai Wong

x1 = x - mean(x);
y1 = y - mean(y);

var_x = sum(x1.^2);
var_y = sum(y1.^2);

corr = x1'*y1 / sqrt(var_x*var_y);