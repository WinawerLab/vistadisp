function [myamp, myphi, lefit] = sinFit(data)
% SINFIT - fits a single cycle sinusoid to a data vector
% usage: [a, p, y] = sinFit(x) returns the amp, phase, and fit vals
%           [a, p] = sinFit(x) returns the amp & phase
%           sinFit(x) plots the data and fit
%       Returned phase is in radians

% lkc 16/Mar/2011 wrote it 

%% preliminaries

n = length(data);
xrad = linspace(0,2.*pi,n);  % x axis in radians

% make the canonical sine and cosine
mysin = sin(xrad);
mycos = cos(xrad);

%% do the fitting

% Fourier's theorem + help from Euler's theorem
dx = 2./n;
myreal = sum(data.*mycos).*dx;
myim = sum(data.*mysin).*dx;

% Pythagoras 
myamp = sqrt(myreal.^2 + myim.^2);

% trigonomety (but we need to keep track of what quantrant we're in)
% myphi = atan(myim./myreal);
% ... or we could be lazy and let matlab keep track...
myphi = angle(complex(myreal, myim));

lefit = myamp.*cos(xrad-myphi);

%% plot if called with no output args
if ~nargout  
    plot(data);
    hold on
    plot(lefit, 'r');
    hold off
end
