function seg_times = audio_splice(y, sf, thresh, dur_mm, sil_thresh)

% PUT PARAMS INTO CORRECT FORMAT
% convert audio to mono
if size(y, 2) > 1
    y = y(:, 1);
end

% make bits abs for thresholding
y_seg = abs(y);

% convert time params to samples
dur_mm     = dur_mm*sf;
sil_thresh = sil_thresh*sf;

% SEGMENT AUDIO INTO SENTENCES --------------------------------------------
% GET TALKING AND SILENCE INTERVALS
% logical array of values exeeding threshold (indicating speaking)
talk_times = y_seg > thresh;

% return whole speech segment if all values are talking or silence
if all(talk_times == talk_times(1))
    seg_times = [1 length(y)];
else
    % identify transition pts (all silent periods follow: diff([1 0 0 1]) = [-1 1])
    talk2sil = find(diff(talk_times) == -1);
    sil2talk = find(diff(talk_times) == 1);

    % make sure same number of transitions to talking and silence
    if length(talk2sil) > length(sil2talk)
        talk2sil = talk2sil(1:length(sil2talk));
    elseif length(sil2talk) > length(talk2sil)
        sil2talk = sil2talk(1:length(talk2sil));
    end
    
    % store silence/talking interval indices
    if isempty(talk2sil) || isempty(talk2sil)
            seg_times = [1 length(y)];
    else
        if talk2sil(1) < sil2talk(1)
            talk_bound = [sil2talk(1:end - 1), talk2sil(2:end)];
            sil_bound  = [talk2sil, sil2talk];
        else
            talk_bound = [sil2talk, talk2sil];
            sil_bound  = [talk2sil(1:end - 1), sil2talk(2:end)];
        end

        % lengths of all silent periods
        if ~isempty(sil_bound)
            sil_dur  = sil_bound(:, 2) - sil_bound(:, 1);

            % go through silent periods and fill in periods that don't exceed thresh_sil
            for i = 1:length(sil_dur)
                if sil_dur(i) < sil_thresh
                    talk_times(sil_bound(i, 1):sil_bound(i, 2)) = 1;
                end
            end    
        end

        % RE-CALCULATE TALKING INTERVLS
        if all(talk_times == talk_times(1))
            seg_times = [1 length(y)];
        else

            % identify transition points (all silent periods follow: diff([1 0 0 1]) = [-1 1])
            talk2sil = find(diff(talk_times) == -1);
            sil2talk = find(diff(talk_times) == 1);

            % make sure same number of transitions to talking and silence
            if length(talk2sil) > length(sil2talk)
                talk2sil = talk2sil(1:length(sil2talk));
            elseif length(sil2talk) > length(talk2sil)
                sil2talk = sil2talk(1:length(talk2sil));
            end

            if isempty(talk2sil) || isempty(talk2sil)
                seg_times = [1 length(y)];
            else
                % store silence/talking interval indices
                if talk2sil(1) < sil2talk(1)
                    sen_times = [sil2talk(1:end - 1), talk2sil(2:end)];
                else
                    sen_times = [sil2talk, talk2sil];
                end

                % lengths of all talking periods
                if isempty(sen_times)
                    seg_times = [1 length(y)];
                else 
                    talk_dur = sen_times(:, 2) - sen_times(:, 1);

                    % go through talking periods and eliminate any that don't meet length constrains
                    for i = 1:length(talk_dur)
                        if talk_dur(i) < dur_mm(1) || talk_dur(i) > dur_mm(2)
                            sen_times(i, :) = [0 0];
                        end
                    end

                    % eliminate zero rows
                    sen_times(all(sen_times == 0, 2), :) = [];

                    % GET ALL SILENCE SEGMENTS SURROUNDING SENTENCES --------------------------
                    %sil_times = zeros(length(sen_times)*2, 2);
                    sil_times = [];

                    if isempty(sen_times)
                        seg_times = [1 length(y)];
                    else
                        % MAIN CASE (all sentences)
                        if size(sen_times, 1) > 1
                            for i = 1:length(sen_times)-1
                                sil_times(end+1, 1:2) = [sen_times(i,2)+1 sen_times(i+1,1)-1];
                            end
                        end

                        % BASE CASE (beginning of audio to start of 1st sentence)
                        if sen_times(1,1) ~= 1
                            first_sil = [1 sen_times(1,1)-1];
                            sil_times = [first_sil; sil_times];
                        end    

                        % END CASE (end of last sentence to end of audio)
                        if sen_times(end) ~= length(y)
                            last_sil  = [sen_times(end)+1 length(y)];
                            sil_times = [sil_times; last_sil]; 
                        end

                        % concatenate sentence and silence segments
                        seg_times = [sen_times; sil_times];
                    end
                end
            end
        end
    end
end        
end