function [kb,stop] = CheckTrigger_MRI_CBI(kb)

stop = 0;

Datapixx('RegWrRd');
kbchk = dec2bin(Datapixx('GetDinValues'));
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1); % for checking escape %(kb.ID)

% check the response button
% % scanner
Datapixx('RegWrRd');

if kb.keyCode(kb.fiveKey) %kb.keyCode(kb.tKey) || 
    kb.resp = 5;
    kb.keyIsDown = 1;

elseif kb.keyCode(kb.escKey) || kb.keyCode(kb.qKey) % esc/q key, quit
    stop =1;
end


end