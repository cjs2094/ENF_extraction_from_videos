function rmse = func_calcRMSE(x, y) % root mean squared error
%% Jisoo Choi, 6/17/2019

[y_hat] = func_transformAffine(x, y);
    
x1 = x;
y1 = y_hat;
%x1 = x - mean(x);
%y1 = y_hat - mean(y_hat);

rmse = sqrt(mean((x1 - y1).^2));  

