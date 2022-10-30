function [corr, rmse, mae] = func_performanceMearsure(sig1, sig2)

corr = func_calcPearsonCorr(sig1(:), sig2(:));
rmse = func_calcRMSE(sig1(:), sig2(:));
mae  = func_calcMAE(sig1(:), sig2(:));