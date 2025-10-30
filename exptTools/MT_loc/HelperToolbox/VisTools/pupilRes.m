function [rl psf] = pupilRes(d, l, f)
%
% PUPILRES computes the diffraction-limited angular resolution 
%
%	pupilRes(d) computes Rayleigh limit in arcmin for a d mm pupil
%   pupilRes(d, l) computes it for wavelength l nm
%   pupilRes(d, l, f) computes linear limit for eye with focal length f
%     
%

% history:
% 1890      tlr (The Lord Rayleigh) - Wrote it.
% 07/13/10  lkc - cleaned up the code

%	*** handle the input arguments.  Real code starts	***
%	

if nargin == 0,
	d = 3;  
	l = 555;
	f = 17;
	
elseif nargin == 1,
	l = 555;
	f = 17;
	
elseif nargin == 2,
	f = 17;
	
elseif nargin == 3,
	%do nothing
else
	error('invalid input arguments');
end	%	***  argument handling

k = 1.22;

rtemp = asin(k*(l*10.^-9)/(d*10.^-3));     % Rayleigh-Airy relation
rl = 60.*rtemp.*180./pi;                   %convert to arcmin

psf  = (f.*10.^-3).*2.*sin(rtemp./2).*10.^6;          % microns on the retina


