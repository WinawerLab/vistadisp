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
params.period               = 240;
params.responseDevice       = '932';
params.keyboard             = '932'; % 'Magic Keyboard'; %
params.responseKeys         = {'1';'2';'3';'4';'6';'7';'8';'9'};
params.displayGUI           = false;
params.savefilepath         = '/Users/winawerlab/matlab/toolboxes/vistadisp/data_NEI/floc'; %if not specified it will save files in vistarootpath dir

%% run it
wlsubjnum = input('What is the subject wlsubj number? \n\n','s');
params.initials = sprintf('%s_',wlsubjnum);

for ii = 1:4
    params.sesNum = ii;
    params.loadMatrix = sprintf('run%i_fLOC_240TRs_2hz.mat',ii);
    ret(params);
end

