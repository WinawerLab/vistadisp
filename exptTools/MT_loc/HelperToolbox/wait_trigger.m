function [VP kb] = wait_trigger(display,kb,VP,pa)

for view = 0:1
    Screen('SelectStereoDrawbuffer', VP.window, view);
%     Screen('DrawTexture', VP.window, VP.bg);
    Screen('DrawDots',VP.window, pa.fixationDot, pa.dotDiameter*2, [VP.gray VP.gray VP.gray], [], 2);
    Screen('DrawLines', VP.window, pa.fixationCross, 2, pa.fixationColor(1,:), [VP.Rect(3)/2, VP.Rect(4)/2]);
    Screen('DrawText', VP.window, ['Please wait.'],VP.Rect(3)./2-150,VP.Rect(4)/2+50,[VP.whiteValue VP.whiteValue VP.whiteValue]);
end

VP.vbl = Screen('Flip', VP.window, [], 0);

%waiting for trigger
switch display

    case 3 %cbi
        kb.keyIsDown = 0;
        pause(0.5)
        while ~kb.keyIsDown
            [kb,~] = CheckTrigger_MRI_CBI(kb); % if response with response button MRI
            [kb,~] = CheckKeyboard(kb); % if response with keyboard
%             fprintf('>>>>>>>>>>> waiting for the trigger from the scanner.... \n')
        end
        fprintf('>>>>>>>>>>> trigger detected \n')

    otherwise
        kb.keyIsDown = 0;
        pause(0.3)
        while kb.keyIsDown == 0;
            [kb,~] = CheckKeyboard(kb); % if response with keyboard
        end
end

end
