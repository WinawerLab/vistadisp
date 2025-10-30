save(filename,'pa','VP');

RestrictKeysForKbCheck([]); % Reenable all keys for KbCheck:
ListenChar; % Start listening to GUI keystrokes again
ShowCursor;
clear moglmorpher;
Screen('CloseAll');%sca;
clear moglmorpher;
Priority(0);
if VP.stereoMode == 8 && display ~=2
    Datapixx('SetPropixxDlpSequenceProgram',0);
    Datapixx('RegWrRd');
end
Datapixx('Close');