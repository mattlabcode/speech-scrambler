function [L_spl L_int L_loud] = ratio2db(r)

% [L_spl L_int L_loud] = ratio2dB(r)
%
% Input:
%	r - ratio of sound level (e.g. r=2 for double, r=0.5 for half)
%
% Output:
%	L_spl  - level change for objectively measured sound pressure (SPL, voltage)
%	L_int  - theoretically calculated sound intensity (acoustic power)
%	L_loud - level change for subjectively perceived loudness (volume)
%
% Description: The program provides different level changes in dB for a given 
% sound level ratio. Nice additional information can be found here:
%
% http://www.sengpielaudio.com/calculator-levelchange.htm
% -----------------------------------------------------------------------------------
% B. Herrmann, Email: bherrmann@cbs.mpg.de, 2011-11-21

nInputs = nargin;
if nInputs < 1 || isempty(r), fprintf('Error: r needs to be defined'); L_spl = []; L_int = []; L_loud = []; return; end;

% get level change in dB
L_spl  = 20 * log10(r); % level change for sound pressure level (voltage)
L_int  = 10 * log10(r); % level change for acoustic intensity (power)
L_loud = 10 * log2(r); % level change for psychoacoustic loudness (volume)

return;

