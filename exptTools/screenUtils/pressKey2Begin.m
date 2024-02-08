function pressKey2Begin(display, onlyWaitKb, speak, promptString, triggerKey)
% pressKey2Begin(display, [onlyWaitKb=1], [speak=0], ...
% [promptString = 'please press any key to begin.'],[triggerKey = 'any'])
%
%   Displays 'please press any key to begin' on the SCREEN
%   just below the center of the screen and waits for the 
%   user to press a key.
%
%   if onlyWaitKb flag is true (default), we'll try to only wait for
%   internal keyboard keys (useful to avoid catching button presses from an
%   external device).
%
% SEE ALSO clickMouse2Begin dispStringInCenter

% 1/20/97 gmb wrote it.
% 07/2005 SOD modified
% 05/2008 RAS added 'speak' option. Defaults to 0, so it stops freaking me
% out. :)  
% 07/2008 RAS there were 2 versions in the repository. I chose to keep the
% one in screenUtils, removed the one in misc.
% 08/2011 vistateam added triggerKey as optional input. If a single
%       character experiment will wait for it to start scan. If 'any'
%       wait for any key.

if(~exist('onlyWaitKb','var') || isempty(onlyWaitKb))
    onlyWaitKb = true;
end

if(~exist('speak','var') || isempty(speak))
    speak = false;
end

if(~exist('triggerKey','var') || isempty(triggerKey))
	triggerKey = 'any';
end

if(~exist('promptString','var') || isempty(promptString))
	promptString = sprintf('Please wait.');
end



Screen('FillRect', display.windowPtr, display.backColorRgb);
drawFixation(display);
if iscell(promptString)
    % multi-line input: present each line separately
    nLines = length(promptString);
    vRange = min(.4, .04 * nLines/2);  % vertical axis range of message
    vLoc = 0.5 + linspace(-vRange, vRange, nLines); % vertical location of each line
    textSize = 20;
    oldTextSize = Screen('TextSize', display.windowPtr, textSize);
    charWidth = textSize/4.5; % character width
    for n = 1:nLines
        loc(1) = display.rect(3)/2 - charWidth*length(promptString{n});
		loc(2) = display.rect(4) * vLoc(n);
		Screen('DrawText', display.windowPtr, promptString{n}, loc(1), loc(2), display.textColorRgb);
    end
    drawFixation(display);
    Screen('Flip',display.windowPtr);
    Screen('TextSize', display.windowPtr, oldTextSize);
else
    % single line: present in the middle of the screen
    dispStringInCenter(display, promptString, 0.55);
end


if(speak)
    % this will only work on mac and is put here for cases where the screens
    % are mirrored and you may not see the 'go ahead' message.
    try
        system(sprintf('say %s',promptString));
    catch ME
        warning(ME.identifier, ME.message)
    end
end

% KbWait and KbCheck are device dependent
if onlyWaitKb && isfield(display,'devices'),
    % wait for input of experimentor only
    while ~KbCheck(display.devices.keyInputInternal),
        WaitSecs(0.01); % give time back to OS - important
    end;
else
    % We use KbCheck in a while loop instead of KbWait, as KbWait is
    % reported to be unreliable and would need a device input as well.
    % 
    % We can either wait for any key press (if triggerKey = 'any') or we
    % can wait for a specific trigger key (if triggerKey has any other
    % value)
    % 
    iwait = 0;
    if strcmpi('any', triggerKey)
        while ~KbCheck(-1)
            WaitSecs(0.01);
        end
    else  % wait for the specific key set by 'triggerKey'      
        while ~iwait
            WaitSecs(0.01); 
            [keyIsDown, ~, c] = KbCheck(-1);
            if keyIsDown
                str = KbName(find(c));
                % we just compare the first element in str and triggerKey
                % because if KbName and KbCheck when used togegther can
                % return unwanted characters (for example, KbName(KbCheck)
                % return '5%' when only the '5' key is pressed).
                if strcmpi(str(1), triggerKey(1)) 
                    iwait = 1;
                end
            end
        end        
    end
end


return;


















