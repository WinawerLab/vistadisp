function [pa, kb, OnGoing] = check_resp(whichFrame,pa,kb)

OnGoing = 1;
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);

if kb.keyIsDown
    if kb.keyCode(kb.downArrowKey)
        kb.resp = 1;
    elseif kb.keyCode(kb.upArrowKey)
        kb.resp = 2;
    elseif kb.keyCode(kb.threeKey) % - green button
        kb.resp = 3;
    elseif kb.keyCode(kb.fourKey) %  - red button
        kb.resp = 4;
    elseif kb.keyCode(kb.escKey) || kb.keyCode(kb.qKey) % esc/q key, quit
        OnGoing = 0;
    else
        kb.resp = NaN;
    end
else
    kb.resp = NaN;
end

pa.responseMat(min([whichFrame size(pa.responseMat,1)]),1)= kb.resp; % button pressed
pa.responseMat(min([whichFrame size(pa.responseMat,1)]),2)= GetSecs-pa.expStart; % time so far

end