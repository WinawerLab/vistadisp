tbUse vistadisp
% runme for fLOC
% 240 TRs
Screen('Preference', 'TextRenderer', 0); % For draw formatted text
%% 

params                      = retCreateDefaultGUIParams;
params.fixation             = 'dot';
params.tr                   = 1;
params.skipSyncTests        = 0;
params.calibration          = 'CBI_Propixx';
params.prescanDuration      = 0;
params.experiment           = 'experiment from file';
params.doEyelink            = false;
params.period               = 360;
params.responseDevice       = '932';
params.keyboard             = 'Magic Keyboard';
params.responseKeys         = {'1';'2';'3';'4';'6';'7';'8';'9'};
params.displayGUI           = false;
params.savefilepath         = '/Users/winawerlab/matlab/toolboxes/vistadisp/SF'; %if not specified it will save files in vistarootpath dir

%% run it

params.initials = 'XX'; % specify subjects initials

for ii = 1:4
    params.sesNum = ii;
    params.loadMatrix = sprintf('run%i_SF_noise_360TRs_1hz_1080.mat',ii);
    ret(params);
end

