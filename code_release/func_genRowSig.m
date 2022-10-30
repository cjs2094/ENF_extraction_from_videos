function [row_sig] = func_genRowSig(vidObj, numOfTotalFrames, n_ref_frame, brComp)
frameRate = vidObj.FrameRate;
height = vidObj.Height;

vid1 = read(vidObj, n_ref_frame);
s_ref = rgb2gray(im2double(vid1));
row_sig_hat = [];

start_time = tic;
for m = 1 : numOfTotalFrames
    vid2 = read(vidObj, m);
    s_m = rgb2gray(im2double(vid2));
    
    if brComp == '1' % no brightness compensation
        s_m_brComp = s_m;
    elseif brComp == '2' % brigthness compensation using linear transform
        [s_m_brComp, ~] = func_transformLinear(s_ref, s_m);
    elseif brComp == '3' % brigthness compensation using affine transform
        [s_m_brComp, ~] = func_transformAffine(s_ref, s_m);
    end
    %hatOfBeta_array{m} = hatOfBeta;
    
    mean_of_s_m_brComp = mean(s_m_brComp, 2);
    row_sig_hat = [row_sig_hat mean_of_s_m_brComp];
    
    if mod(m, 500) == 0
        time_used = toc(start_time);
        remaining_time = (time_used / (m / numOfTotalFrames) - time_used) / 60; % unit: min
        %disp(['Remaining time (min): ', num2str(remaining_time)])
    end
end

mean_of_row_sig_hat = mean(row_sig_hat, 2);
row_sig = row_sig_hat - mean_of_row_sig_hat;

end