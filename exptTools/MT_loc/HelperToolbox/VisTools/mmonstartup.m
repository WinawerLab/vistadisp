function mmonstartup(time, dtype)
% 
% function mmonstartup(time, dtype)
% 
% Fill screen with grey background and waits given time for display to
% warm up.  Plays sound and text output on screen and mails relevant 
% parties when finished.
% 
% [time] = warm-up time in minutes, default time is 60 minutes.
% [dtype] = monitor type if want to load gamma table.
%       Supported Monitor types:
%           's' = sharp 42"
%               (see getgamma.m to add additional monitor gamma corrections.)
% 
% Example:
%   ...to warm for 6 sec:
%       monstartup .1
%   ...to warm for 6 sec and load Sharp 42" gamma (...gamma file on TBC's MBP)
%       monstartup .1 s
% 
% 
% T.Czuba UT 3-21-2008
% LKC bred mmonstratup from monstarup 2-25-2011

if ~exist('time','var');
    time = 60;
end
if ~exist('dtype','var')
    dtype = 'none';
end
if ischar(time)
    time = str2num(time);
end
bgcol = [128 128 128];  %grey
txtcol = [0 0 0];   %black
time = time*60; %convert warm-up time to seconds
savert = 5; %time in seconds for scrn saver to move words
KbName('UnifyKeyNames');
ListenChar(2);  %silence kb input
HideCursor

try
scrns = Screen('Screens');

[winPtr winRect] = Screen('OpenWindow',min(scrns));

%%  monitor gamma switch
    % Add additional case values for other monitors here and in getgamma.m  
switch dtype
    case 'none' %no monitor defined, dont load gamma
        oldgamma = Screen('ReadNormalizedGammaTable',winPtr);
    case 's'    %Sharp 42" LCD
        gamma = getgamma(dtype);
        oldgamma = Screen('LoadNormalizedGammaTable',winPtr,gamma);
        
end
%%
Screen('FillRect',winPtr,bgcol,winRect);

Screen('Flip',winPtr);

% %     M = Screen('GetImage',winPtr);
% % 
% %     imwrite(M,['/Volumes/LKCLAB/Users/TBC/Pictures/ssgreyG90.jpg'],'jpg','Quality',100);

fprintf(['\n',datestr(now),'\n']);
flag = 0;
tic
while 1
    t = toc;
    
    if ~flag && t>time  % wait for warm-up time
        Screen('Flip',winPtr);
        flag = 1;
        fprintf('\nMonitor warm-up time completed.\n');
        % call pcode - see LKC to add or remove mail recipients
        mailMonsWarm
        %load gong
        %sound(y(1:5:end),Fs/2)
    elseif flag && t>savert     %periodically move onscreen message
        Screen('DrawText',winPtr,'Monitor has been warmed up. Press any key to end.',rand*winRect(3),rand*winRect(4),txtcol,bgcol);
        Screen('Flip',winPtr);
        tic
    end
    
    [keyIsDown, secs, keyCode] = KbCheck;   %poll keyboard for presses
    
    if flag %&& any(keyCode) % Normal exit after warm-up time
        Screen('LoadNormalizedGammaTable',winPtr,oldgamma);
        Screen('CloseAll')
        ShowCursor
        ListenChar(0);
        break
    elseif ~flag && keyCode(KbName('ESCAPE'))  % Forced exit.
        Screen('LoadNormalizedGammaTable',winPtr,oldgamma);
        Screen('CloseAll')
        ShowCursor
        ListenChar(0);
        fprintf('Caution:: exited manually, only warmed up %g minutes\n', t/60)
        break
    end
    
end

catch % In case of an error, close screens and return kb control.
    Screen('LoadNormalizedGammaTable',winPtr,oldgamma);
    Screen('CloseAll');
    ShowCursor
    ListenChar(0);
    fprintf('Error occured. Monitor may not be warmed up as requested')
end