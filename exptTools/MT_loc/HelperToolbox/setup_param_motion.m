function [VP pa] = setup_param_motion(VP)

% set up timing
pa.totalTime = 216;                                                        % code will run this many secs + X secs of blank
pa.blockDuration = 12;                                                     % duration for one block in secs
pa.nRepBlock = round(pa.totalTime./pa.blockDuration);                      % how many blocks 
pa.responseMat = zeros(round(pa.blockDuration*VP.frameRate*pa.nRepBlock),2); % if we want to record button press
pa.totalTime = pa.totalTime + pa.blockDuration;                            % real total time = stimulus + blank

% set up display size

pa.thetaDirs = 0;                                                          % polar angle(s) of aperture center
pa.rDirs = 10;                                                              % eccentricity of aperture center
pa.borderPatch = 4;                                                        % aperture size radius
pa.centerPatch = 0;                                                        % only matters if you want a donut
pa.rmin = pa.centerPatch * VP.pixelsPerDegree;                             % possible dot radius - lower boundary 
pa.rmax = pa.borderPatch * VP.pixelsPerDegree;                             % possible dot radius - upper boundary 

% set up dots

pa.nDots = 250;                                                            % number of dots
pa.dotDiameterinDeg = 0.15;                                                % dot diameter in deg
pa.dotDiameter = pa.dotDiameterinDeg * VP.pixelsPerDegree;                 % dot diameter in pixel
pa.dotColor = 255*ones(pa.nDots,3);                                        % dots are black and white
pa.dotColor(randperm(pa.nDots,pa.nDots/2),:) = zeros(pa.nDots/2,3);
pa.dotColor = pa.dotColor';
pa.locOfStimPer = 10;                                                      % peripheral location of the stimulus
pa.theta = (2*pi .* rand(1,pa.nDots))-2*pi;                                % initialize random dot theta
pa.r = (pa.rmax - pa.rmin) .* (rand(1,pa.nDots).^(1/2)) + pa.rmin;         % initialize random dot radius

% set up speed

pa.dps = 5 ;                                                               % speed - degree per second
pa.pps = pa.dps * VP.pixelsPerDegree;                                      % speed - pixal per second
pa.thetaspeed = 2*pi/(2*pa.borderPatch*pi/pa.dps)/VP.frameRate;            % speed - calculate rotating speed based on pa.dps
pa.dotdies = 1;                                                            % 1 - dots die; 0 - dots don't die
pa.totalLife = 0.5;                                                        % dot life time in secs
pa.lifetime = rand(pa.nDots,1)*pa.totalLife;                               % initialize random dot age

% set up fixation

pa.whereFixation = 2;                                                      % 1 top of screen; 2 middle of screen; 3 bottom of screen - if you put fixation at top/bottom you get 20 deg ecc for upper/lower meridian but I'm not sure if the script is ready
pa.fixationCrossLength = 5;                                                % fixation size - pixel
pa.fixationColor = [0 255 0;255 0 0];                                      % fixation color - green or red
fixationShift = VP.Rect(4)/2-(pa.borderPatch+1)*VP.pixelsPerDegree;        % one deg out of main aperture for the upper/lower fixation 
if pa.whereFixation == 1                                                   % top of screen
    pa.fixationDot =  [VP.Rect(3)/2, fixationShift];
    pa.fixationCross = [-pa.fixationCrossLength, pa.fixationCrossLength, 0, 0; fixationShift-VP.Rect(4)/2, fixationShift-VP.Rect(4)/2, fixationShift-VP.Rect(4)/2-pa.fixationCrossLength, fixationShift-VP.Rect(4)/2+pa.fixationCrossLength];
elseif pa.whereFixation == 3                                               % bottom of screen
    pa.fixationDot =  [VP.Rect(3)/2, VP.Rect(4)-fixationShift];
    pa.fixationCross = [-pa.fixationCrossLength, pa.fixationCrossLength, 0, 0; VP.Rect(4)-fixationShift-VP.Rect(4)/2, VP.Rect(4)-fixationShift-VP.Rect(4)/2, VP.Rect(4)-fixationShift-VP.Rect(4)/2-pa.fixationCrossLength, VP.Rect(4)-fixationShift-VP.Rect(4)/2+pa.fixationCrossLength];    
else                                                                       % middle of screen
    pa.fixationDot =  [VP.Rect(3)/2, VP.Rect(4)/2];
    pa.fixationCross = [-pa.fixationCrossLength, pa.fixationCrossLength, 0, 0; 0, 0, -pa.fixationCrossLength, pa.fixationCrossLength];
end

VP = MakeTextures(pa,VP);                                                  % make pink noise background around aperture

% set up design matrix
pa.conditionOrder = repmat(repelem([1 2 3], 1, 2),1,round(pa.nRepBlock/5)); % 1 1 2 2 3 3 4 4
pa.conditionOrder(2:2:end) = 5;

find_blank = find(pa.conditionOrder == 5);
insert_blankCond = repmat([4 5 6],[1 length(find_blank)/3]);

for f = 1 : length(insert_blankCond)
    pa.conditionOrder(find_blank(f)) = insert_blankCond(f);
end


pa.dsm = zeros(pa.totalTime,5); 
for block = 1:pa.nRepBlock
    pa.dsm((block-1)*pa.blockDuration+1,pa.conditionOrder(block)) = 1;
end
