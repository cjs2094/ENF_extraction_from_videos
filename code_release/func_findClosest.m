function [ index ] = func_findClosest(vector, value)

[~, index] = min(abs(vector - value));

end

% function [ index ] = func_findClosest( vector, value )
% 
% index = 1;
% 
% for k = 2:length(vector)
%     if (abs(vector(k) - value) < abs(vector(k-1) - value))
%         index = k;
%     else
%         break;
%     end
%     
% end
% 
