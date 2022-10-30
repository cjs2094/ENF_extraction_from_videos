function [nominalFreq, Tro] = func_readNominalFreqAndTro(videoFileLocation)

fn_sr = [videoFileLocation '\nominalFreq.txt'];
if exist(fn_sr, 'file') ~= 2
    disp(['folder ' vid_db ': nominalFreq.txt file does not exist.']);
end

fp = fopen(fn_sr, 'r');
formatSpec = '%f';
nominalFreq = fscanf(fp, formatSpec);
fclose(fp);

fn_sr = [videoFileLocation '\Tro.txt'];
if exist(fn_sr, 'file') ~= 2
    disp(['folder ' vid_db ': Tro.txt file does not exist.']);
end

fp = fopen(fn_sr, 'r');
formatSpec = '%f';
Tro = fscanf(fp, formatSpec);
fclose(fp);


