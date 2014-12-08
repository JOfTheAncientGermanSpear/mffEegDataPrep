function pipelineInput = createPipelineInput(test, mffBasePath, edfBasePath, mriPath, params)
%function pipelineInput = createPipelineInput(test, mffBasePath, edfBasePath, mriPath, params)
%for example:
%   test = 'hand1';
%   mffBasePath = '/depot/home/lbuser/data/eeg1028/mffs/sub_1/';
%   edfBasePath = '/depot/home/lbuser/data/eeg1028/edfs/sub_1/';
%   mriPath = '/depot/home/lbuser/data/MRI/t1.nii';
%   S.prepEegData.sensorCoordinatesPath =
%   '/depot/home/lbuser/data/eeg1028/mffs/sub_1/coordinates.xml';
%   pipelineInput = createPipelineInput(test, mffBasePath, edfBasePath, mriPath, S);
%   inputs:
%       params (optional):
%       struct with overrides for any of the following fields
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

if nargin < 5, params = struct(); end;

pipelineInput.test = test;

pipelineInput.mffSettings = mffSettingsSub(test, mffBasePath);

events = prepEvents(pipelineInput.mffSettings.mffPath);

pipelineInput.convert = convertParamsSub(test, edfBasePath, getEventsTimeWin(events));

pipelineInput.dataPrep = dataPrepSub(pipelineInput.convert, events);

pipelineInput.montage = montageParamsSub(pipelineInput.dataPrep);

pipelineInput.hpFilter = hpFilterParamsSub(pipelineInput.montage);

pipelineInput.downsample = downsampleParamsSub(pipelineInput.hpFilter);

pipelineInput.lpFilter = lpFilterParamsSub(pipelineInput.downsample);

pipelineInput.epochs = epochsParamsSub(pipelineInput.lpFilter);

pipelineInput.average = averageParamsSub(pipelineInput.epochs);


datafileForModels = getPreviousOutputSub(pipelineInput.average);

pipelineInput.forwardModel = forwardModelSub(datafileForModels, mriPath);

pipelineInput.sourceInversion = sourceInversionSub(datafileForModels);

pipelineInput.inversionResults = inversionResultsSub(datafileForModels);

pipelineInput = fillWithDefaults(params, pipelineInput);

end

function mffSettings = mffSettingsSub(test, mffBasePath)
    mffPath = [mffBasePath filesep test '.mff'];

    [mffEvents, Fs] = readMffEvents(mffPath);
    
    mffSettings.mffEvents = mffEvents';
    mffSettings.mffPath = mffPath;
    mffSettings.Fs = Fs;
end

function S = convertParamsSub(test, edfBasepath, timewin)
    S.dataset = [edfBasepath filesep test '.edf'];
    S.D = S.dataset;
    
    S.mode = 'continuous';
    S.checkboundary = 0;
    
    S.timewin = timewin;
    
    S.prefix = 'spmeeg_';
    
end

function S = dataPrepSub(prevS, events)
    S.D = getPreviousOutputSub(prevS);
    S.prefix = 'DataPrep'; %different convention from SPM so known custom

    S.events = events;
end

function S = montageParamsSub(prevS)
    S.D = getPreviousOutputSub(prevS);
    
    S.montage = [cd filesep 'avref_vref.mat'];
    S.prefix = 'M';
end

function S = hpFilterParamsSub(prevS)
    S.D = getPreviousOutputSub(prevS);
    
    S.freq = .1;
    S.band = 'high';
    S.prefix = 'f';
end

function S = downsampleParamsSub(prevS)
    S.D = getPreviousOutputSub(prevS);
    S.fsample_new = 200;
    S.prefix = 'd';
end

function S = lpFilterParamsSub(prevS)
    S.D = getPreviousOutputSub(prevS);
    
    S.freq = 30;
    S.band = 'low';
    S.prefix = 'f';
end

function S = epochsParamsSub(prevS)
    S.D = getPreviousOutputSub(prevS);
    
    S.prefix = 'e';
    
    S.timewin = [500 2500];
    
    trialdef = @(t, v) struct('eventtype',t,'conditionlabel',t,'eventvalue',v);
    
    dashedTrialdef = trialdef('dashed', 0);
    solidTrialdef = trialdef('solid', 1);
    
    S.trialdef(1) = dashedTrialdef;
    S.trialdef(2) = solidTrialdef;
    
end

function S = averageParamsSub(prevS)
    S.D = getPreviousOutputSub(prevS);
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

function D = getPreviousOutputSub(prevS)
    D = prependToFilename(prevS.D, prevS.prefix);
    [~, basename, ~] = fileparts(D);
    D = [basename '.mat'];
end
