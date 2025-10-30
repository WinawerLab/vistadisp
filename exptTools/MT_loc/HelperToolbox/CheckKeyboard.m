function [kb,stop] = CheckKeyboard(kb)

kb.keyIsDown = 0;

[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);

stop = 0;

if kb.keyIsDown

    if kb.keyCode(kb.downArrowKey) % or towards / near
        kb.resp = 1;
    elseif kb.keyCode(kb.upArrowKey) % or away / far
        kb.resp = 2;
    elseif kb.keyCode(kb.escKey) || kb.keyCode(kb.qKey) % esc/q key, quit
        stop =1;
    else
    end
else
    kb.resp = NaN;
end

    
end