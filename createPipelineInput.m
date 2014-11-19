function pipelineInput = createPipelineInput(test, mffBasePath, edfBasePath, params)
%function pipelineInput = createPipelineInput(test, mffBasePath, edfBasePath, params)
%for example:
%   test = 'hand1';
%   mffBasePath = '/depot/home/lbuser/data/eeg1028/mffs/';
%   edfBasePath = '/depot/home/lbuser/data/eeg1028/edfs/';
%   inputs:
%       params (optional):
%       struct with overrides for any of the following fields
%           covert
%               see spm_eeg_convert
%           montage
%               see spm_eeg_montage
%           hpFilter
%               see spm_eeg_filter
%           lpFilter
%               see spm_eeg_filter
%           downsample
%               see spm_eeg_downsample
%           dashedEpochs
%               see spm_eeg_epochs
%           solidEpochs
%               see spm_eeg_epochs
%           dashedAverage
%               see spm_eeg_average
%           solidAverage
%               see spm_eeg_average
%assumptions:
%   1) mff import installed, see help prepEvents
%   2) spm installed
%   3) spm eeg initialized
%   4) mff files can be found by concatenating mffBasePath with test name
%       /depot/home/lbuser/data/eeg1028/mffs/lang2.mff
%   5) same as 4 with edf files & base path

%pipelineInputs = cellfun(@(t) createPipelineInputSub(t, mffBasePath, edfBasePath), tests, 'UniformOutput', false);

if nargin < 4, params = struct(); end;

pipelineInput.test = test;

pipelineInput.mffSettings = mffSettingsSub(test, mffBasePath);

pipelineInput.events = prepEvents(pipelineInput.mffSettings.mffPath);

pipelineInput.sensorCoordinates = getSensorCoordinates(pipelineInput.mffSettings.mffPath);

[pipelineInput.fiducials, pipelineInput.eegSensors] = sensorCoordsToSpm(pipelineInput.sensorCoordinates);



pipelineInput.convert = convertParamsSub(test, edfBasePath, pipelineInput.events);

pipelineInput.montage = montageParamsSub(pipelineInput.convert);

pipelineInput.hpFilter = hpFilterParamsSub(pipelineInput.montage);

pipelineInput.downsample = downsampleParamsSub(pipelineInput.hpFilter);

pipelineInput.lpFilter = lpFilterParamsSub(pipelineInput.downsample);

pipelineInput.epochs = epochsParamsSub(pipelineInput.lpFilter);

pipelineInput.average = averageParamsSub(pipelineInput.epochs);

pipelineInput.convert2Images = convert2ImagesParamsSub(pipelineInput.average);


pipelineInput = fillWithDefaults(params, pipelineInput);

end

function mffSettings = mffSettingsSub(test, mffBasePath)
    mffPath = [mffBasePath filesep test '.mff'];

    [mffEvents, Fs] = readMffEvents(mffPath);
    
    mffSettings.mffEvents = mffEvents';
    mffSettings.mffPath = mffPath;
    mffSettings.Fs = Fs;
end

function S = convertParamsSub(test, edfBasepath, events)
    S.dataset = [edfBasepath filesep test '.edf'];
    S.D = S.dataset;
    
    S.mode = 'continuous';
    S.checkboundary = 0;
    
    startTime = events(1).time - .1;
    stopTime = events(end).time + 6;
    if startTime < 0, startTime = 0; end;
    
    S.timewin = [startTime stopTime];
    
    S.prefix = 'spmeeg_';
    
end

function S = montageParamsSub(prevS)
    S.montage = [cd filesep 'avref_vref.mat'];
    S.D = getOutputFromPrevS(prevS);
    S.prefix = 'M';
end

function S = hpFilterParamsSub(prevS)
    S.freq = .1;
    S.band = 'high';
    S.D = getOutputFromPrevS(prevS);
    S.prefix = 'f';
end

function S = downsampleParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.fsample_new = 200;
    S.prefix = 'd';
end

function S = lpFilterParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.freq = 30;
    S.band = 'low';
    S.prefix = 'f';
end

function S = epochsParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.prefix = 'e';
    
    S.timewin = [500 2500];
    
    trialdef = @(t, v) struct('eventtype',t,'conditionlabel',t,'eventvalue',v);
    
    dashedTrialdef = trialdef('dashed', 0);
    solidTrialdef = trialdef('solid', 1);
    
    S.trialdef(1) = dashedTrialdef;
    S.trialdef(2) = solidTrialdef;
    
end

function S = averageParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.robust.bycondition = 1;
    S.robust.removebad = 0;
    S.prefix = 'm';
end

function S = convert2ImagesParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.mode = 'scalp x time';
    S.channels = 'EEG';
end

function output = getOutputFromPrevS(prevS)
    [~, prevInputName, ~] = fileparts(prevS.D);
    output = [prevS.prefix prevInputName '.mat'];
end
