sen = dir(fullfile('/sentences/audio 1', '*.wav'));

total_len = 0;
for s = 1:length(sen)
    [y, sf] = audioread([sen(s).folder '/' sen(s).name]);
    
    len = length(y)/sf; 
    total_len = total_len + len;
end

disp(total_len/60)
