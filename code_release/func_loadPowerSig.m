function [x_power] = func_loadPowerSig(videoFileLocation, videoFileName)

powerFn = [videoFileLocation, '\power_', videoFileName, '.wav'];

if isfile(powerFn)
    [x_power, fs] = audioread(powerFn);
    
    if fs ~= 1000
        fs_downsampled = 1000;
        [x_power_downsampled] = func_downsample(x_power, fs, fs_downsampled);
        x_power = x_power_downsampled;
    end
    
    % remove DC component
    x_power = x_power - mean(x_power);
else
   x_power = NaN; 
end
    
