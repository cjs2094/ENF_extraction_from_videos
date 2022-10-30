function [rowSig_dirConcat, rowSig_zeroingOut, rowSig_dirConcat_1k, rowSig_zeroingOut_1k, paras]...
    = func_linearizationWithDirConcatAndZeroingOut(videoFileLocation, videoFileName)

filename = [videoFileLocation, '\rowSig_', videoFileName, '.mat'];
if isfile(filename) % if file exists.
    load(filename);
     
else % if file does not exist.
    vidObj = VideoReader([videoFileLocation, '\', videoFileName, '.mov']);
    numOfTotalFrames = vidObj.NumFrames; % value less than "number of total frames shown in Command Window"
    frameRate = vidObj.frameRate;
    height = vidObj.height;
    numOfTotalFrames_neareastIntegerOf1000 = 1000*floor(numOfTotalFrames/1000);
    
    brComp = '3'; % brightness compensation type
    n_ref_frame = 1001; % ref frame for brightness compensation
    
    
    [rowSig] = func_genRowSig(vidObj, numOfTotalFrames_neareastIntegerOf1000, n_ref_frame, brComp);
    clear vidObj
 
    % read .txt files
    [nominalFreq, Tro] = func_readNominalFreqAndTro(videoFileLocation);
    
    % find parameters
    fps = height*frameRate; % perceptual sampling frequency
    fs  = height/Tro; % actual sampling frequency
    M   = round(height / (Tro*frameRate));
    numOfZeros = M - height;
    fps_rounded = round(fps);
    fs_rounded  = round(fs);

    % produce row signals using direct concatenation and periodic
    % zeroing-out methods
    rowSig_dirConcat    = rowSig(:);
    [rowSig_zeroingOut] = func_zeroingOutVerOfRowSig(rowSig, height, M);

    % remove DC components
    rowSig_dirConcat  = rowSig_dirConcat  - mean(rowSig_dirConcat);
    rowSig_zeroingOut = rowSig_zeroingOut - mean(rowSig_zeroingOut);
    
    % downsample sigs to 1kHz
    fs_downsampled = 1000;
    [rowSig_dirConcat_1k ] = func_downsample(rowSig_dirConcat, fps, fs_downsampled);
    [rowSig_zeroingOut_1k] = func_downsample(rowSig_zeroingOut, fs, fs_downsampled);
     
    % store parameters
    paras.nominalFreq      = nominalFreq;
    paras.Tro              = Tro;
    paras.frameRate        = frameRate;
    paras.height           = height;
    paras.numOfZeros       = numOfZeros;
    paras.fs_rounded       = fs_rounded;
    paras.fps_rounded      = fps_rounded;
    paras.fs_downsampled   = fs_downsampled;
    paras.numOfTotalFrames = numOfTotalFrames_neareastIntegerOf1000;
    
    save(filename, 'rowSig_dirConcat', 'rowSig_zeroingOut', 'rowSig_dirConcat_1k', 'rowSig_zeroingOut_1k', 'paras');
end

%mkdir([videoFileLocation, '\', videoFileName]);



