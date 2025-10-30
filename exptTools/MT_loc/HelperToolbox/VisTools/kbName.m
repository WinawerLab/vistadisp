function result = KbName(arg)
% function result = KbName(arg)
% 	
% 	KbName maps between KbCheck-style keyscan codes and key names.
% 	
% 	¥	If arg is a string designating a key label then KbName returns the 
% 		keycode of the indicated key.  
% 	¥	if arg is a keycode, KbName returns the label of the designated key. 
% 	¥	if no argument is supplied then KbName returns the key name of the 
% 		next keypress detected. KbName waits for one second before scanning
% 		the keyboard for that keypress. This delay avoids catching the 
% 		<return> press used to execute the KbName function. 
% 			
% 	KbName deals with keys, not characters. See KbCheck help for an 
% 	explanation of keys, characters, and keycodes.   
% 	
% 	There are standard character sets, but there are no standard key 
% 	names.  The convention KbName follows is to name keys with 
% 	the primary key label printed on the key.  For example, the the "]}" 
% 	key is named "]" because "]" is the primary key label and "}" is the 
% 	shifted key function.  In the case of  labels such as "5", which appears 
% 	on two keys, the name "5" designates the "5" key on the numeric keypad 
% 	and "5%" designates the QWERTY "5" key. Here, "5" specifies the primary 
% 	label of the key and the shifted label, "%" refines the specification, 
% 	distinguishing it from keypad "5".  Keys labeled with symbols not 
% 	represented in character sets are assigned names describing those symbols, 
% 	for example the space bar is named "space" and the apple key is
% 	named "apple"
% 	
% 	Use KbName to make your scripts more readable and portable, using key 
% 	labels instead of keycodes, which are cryptic and may differ between Macs.  
% 	For example, 
% 	
% 	yesKey = KbName('return');           
% 	[a,b,keyCode] = KbCheck;
% 	if keyCode(yesKey)
% 		flushevents('keyDown');
% 		...
% 	end;
% 	
% 	See also KbCheck, KbDemo, KbWait.

% 	12/16/98  Allen Ingling wrote it
% 	2/12/99  Denis Pelli cosmetic editing of comments
% 	3/19/99  Denis Pelli added "enter" and "function" keys. Cope with hitting multiple keys.
%   1/18/02  Larry Cormack changed to return windows keycodes

kk = cell(256,1);

kk{9} = 'backspace';
kk{10} = 'tab';

kk{14} = 'return';

kk{17} = 'shift';
kk{18} = 'ctrl';
kk{19} = 'alt';
kk{20} = 'pause';
kk{21} = 'capslock';

kk{28} = 'escape';

kk{33} = 'spacebar';
kk{34} = 'page up';
kk{35} = 'page down';
kk{36} = 'end';
kk{37} = 'home';
kk{38} = 'left';
kk{39} = 'up';
kk{40} = 'right';       
kk{41} = 'down';

kk{45} = 'print screen';
kk{46} = 'ins';
kk{47} = 'del';

kk{49} = '0';
kk{50} = '1';
kk{51} = '2';
kk{52} = '3';
kk{53} = '4';		
kk{54} = '5';
kk{55} = '6';
kk{56} = '7';
kk{57} = '8';
kk{58} = '9';

kk{66} = 'a';
kk{67} = 'b';
kk{68} = 'c';
kk{69} = 'd';
kk{70} = 'e';
kk{71} = 'f';
kk{72} = 'g';
kk{73} = 'h';
kk{74} = 'i';
kk{75} = 'j';
kk{76} = 'k';
kk{77} = 'l';
kk{78} = 'm';
kk{79} = 'n';
kk{80} = 'o';
kk{81} = 'p';
kk{82} = 'q';
kk{83} = 'r';
kk{84} = 's';
kk{85} = 't';
kk{86} = 'u';
kk{87} = 'v';
kk{88} = 'w';
kk{89} = 'x';
kk{90} = 'y';
kk{91} = 'z';
kk{92} = 'windowz key left';
kk{93} = 'windowz key right';

kk{97} = '0 keypad';
kk{98} = '1 keypad';
kk{99} = '2 keypad';
kk{100} = '3 keypad';
kk{101} = '4 keypad';
kk{102} = '5 keypad';
kk{103} = '6 keypad';
kk{104} = '7 keypad';
kk{105} = '8 keypad';
kk{106} = '9 keypad';
kk{107} = '* keypad';
kk{108} = '+ keypad';

kk{110} = '- keypad';
kk{111} = '. keypad';
kk{112} = '/ keypad';

kk{113} = 'f1';
kk{114} = 'f2';
kk{115} = 'f3';
kk{116} = 'f4';
kk{117} = 'f5';
kk{118} = 'f6';
kk{119} = 'f7';
kk{120} = 'f8';
kk{121} = 'f9';
kk{122} = 'f11';
kk{123} = 'f12';

kk{145} = 'num lock';
kk{146} = 'scroll lock';

kk{187} = ';';
kk{188} = '=';
kk{189} = ',';
kk{190} = '-';
kk{191} = '.';
kk{192} = '/';
kk{193} = '`';
kk{221} = '\';
kk{223} = 'single quote';

unused = [1:8 12 13 15 16 22:27 29:32 42:44 48 59:65 ...			%unused codes
			94:97 109 124:145 147: 186 223:256];
			
used = setdiff(1:256,unused); %used codes

clear result
if nargin==0
	waitsecs(1);
	keyPressed = 0;
	while (~keyPressed)
		[keyPressed, secs, keyCode] = KbCheck;
	end %while
	result = kk{find(keyCode)};
elseif isa(arg,'double')  %argument is a number, so find the code
	% if more than one key is hit, we return an array
	result = [kk{arg}];
elseif ischar(arg)      %argument is a character, so find the code
	for i = used
		if strcmp(upper(kk{i}), upper(arg))
			result = i;
			break;
		end %if
	end %for i
end %elseif
		


