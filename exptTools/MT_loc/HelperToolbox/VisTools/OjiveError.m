function chisq = OjiveError(p, x, y, sd)
% OJIVEERROR -  computes error of an ojive fit to data
%               
% chisq = OjiveError(p, x, y, sd) 
%   computes the chi-squared
%   error between a set of data and a cumulative normal
%       p - the starting parameter vector [slope, bias]
%       x, y, sd    - the data points and standard deviations
%                     (in the y-direction)
%
% *******************************************************************************
% * This function was written to be called by fminsearch() for fitting          *
% * psychometric functions to data, viz:                                        *
% * p = fminsearch(@OjiveError, [slopeGuess, Biasguess], [], x, ydata, sdevs)   *
% *******************************************************************************
%
% lkc, 10/30/2001

ymodel = ojive(x, p(1), p(2));          % compute cumulative normal
error = y-ymodel;                       % compute error ...
sq_error = error.^2;                    % and squared error
weighted_sq_error = sq_error./sd;       % weight by 1/s
chisq = sum(weighted_sq_error);         % and sum