clc
clear all;
cd('/Users/matthewbain/Documents/Science/Experiments/efflisisc/experiment/')
addpath(genpath('matlab'))
rng_cfig = rng(257);
            
% (*) define file params
story = 2;

% (*) define params
maxdiff = .5;  % allowable difference between concat sent dur and story 
RMS     = -28; % SNR for normalization

% input
seg_all = dir(fullfile(['segments' '/' 'story' num2str(story)], ['audio_' num2str(story) '*.wav']));
seg_times = dir(fullfile(['segments' '/' 'story' num2str(story)], ['audio_' num2str(story) '*.csv']));

% savefile
savefile = ['stories' '/' 'story' num2str(story) '_scrambled' '.wav'];

% CONCATENATE SENTENCES IN SCRAMBLED ORDER
% get random permutation of segments
sent_ix = randperm(length(seg_all), length(seg_all));

audio_scram = [];
for i = 1:length(sent_ix)
    % read in current sentence
    [seg, sf] = audioread(['segments' '/' 'story' num2str(story) '/' seg_all(sent_ix(i)).name]);
    
    % normalize segment
    %seg = wav_normalize(seg, RMS, 'r');
    
    % add current sentence to scrambled story
    audio_scram = [audio_scram seg'];
end

% normalize concatenated story
audio_scram = wav_normalize(audio_scram, RMS, 'r');

% SAVE --------------------------------------------------------------------
% SAVE NEW SENTENCE ORDER
% read in segment times
seg_times = csvread(['segments' '/' 'story' num2str(story) '/' seg_times(1).name]);

% new positions of all sentences
for i = 1:length(seg_times)
    seg_times(i,3) = find(seg_times(i,3) == sent_ix);
end

% save new sentence order
xlswrite(['stories' '/' 'story' num2str(story) '_scrambled' '.xlsx'], seg_times);

% write scrambled story
audiowrite(savefile, audio_scram, sf);

disp('finished')