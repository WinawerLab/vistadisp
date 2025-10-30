function VP = setup_display(skipSync,Display,debugTrigger)
if 1 == skipSync %skip Sync to deal with sync issues
    Screen('Preference','SkipSyncTests',1);
end
VP.debugTrigger = debugTrigger;
global GL;
AssertOpenGL;
InitializeMatlabOpenGL(0,3);
PsychImaging('PrepareConfiguration');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEFINE DISPLAY SPECIFIC VIEWING CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch(Display) %Display Parameters

    case 1 % NYUAD
        VP.screenDistance = 880;   %mm 83.5
        VP.IOD = 58;               %mm
        VP.screenWidthMm = 711;  % 719.8875 (new AD)
        VP.screenHeightMm = VP.screenWidthMm*9/16; %207.8;     %mm
        VP.whiteValue = 255;
        VP.stereoMode = 0;         % set to 1 for a propixx
        VP.multiSample = 32;       % PTB will change automatically to max supported on your display
        VP.fullscreen = [];
    case 2 % puti laptop
        VP.screenDistance = 500;   %mm
        VP.IOD = 62.5;               %mm
        VP.screenWidthMm = 332.5;      %mm
        VP.screenHeightMm = 207.8;     %mm
        VP.whiteValue = 255;
        VP.stereoMode = 0;
        VP.multiSample = 32;      
        VP.fullscreen = [0 0 800 500];
%         VP.fullscreen = [];

    case 3 % NYU CBI
        VP.screenDistance = 880;   %mm
        VP.IOD = 66.5;               %mm
        VP.screenWidthMm = 711;
        VP.screenHeightMm = VP.screenWidthMm*9/16; %207.8;     %mm
        VP.whiteValue = 255;
        VP.stereoMode = 0;         % set to 1 for a propixx
        VP.multiSample = 32;       % PTB will change automatically to max supported on your display
        VP.fullscreen = [];
end
%Display Parameters Switch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SETUP PSYCHTOOLBOX WITH OPENGL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'Verbosity', 3); % Increase level of verbosity for debug purposes:
Screen('Preference','VisualDebugLevel', 3);%control verbosity and debugging, level:4 for developing, level:0 disable errors
VP.screenID = max(Screen('Screens'));    %Screen for display.
VP.centerPatch = 0.75;
switch Display
    case 2
    otherwise
        PsychImaging('AddTask','General','UseDataPixx'); % Tell PTB we want to display on a DataPixx device.

        if ~Datapixx('IsReady')
            Datapixx('Open');
        end

        if (Datapixx('IsVIEWPixx'))
            Datapixx('EnableVideoScanningBacklight');
        end
        Datapixx('EnableVideoStereoBlueline');
        Datapixx('SetVideoStereoVesaWaveform', 2);      % If driving NVIDIA glasses

        if Datapixx('IsViewpixx3D') && UseDCdriving
            Datapixx('EnableVideoLcd3D60Hz');
        end
        Datapixx('RegWrRd');

        if VP.stereoMode == 8
            Datapixx('SetPropixxDlpSequenceProgram',1); % 1 is for RB3D mode, 3 for setting up to 480Hz, 5 for 1440Hz
            Datapixx('RegWr');
            Datapixx('SetPropixx3DCrosstalkLR', 0); % minimize the crosstalk
            Datapixx('SetPropixx3DCrosstalkRL', 0); % minimize the crosstalk
        end
end

VP.Display = Display;
VP.backGroundColor = [255/2 255/2 255/2];
[VP.window,VP.Rect] = PsychImaging('OpenWindow',VP.screenID,VP.backGroundColor,VP.fullscreen,[],[], VP.stereoMode, VP.multiSample);

[VP.windowCenter(1),VP.windowCenter(2)] = RectCenter(VP.Rect); %Window center
VP.windowWidthPix = VP.Rect(3)-VP.Rect(1);
VP.windowHeightPix = VP.Rect(4)-VP.Rect(2);

% TODO: Check which stereomodes this will be correct for and update
% accordingly
if VP.stereoMode == 4
    VP.screenWidthPix = 1.5*VP.windowWidthPix;
    VP.screenWidthPix = 1*VP.windowWidthPix;
else
    VP.screenWidthPix = VP.windowWidthPix;
end
VP.screenHeightPix = VP.windowHeightPix;

%Hmmm, Blending needs to be set both within and outside the BeginOpenGL
% context, which seems weird
glBlendFunc(GL.SRC_ALPHA,GL.ONE_MINUS_SRC_ALPHA); %Alpha blending for antialising
Screen('BeginOpenGL',VP.window); %Setup the OpenGL rendering context
glViewport(0,0,VP.windowWidthPix,VP.windowHeightPix); %Define viewport
glDisable(GL.LIGHTING); %Disable lighting; interacts with alpha blending (and often supersedes with unwanted results)
glEnable(GL.DEPTH_TEST); %glDepthFunc(GL.LESS); %glDepthFunc(GL.LEQUAL); %Occlusion handling
glEnable(GL.BLEND); glBlendFunc(GL.SRC_ALPHA,GL.ONE_MINUS_SRC_ALPHA); %Alpha blending for antialising
Screen('EndOpenGL',VP.window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEFINE STRUCTURE HOLDING ALL VIEWING PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Viewing Parameters
VP.ifi = Screen('GetFlipInterval', VP.window);
VP.frameRate = 1/VP.ifi;
% Calculate the width of one eye's view (in deg)
VP.screenWidthDeg = 2*atand(0.5*VP.screenWidthMm/VP.screenDistance);
VP.pixelsPerDegree = VP.screenWidthPix/VP.screenWidthDeg; % calculate pixels per degree
VP.pixelsPerMm = VP.screenWidthPix/VP.screenWidthMm; %% pixels/Mm
VP.MmPerDegree = VP.screenWidthMm/VP.screenWidthDeg;
VP.degreesPerMm = 1/VP.MmPerDegree;

if VP.stereoMode == 4
    [VP.window,VP.Rect]=PsychImaging('OpenWindow', VP.screenID, VP.backGroundColor, [0 0 1920 1080], [], [], VP.stereoMode, VP.multiSample);
    SetStereoSideBySideParameters(VP.window, [1,0], [1, 1], [0,0], [1, 1]);
end

% VP.frameRate
% Define some colors - These are wrong in GL Context - eg glClearColor [0,1]
VP.white= WhiteIndex(VP.screenID);
VP.black= BlackIndex(VP.screenID);
VP.gray= (VP.white+VP.black)/2;
if round(VP.gray)==VP.white
    VP.gray=VP.black;
end
VP.inc=VP.white-VP.gray;

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', VP.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
priorityLevel=MaxPriority(VP.window);
Priority(priorityLevel);