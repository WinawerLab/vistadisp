function y = ojive(x, s, m)
% OJIVE     return a cumulative normal
% 
% ojive(x, [sigma], [mean])

switch nargin,
case 2,
    m = 0;
case 1,
    s = 1;
    m = 0;
end

z = (x-m)./s;   % normalize
y = erf(z);     % the error function
y = (y+1)./2;   % scale output to 0-1