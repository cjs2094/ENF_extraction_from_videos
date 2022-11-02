function [output] = func_removeOutliers(signal)

diff = zeros(length(signal) - 1, 1);
for k = 1 : length(diff)
    diff(k) = signal(k + 1) - signal(k);
end
mean_diff = mean(diff);
std_diff = std(diff);
outlier_pos = [];
for k = 1 : (length(diff) - 1)
    if diff(k) > (mean_diff + std_diff)
        if  diff(k+1) < (mean_diff - std_diff)
            outlier_pos = [outlier_pos (k + 1)];
        end
    elseif diff(k) < (mean_diff - std_diff)
        if diff(k+1) > (mean_diff + std_diff)
            outlier_pos = [outlier_pos (k + 1)];
        end
    end
end
output = signal;
for k = 1 : length(outlier_pos)
    output = averageApoint(output, outlier_pos(k));
end


%%
function [output] = averageApoint(signal, index)

output = signal;
output(index) = 0.5*(signal(index - 1) + signal(index + 1));
