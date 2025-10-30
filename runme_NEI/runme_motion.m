% moving vs. static
% central moving -> central stationary -> right moving -> right stationary -> left moving -> left stationary [repated 3 times]
% code was written based on Puti's motion localizer

tbUse vistadisp
clearvars; close all; clc
debugTrigger = 0; %0;
display = 3;   % 1-AD % 2-laptop % 3-NY
params.doEyelink = 0; %0;
Screen('Preference', 'TextRenderer', 0); % For draw formatted text

addpath(genpath('./MT_loc/HelperToolbox'));

wlsubjnum = input('What is the subject wlsubj number? \n\n','s');
subID = sprintf('%s_',wlsubjnum);

runs = 3;
mydir  = '/Users/winawerlab/matlab/toolboxes/vistadisp/data_NEI/mot';

%%
for r = 1 : runs
    
    
    filename = [mydir '/sub-' subID,'task-motion_' 'run-' num2str(r), '_' datestr(now,30) '.mat'];
    eyeLinkFileName = sprintf('%s.edf',[subID,'mot_' 'run-' num2str(r)]);
    %% Setup display and parameters
    skipSync = 1;                                                              % skip Sync for debugging
    VP = setup_display(skipSync, display ,debugTrigger);                       % set up display
    [VP, pa] = setup_param_motion(VP);
    kb = SetupKeyboard();
    
    
    
    if params.doEyelink
        
        if r == 1
        
        fprintf('\n[%s]: Setting up Eyelink..\n',eyeLinkFileName)
        
        Eyelink('SetAddress','192.168.1.5');
        el = EyelinkInitDefaults(VP.window);
        EyelinkUpdateDefaults(el);
        %
        % %     Initialize the eyetracker
        Eyelink('Initialize', 'PsychEyelinkDispatchCallback');
        % %     Set up 5 point calibration
        s = Eyelink('command', 'calibration_type=HV5');
        %
        % %     Calibrate the eye tracker

        
        EyelinkDoTrackerSetup(el);
        
        %
        % %     Throw an error if calibration failed
        if s~=0
            error('link_sample_data error, status: ', s)
        end
        
        el = prepEyelink(VP.window);
        
        end
        
        sesFileName = sprintf('%s%d%s', subID, num2str(r));
        
        
        ELfileName = sprintf('%s.edf', sesFileName);
        
        edfFileStatus = Eyelink('OpenFile', ELfileName);
        
        if edfFileStatus ~= 0, fprintf('Cannot open .edf file. Exiting ...');
            try
                Eyelink('CloseFile');
                Eyelink('Shutdown');
            end
            return;
        else
            fprintf('\n[%s]: Succesfully openend Eyelink file..\n',mfilename)
        end
        
