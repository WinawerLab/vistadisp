function d = disp2depth(theta, D, ipd)
%
% DISP2DEPTH converts disparities to depth intervals 
%
%	disp2depth(theta, D, ipd) computes disparity
%   using:   D viewing distance (1m default)
%               ipd interpupillary distance (6.5 default)
%
%   enter theta in arcmin, D in m, and ipd in cm
%   d is returned in cm
%     
% see also: depth2disp
% 
% Lawrence K. Cormack

% history:
% 04/17/09  lkc Wrote it (thought I had done so years ago...).
% 10/6/09   jah corrected convert to radians (i thought something was fishy...)

%	*** handle the input arguments.  Real code starts	***
%	*** on line 80 										***
if nargin == 0,
	ipd = 6.5;
	D = 1;
	theta = 10;
	
elseif nargin == 1,
	ipd = 6.5;
	D = 1;
	
elseif nargin == 2,
	ipd = 6.5;
	
elseif nargin == 3,
	%do nothing
else
	error('invalid input arguments');
end	%	***  argument handling

D = 100.*D;     % do all calcs in cm

%theta = ipd.*d ./ (D.*(d+D));

theta = d2r(theta/60);     % convert to rad
d = (theta.*(D.^2)) ./ (ipd - theta.*D);
