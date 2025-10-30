function doRetinotopyScan(params)
% doRetinotopyScan - runs retinotopy scans
%
% doRetinotopyScan(params)
%
% Runs any of several retinotopy scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.
% 11.09.15 JW added a check for modality. If modality is ECoG, then call
%           ShowScanStimulus with the argument timeFromT0 == false. See
%           ShowScanStimulus for details. 
% 02.20.23  JK Added option to specify subject ID inside params. sesNUM is
%           also read from the main script and changed timeFromT0 to false.

% defaults
if ~exist('params', 'var'), error('No parameters specified!'); end

% make/load stimulus
stimulus = retLoadStimulus(params);

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);%clear

fprintf('\n')
if ~isfield(params,'initials')
    initials = input('Please enter subjct initials: ', 's');
else
    initials = params.initials;
end

% sesNum = input('Please enter session number: ', 's');

sesNum = double(params.sesNum);

sesFileName = sprintf('%s%d', initials, sesNum);

while exist(sprintf('%s.edf',sesFileName), 'file')
    
    fprintf('\nFilename %s exists. Please re-enter subj ID and session number.\n', sesFileName)
    initials = input('Please enter subjct initials: ', 's');
    sesNum = input('Please enter session number: ', 's');
    sesNum = str2double(sesNum);
    sesFileName = sprintf('%s%d%s', initials, sesNum);
    
end
   
try

    % check for OpenGL
    AssertOpenGL;
    
    % to skip annoying warning message on display (but not terminal)
    Screen('Preference','SkipSyncTests', 1);
    Screen('Preference','TextRenderer', 0);
    
    % Open the screen
    params.display                = openScreen(params.display);
    params.display.devices        = params.devices;
    
    if contains(params.fixation,'emoji')
    [params, stimulus] = retLoadEmoji(params, stimulus);
    end
    % to allow blending
    Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %% Initialize EyeLink if requested
    if params.doEyelink
        
        fprintf('\n[%s]: Setting up Eyelink..\n',mfilename)
        
        Eyelink('SetAddress','192.168.1.5');
        el = EyelinkInitDefaults(params.display.windowPtr);
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
            error('link_sample_data error, status: %d', s)
        end
   
        el = prepEyelink(params.display.windowPtr);            
        
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
         if (params.sesNum == 1) || (params.sesNum == 5)
        cal = EyelinkDoTrackerSetup(el);
         end
    end
        
    
    %% Create stimuli
    
    % Store the images in textures
    stimulus = createTextures(params.display,stimulus);
    
    % If necessary, flip the screen LR or UD  to account for mirrors
    % We now do a single screen flip before the experiment starts (instead
    % of flipping each image). This ensures that everything, including
    % fixation, stimulus, countdown text, etc, all get flipped.
    retScreenReverse(params, stimulus);
    
    % If we are doing ECoG, then add photodiode flash to every other frame
    % of stimulus. This can be used later for syncing stimulus to electrode
    % outputs.
    stimulus = retECOGtrigger(params, stimulus);
    
    % [params, stimulus] = retLoadEmoji(params, stimulus);
    
    for n = 1:params.repetitions,
        % set priority
        Priority(params.runPriority);
        
        % reset colormap?
        retResetColorMap(params);
        
        % wait for go signal
        onlyWaitKb = false;
        pressKey2Begin(params.display, onlyWaitKb, [], [], params.triggerKey);


        % If we are doing eCOG, then signal to photodiode that expt is
        % starting by giving a patterned flash
        retECOGdiode(params);
        
        % countdown + get start time (time0)
        [time0] = countDown(params.display,params.countdown,params.startScan, params.trigger);
        time0   = time0 + params.startScan; % we know we should be behind by that amount
        
        
        % go
        if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
            timeFromT0 = false;
        else timeFromT0 = false;
        end
        
        if params.doEyelink
            Eyelink('StartRecording');
        end
      
        [response, timing, quitProg] = showScanStimulus(params.display,params.responseKeys,stimulus,time0, timeFromT0); %#ok<ASGLU>
        
        if ~isfield(params,'savefilepath')
            savename = fullfile(fileparts(vistadispRootPath), ...
                sprintf('%s_%s', sesFileName, datestr(now,30)));
        else
            savename = fullfile(params.savefilepath, ...
                sprintf('%s_%s', sesFileName, datestr(now,30)));
        end
        
        if params.doEyelink
            
            Eyelink('StopRecording');
            Eyelink('ReceiveFile', ELfileName, fileparts(vistadispRootPath) ,1);
            Eyelink('CloseFile');
            movefile(sprintf('%s/%s',fileparts(vistadispRootPath),ELfileName),sprintf('%s.edf',savename))
            
            if params.sesNum == 4
                Eyelink('Shutdown');
            end
 
        end
        
        % reset priority
        Priority(0);
        
        % get performance
        [pc,rc] = getFixationPerformance(params.fix,stimulus,response);
        fprintf('[%s]: percent correct: %.1f %%, reaction time: %.1f secs\n',mfilename,pc,rc);
        
        % save
        if params.savestimparams
            filename = sprintf('%s.mat',savename);
            save(filename);                % save parameters
            fprintf('[%s]:Saving in %s.\n',mfilename,filename);
        end
        
        % don't keep going if quit signal is given
        if quitProg, break; end
        
    end
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);

catch ME
    % clean up if error occurred
    Screen('CloseAll'); setGamma(0); Priority(0); ShowCursor;
    warning(ME.identifier, ME.message);
end

return;



   