%         cal = EyelinkDoTrackerSetup(el);
        
        
    end

    
                                                  % set up keyboard
    %% Exp start
    [VP, kb] = wait_trigger(display,kb,VP,pa);                                 % waiting for trigger
    
    if params.doEyelink
        Eyelink('StartRecording');
    end
    
    OnGoing = 1;                                                               % continue running the experiment if OnGoing == 1                                                         % start with frame 1
    while OnGoing == 1
        pa.expStart = GetSecs;                                                 % start time for the experiment
        whichLoc = 0;                                                          % which motion localizer to run
        whichColor = 1;                                                        % which fixation color
        taskLastChange = pa.expStart;                                          % how much time has passed since the last fixation change
        whichFrame = 1;
        
        for block = 1:pa.nRepBlock
            
            startTime = GetSecs;
            whichLoc = pa.conditionOrder(block);
            if whichLoc ==1                                                    % if 1st initiate dotMat
                dotMat = zeros(pa.nDots,round(pa.blockDuration*VP.frameRate),2);
            end
            
            pa.theta = (2*pi .* rand(1,pa.nDots))-2*pi;                        % initialize random dot theta
            pa.r = sort((((pa.rmax - pa.rmin) .* (rand(1,pa.nDots).^(1/2))) + pa.rmin)); % initialize random dot radius
            
            timeLastFlipped = GetSecs;
            
            while GetSecs-startTime < pa.blockDuration                         % block ends when time's up
                
                if whichLoc ~= [4 5 6]                                           % whichLoc 5 is static
                    
                    if pa.dotdies == 1
                        pa.lifetime = pa.lifetime + 1/VP.frameRate;
                        dotsOut = pa.lifetime >= pa.totalLife;
                        pa.lifetime(dotsOut) = 0;
                        pa.r(dotsOut) = (pa.rmax - pa.rmin) .* (rand(1,sum(dotsOut)).^(1/2)) + pa.rmin;
                        pa.theta(dotsOut) = (2*pi .* rand(1,sum(dotsOut)))-2*pi;
                    end
                    
                    % outward % move dots based on time past and check which dots is out
                    
                    outward = 1:length(pa.r)/2;
                    inward = length(pa.r)/2+1:length(pa.r);
                    
                    
                    pa.r(outward)   = pa.r(outward) + pa.pps * (GetSecs-timeLastFlipped) * pa.r(outward).^(1/2)./max(pa.r(outward).^(1/2)); % scale dots speed down near center
                    pa.r(inward)    = pa.r(inward)- pa.pps * (GetSecs-timeLastFlipped) * pa.r(inward).^(1/2)./max(pa.r(inward).^(1/2)); % scale dots speed down near center
                    timeLastFlipped = GetSecs;
                    
                    %                 pa.r(outward) = pa.r(outward) + pa.pps / VP.frameRate * pa.r(outward).^(1/2)./max(pa.r(outward).^(1/2)); % scale dots speed down near center
                    %                 pa.r(inward) = pa.r(inward) - pa.pps / VP.frameRate * pa.r(inward).^(1/2)./max(pa.r(inward).^(1/2)); % scale dots speed down near center
                    
                    dotsOut = pa.r >= pa.rmax;                             % when dots exit they die
                    pa.r(dotsOut) = (pa.rmax - pa.rmin) .* (rand(1,sum(dotsOut)).^(1/2)) + pa.rmin; % update with new dots
                    pa.theta(dotsOut) = (2*pi .* rand(1,sum(dotsOut)))-2*pi; % update with new dots
                    
                    [x, y] = pol2cart(pa.theta, pa.r);                          % convert theta and radius to x-y coordinates
                    
                else                                                           % static
                    
                end
                
                % change the fixation color at a random time (2 to 12 secs)
                if GetSecs-taskLastChange > (6+rand*15)
                    whichColor = whichColor+1;
                    taskLastChange = GetSecs;
                else
                end
                
                
                if whichLoc == 1
                    
                    Screen('DrawDots',VP.window, [x+VP.Rect(3)/2;y+VP.Rect(4)/2], pa.dotDiameter, pa.dotColor, [0 0], 2); % dots
                    Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(iseven(whichColor)+1,:), [VP.Rect(3)/2, VP.Rect(4)/2]); % fixation cross
                    Screen('DrawingFinished', VP.window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                elseif whichLoc == 2
                    
                    Screen('DrawDots',VP.window, [x+VP.Rect(3)/2;y+VP.Rect(4)/2], pa.dotDiameter, pa.dotColor, [pa.locOfStimPer*VP.pixelsPerDegree 0], 2); % dots
                    Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(iseven(whichColor)+1,:), [VP.Rect(3)/2, VP.Rect(4)/2]); % fixation cross
                    Screen('DrawingFinished', VP.window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                elseif whichLoc == 3
                    
                    Screen('DrawDots',VP.window, [x+VP.Rect(3)/2;y+VP.Rect(4)/2], pa.dotDiameter, pa.dotColor, [-pa.locOfStimPer*VP.pixelsPerDegree 0], 2); % dots
                    Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(iseven(whichColor)+1,:), [VP.Rect(3)/2, VP.Rect(4)/2]); % fixation cross
                    Screen('DrawingFinished', VP.window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                elseif whichLoc == 4
                    
                    Screen('DrawDots',VP.window, [x+VP.Rect(3)/2;y+VP.Rect(4)/2], pa.dotDiameter, pa.dotColor, [0 0], 2); % dots
                    Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(iseven(whichColor)+1,:), [VP.Rect(3)/2, VP.Rect(4)/2]); % fixation cross
                    Screen('DrawingFinished', VP.window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                elseif whichLoc == 5
                    
                    Screen('DrawDots',VP.window, [x+VP.Rect(3)/2;y+VP.Rect(4)/2], pa.dotDiameter, pa.dotColor, [pa.locOfStimPer*VP.pixelsPerDegree 0], 2); % dots
                    Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(iseven(whichColor)+1,:), [VP.Rect(3)/2, VP.Rect(4)/2]); % fixation cross
                    Screen('DrawingFinished', VP.window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                elseif whichLoc == 6
                    
                    Screen('DrawDots',VP.window, [x+VP.Rect(3)/2;y+VP.Rect(4)/2], pa.dotDiameter, pa.dotColor, [-pa.locOfStimPer*VP.pixelsPerDegree 0], 2); % dots
                    Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(iseven(whichColor)+1,:), [VP.Rect(3)/2, VP.Rect(4)/2]); % fixation cross
                    Screen('DrawingFinished', VP.window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                end
                
                VP.vbl = Screen('Flip', VP.window, [] , 0);
                whichFrame = whichFrame + 1; % go to the next frame for the whole exp
                
                % check button press
                [pa, kb, OnGoing] = check_resp(whichFrame,pa,kb);
                if OnGoing == 0
                    break
                end
            end
        end
        
        %% finishing up with one block of blank screen
        Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(iseven(whichColor)+1,:), [VP.Rect(3)/2, VP.Rect(4)/2]);
        Screen('Flip', VP.window, [] , 0);
        if OnGoing == 0 % skip blank if OnGoing == 0
            break
        end
        while (GetSecs-pa.expStart) < pa.totalTime % blank screen at the end
        end
        OnGoing = 0;
    end
    finish_up
    
    if params.doEyelink
        
        Eyelink('StopRecording');
        Eyelink('ReceiveFile', ELfileName, fileparts(filename) ,1);
        Eyelink('CloseFile');
        movefile(sprintf('%s/%s',fileparts(filename),ELfileName),sprintf('%s.edf',[mydir '/' subID,'_mot_' 'run-' num2str(r)]))
        if r == 4
        Eyelink('Shutdown');
        end

    end
    
    
end
