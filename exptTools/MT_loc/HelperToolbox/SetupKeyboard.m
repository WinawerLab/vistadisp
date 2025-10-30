function kb = SetupKeyboard()
% Setup universal Mac/PC keyboard and keynames

ListenChar(2); % Stop making keypresses show up in matlab
HideCursor;

% Restrict KbCheck to checking of ESCAPE key:
% RestrictKeysForKbCheck([KbName('ESCAPE'), KbName('m')]);

KbName('UnifyKeyNames');

kb.escKey = KbName('ESCAPE');
kb.oneKey = KbName('1!');
kb.twoKey = KbName('2@');
kb.threeKey = KbName('3#');
kb.fourKey = KbName('4$');
kb.fiveKey = KbName('5%');
kb.qKey = KbName('q');
kb.wKey = KbName('w');
kb.eKey = KbName('e');
kb.rKey = KbName('r');
kb.spaceKey = KbName('space');
kb.pKey = KbName('p');
kb.oKey = KbName('o');
kb.iKey = KbName('i');
kb.kKey = KbName('k');
kb.lKey = KbName('l');
kb.zKey = KbName('z');
kb.xKey = KbName('x');
kb.cKey = KbName('c');
kb.aKey = KbName('a');
kb.sKey = KbName('s');
kb.dKey = KbName('d');
kb.fKey = KbName('f');
kb.nKey = KbName('n');
kb.tKey = KbName('t');

kb.leftArrowKey = KbName('LeftArrow');
kb.rightArrowKey = KbName('RightArrow');
kb.upArrowKey = KbName('UpArrow');
kb.downArrowKey = KbName('DownArrow');
% Social psychology response keys
% kb.totallyAwayKey = KbName('1!');
% kb.somewhatAwayKey = KbName('q');
% kb.neutralKey = KbName('a');
% kb.somewhatTowardsKey = KbName('z');
% kb.totallyTowardsKey = KbName('LeftAlt');

% Could also use main rightmost keys (backspace - ctrl)
% kb.totallyAwayKey = KbName('DELETE');
% kb.somewhatAwayKey = KbName('\|');
% kb.neutralKey = KbName('Return'); % This evaluates to [40 158]
% kb.neutralKey = kb.neutralKey(1);
% kb.somewhatTowardsKey = KbName('RightShift');
% kb.totallyTowardsKey = KbName('RightControl');

% Alex style
kb.totallyAwayKey = KbName('d');
kb.somewhatAwayKey = KbName('f');
kb.neutralKey = KbName('space'); % This evaluates to [40 158]
kb.somewhatTowardsKey = KbName('j');
kb.totallyTowardsKey = KbName('k');

% More descriptive names
kb.towardsKey = KbName('z');
kb.awayKey = KbName('a');
kb.rivalryKey = KbName('m');
kb.breakKey = KbName('ESCAPE');

kb.lrotKey = KbName('1!');
kb.rrotKey = KbName('2@');

% Initialize KbCheck
kb.responseGiven = 0;
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1); %KbCheck(-1) - (8/24/22)
[x,y,kb.buttons] = GetMouse();