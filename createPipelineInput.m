function pipelineInput = createPipelineInput(test, input, preProcessSteps, overrides)
%function pipelineInput = createPipelineInput(test, input, preProcessSteps, overrides)
%for example:
%   test = 'hand1';
%   input.mffBasePath = '/depot/home/lbuser/data/eeg1028/mffs/sub_1/';
%   input.edfBasePath = '/depot/home/lbuser/data/eeg1028/edfs/sub_1/';
%   input.mriPath = '/depot/home/lbuser/data/MRI/t1.nii';
%   overrides.prepEegData.sensorCoordinatesPath =
%   '/depot/home/lbuser/data/eeg1028/mffs/sub_1/coordinates.xml';
%   preprocessSteps = ''; %use default ordering by setting to empty
%   pipelineInput = createPipelineInput(test, input, '', S);
%   inputs:
%       test: the name of the test, used for creating the data directory
%       input: a struct with fields for
%           file - full path of file input for the first preprocess step
%               note: if first preprocess step is "convert' (default), then
%               this is the edf file with the data
%           mriPath - full path to MRI for forward model reconstruction
%           if the first preprocess step is "convert" (default), then the
%           following fields are also required
%               mffPath - full path to mff file
%       overrides (optional):
%       struct with overrides for any of the following generated fields
%           convert
%               see spm_eeg_convert
%           dataPrep
%               see prepEegData
%           montage
%               see spm_eeg_montage
%           hpFilter
%               see spm_eeg_filter
%           lpFilter
%               see spm_eeg_filter
%           downsample
%               see spm_eeg_downsample
%           epochs
%               see spm_eeg_epochs
%           average
%               see spm_eeg_average
%assumptions:
%   1) mff import installed, see help prepEvents
%   2) spm installed
%   3) spm eeg initialized
%   4) mff files can be found by concatenating mffBasePath with test name
%       /depot/home/lbuser/data/eeg1028/mffs/lang2.mff
%   5) same as 4 with edf files & base path

%pipelineInputs = cellfun(@(t) createPipelineInputSub(t, mffBasePath, edfBasePath), tests, 'UniformOutput', false);

if nargin < 4, overrides = struct(); end;

if nargin < 3 || isempty(preProcessSteps)
    preProcessSteps = {'convert', 'dataPrep', 'montage', 'hpFilter', 'downsample', ...
        'lpFilter', 'epochs', 'average'}; 
end;

pipelineInput.test = test;

pipelineInput.preProcessSteps = preProcessSteps;

pipelineInput.mriPath = input.mriPath;

for i = 1:length(preProcessSteps)
    step = preProcessSteps{i};
    processFn = str2func(step);
    output = processFn(input);
    
    if isfield(pipelineInput, step)
        step = resolveFieldName(pipelineInput, step);
    end
    pipelineInput.(step) = output;
    
    output.file = dataFileSub(output.D, output.prefix);
    input = output;
end

datafileForModels = output.file;

pipelineInput.forwardModel = forwardModelSub(output.file, pipelineInput.mriPath);

pipelineInput.sourceInversion = sourceInversionSub(datafileForModels);

pipelineInput.inversionResults = inversionResultsSub(datafileForModels);

pipelineInput.ttestDataFile = datafileForModels;

pipelineInput = fillWithDefaults(overrides, pipelineInput);

end

function mffSettings = mffSettingsSub(mffPath)

    [mffEvents, Fs] = readMffEvents(mffPath);
    
    mffSettings.mffEvents = mffEvents';
    mffSettings.mffPath = mffPath;
    mffSettings.Fs = Fs;
end

function S = convert(input)
    S.dataset = input.file;
    S.D = S.dataset;
    
    mffSettings = mffSettingsSub(input.mffPath);
    S.mffSettings = mffSettings;

    S.events = prepEvents(S.mffSettings.mffPath);
    S.timewin = getEventsTimeWin(S.events);
    
    S.mode = 'continuous';
    S.checkboundary = 0;
    
    S.prefix = 'spmeeg_';
    
end

function S = dataPrep(input)
    S.D = input.file;
    S.prefix = 'DataPrep'; %different convention from SPM so known custom

    S.events = input.events;
    
end

function S = montage(input)
    S.D = input.file;
    
    S.montage = [cd filesep 'avref_vref.mat'];
    S.prefix = 'M';
    
end

function S = hpFilter(input)
    S.D = input.file;
    
    S.freq = .1;
    S.band = 'high';
    S.prefix = 'f';
end

function S = downsample(input)
    S.D = input.file;
    S.fsample_new = 200;
    S.prefix = 'd';
end

function S = lpFilter(input)
    S.D = input.file;
    
    S.freq = 30;
    S.band = 'low';
    S.prefix = 'f';
end

function S = epochs(input)
    S.D = input.file;
    
    S.prefix = 'e';
    
    S.timewin = [500 2500];
    
    trialdef = @(t, v) struct('eventtype',t,'conditionlabel',t,'eventvalue',v);
    
    dashedTrialdef = trialdef('dashed', 0);
    solidTrialdef = trialdef('solid', 1);
    
    S.trialdef(1) = dashedTrialdef;
    S.trialdef(2) = solidTrialdef;
    
end

function S = average(input)
    S.D = input.file;
    S.robust.bycondition = 1;
    S.robust.removebad = 0;
    S.prefix = 'm';
end

function batch = forwardModelSub(datafile, mriMesh)
    batch{1}.spm.meeg.source.headmodel.D = {datafile};
    batch{1}.spm.meeg.source.headmodel.val = 1;
    batch{1}.spm.meeg.source.headmodel.comment = '';
    batch{1}.spm.meeg.source.headmodel.meshing.meshes.mri = {mriMesh};
    batch{1}.spm.meeg.source.headmodel.meshing.meshres = 2;
    batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'nas';
    batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.select = 'nas';
    batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'lpa';
    batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.select = 'lpa';
    batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
    batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.select = 'rpa';
    batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
    batch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
end

function batch = sourceInversionSub(datafile)
    batch{1}.spm.meeg.source.invert.D = {datafile};
    batch{1}.spm.meeg.source.invert.val = 1;
    batch{1}.spm.meeg.source.invert.whatconditions.all = 1;
    batch{1}.spm.meeg.source.invert.isstandard.standard = 1;
    batch{1}.spm.meeg.source.invert.modality = {'EEG'};
end

function batch = inversionResultsSub(datafile)
    batch{1}.spm.meeg.source.results.D = {datafile};
    batch{1}.spm.meeg.source.results.val = 1;
    batch{1}.spm.meeg.source.results.woi = [160 1560];
    batch{1}.spm.meeg.source.results.foi = [0 0];
    batch{1}.spm.meeg.source.results.ctype = 'evoked';
    batch{1}.spm.meeg.source.results.space = 1;
    batch{1}.spm.meeg.source.results.format = 'image';
end

function D = dataFileSub(inputFile, prefix)
    D = prependToFilename(inputFile, prefix);
    [~, basename, ~] = fileparts(D);
    D = [basename '.mat'];
end
