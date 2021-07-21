function [R_spl R_int R_loud] = db2ratio(l)

% [R_spl R_int R_loud] = db2ratio(l)
%
% Input:
%	l - level change in dB
%
% Output:
%	R_spl  - ratio for objectively measured sound pressure (voltage)
%	R_int  - ratio for theoretically calculated sound intensity (acoustic power)
%	R_loud - ratio for subjectively perceived loudness (volume)
%
% Description: The program provides the ratio for a given level change in dB.
% Nice additional information can be found here:
%
% http://www.sengpielaudio.com/calculator-levelchange.htm
% -----------------------------------------------------------------------------------
% B. Herrmann, Email: bherrmann@cbs.mpg.de, 2011-11-21

nInputs = nargin;
if nInputs < 1 || isempty(l), fprintf('Error: l needs to be defined'); R_spl = []; R_int = []; R_loud = []; return; end;

% get ratio
R_loud = 2.^(l/10); % ratio for loudness (volume, psychoacoustics)
R_spl = 10.^(l/20); % ratio for sound pressure level (voltage)
R_int = 10.^(l/10); % ratio for acoustic intensity (power)

return;
