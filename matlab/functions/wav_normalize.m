function yn = wav_normalize(y, minusdB, type)

% yn = wav_normalize(y, minusdB, type)
%
% Obligatory inputs:
%	y - sound vector, mono
%	minusdB - must be a negative number, e.g. -24, because an amplitude of 1 is an implicit reference
%	          dB refers to sound preasure level (SPL)
%
% Optional inputs (defaults):
%	type = 'r'; % r - RMS, p - peak
%
% Output:
%	yn - normalized sound vector
%
% Description: The program normalizes a given sound vector either to a given RMS or peak.
%
% NOTE: A warning is issued if clipping would occur using the RMS method;
% however, in such a case peak is automatically set to 0 dB; please note, however,
% that in such a case RMS levels over files might *not* be equal anymore.
% ------------------------------------------------------------------------------------
% J. Obleser, B. Herrmann, Email: bherrmann@cbs.mpg.de, 2011-11-24

% minusdB  must be a negative number, e.g. -6 ;
if minusdB > 0
	minusdB = -(minusdB);
end

% get factor/ratio for normalization
fact = 10^(minusdB / 20);

% do normalization
if type == 'p'
	yn = y .* (fact / max(abs(y)));
elseif type == 'r'
	yn = y .* (fact / sqrt(mean(y.^2)));
end

