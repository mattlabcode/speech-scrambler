clc
clear all;
cd('/Users/matthewbain/Documents/Science/Experiments/efflisisc/experiment/')
addpath(genpath('matlab'))
rng_cfig = rng(257);

% (*) define file params
story = 2;

% (*) define params (for sentences: .001++.001, [1 7], .1)
thresh     = .001;     % silence threshold level
dur_mm     = [1 7];    % min and max segment duration (s)
sil_thresh = .1;       % allowable length of any silence w/in segment (.04?)
do_save    = 1;

% input
if story == 1
    audiofile = '/Users/matthewbain/Documents/Science/Experiments/efflisisc/experiment/stories/story_arctic.wav';
elseif story == 2
    audiofile = '/Users/matthewbain/Documents/Science/Experiments/efflisisc/experiment/stories/story_swim.wav';
end
[y, sf]   = audioread(audiofile);

% savefile
outdir_seg = 'segments';
savefile_seg = [outdir_seg '/' 'story' num2str(story) '/' 'audio_' num2str(story) '_segtimes_sen' '.xlsx'];

% SEGMENT AUDIO INTO SENTENCES --------------------------------------------
% run
seg_times = audio_splice(y, sf, thresh, dur_mm, sil_thresh);    

% vector of all segments that still need to be trimmed
trim_ix = find(seg_times(:, 2) - seg_times(:, 1) > dur_mm(2)*sf);

% initialize counter for audio splicing
splice_ii = 0;

% raise thresh to increase sensitivity (detect sentences behind lots of background noise)
thresh = thresh + .001;

% re-run audio_splice until no segments that need to be trimmed remain
while isempty(trim_ix) == 0 && thresh > 0

    disp(length(trim_ix))
    % run for all segments to be trimmed
    for i = 1:length(trim_ix)
        
        % get current portion of original stim that needs trimming
        if seg_times(trim_ix(i), 2) > length(y) %***TEMP
            y_trim = y(seg_times(trim_ix(i), 1):end, :);
        else
            y_trim = y(seg_times(trim_ix(i), 1):seg_times(trim_ix(i), 2), :);
        end
        
        % run
        seg_times_new = audio_splice(y_trim, sf, thresh, dur_mm, sil_thresh);

        % get seg_times_new (from y_trim) in terms of original y
        seg_times_new = seg_times_new + seg_times(trim_ix(i), 1);
        
        % append new seg_times to existing seg_times
        seg_times = vertcat(seg_times, seg_times_new);

    end

    % remove old segs that have been trimmed
    seg_times(trim_ix, :) = [];
    
    % vector of all segments that still need to be trimmed
    trim_ix = find(seg_times(:, 2) - seg_times(:, 1) > dur_mm(2)*sf);
    
    % increment splice counter
    splice_ii = splice_ii + 1;
    
    % raise thresh to increase sensitivity
    thresh = thresh + .001;
end

%%{
% FIND ALL SEGMENTS BELOW MIN DUR AND APPEND TO END OF NEIGHBOURING SEG ---
sil2short = find((seg_times(:,2) - seg_times(:,1)) < dur_mm(1)*sf);

% repeat until no longer any segments below minimum duration
while ~isempty(sil2short)
    for i = 1:length(sil2short)
                
        % APPEND TOO-SHORT SEGMENT ONTO END OF NEIGHBOURING SEGMENT
        % find neighbouring segment (to left)
        neighseg = find(seg_times(:, 2) == (seg_times(sil2short(i), 1) - 1));
        
        % append too-short segment
        seg_times(neighseg,  2) = seg_times(sil2short(i), 2);
    end
    
    % remove old too-short segments
    seg_times(sil2short, :) = [];
        
    % update too-short segments after eliminating old ones
    sil2short = find((seg_times(:,2) - seg_times(:,1)) < dur_mm(1)*sf);
end
%}

% length of all segments exceeding max dur
%disp((seg_times(find(seg_times(:,2)-seg_times(:,1) > dur_mm(2)*sf), 2) - seg_times(find(seg_times(:,2)-seg_times(:,1) > dur_mm(2)*sf), 1))/sf);

% order seg_times
[sorted, sort_ix] = sort(seg_times(:, 1));
seg_times = seg_times(sort_ix, :);

% ENSURE SEGMENTS SPAN ENTIRE STORY ***rote
% adjust first segment to begin at start of story (base case)
seg_times(1,1) = 1;

% make sure each segment goes to end of next
for i = 1:length(seg_times) - 1
   seg_times(i, 2) = seg_times(i+1, 1);
end

% CUT AUDIO ---------------------------------------------------------------
for i = 1:length(seg_times)
    % get segment
    seg = y(seg_times(i, 1):seg_times(i, 2));
       
    if do_save
        audiowrite([outdir_seg '/' 'story' num2str(story) '/' 'audio_' num2str(story) '_s' num2str(i) '.wav'], seg, sf);
    end
end

% SAVE --------------------------------------------------------------------
% add sentence id column
if do_save
    xlswrite(savefile_seg, [seg_times/sf fix(1:length(seg_times))' (seg_times(:,2) - seg_times(:,1))/sf]); 
    
    disp(sum(seg_times(:,2) - seg_times(:,1))/sf)
end
 
disp('timings generated/audio written')