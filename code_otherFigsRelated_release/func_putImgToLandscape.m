function [img, dim] = putImgToLandscape(img_raw)

dim_raw = size(img_raw);

% rotate image to landscape mode if necessary b/c rolling shutter sample
% rows of landscape images at different timeframe.
if dim_raw(1) > dim_raw(2)        % rotate the image to landscape
    img = imrotate(img_raw, 90);
    dim = size(img);
else                              % keep the original version
    img = img_raw;
    dim = dim_raw;
end