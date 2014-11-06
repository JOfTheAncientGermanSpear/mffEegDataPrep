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



pipelineInput.convert = convertParamsSub(test, edfBasePath, pipelineInput.events);

pipelineInput.montage = montageParamsSub(pipelineInput.convert);

pipelineInput.hpFilter = hpFilterParamsSub(pipelineInput.montage);

pipelineInput.lpFilter = lpFilterParamsSub(pipelineInput.hpFilter);

pipelineInput.downsample = downsampleParamsSub(pipelineInput.lpFilter);

pipelineInput.dashedEpochs = dashedEpochsParamsSub(pipelineInput.downsample);

pipelineInput.solidEpochs = solidEpochsParamsSub(pipelineInput.downsample);

pipelineInput.dashedAverage = averageParamsSub(pipelineInput.dashedEpochs);

pipelineInput.solidAverage = averageParamsSub(pipelineInput.solidEpochs);




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

function S = lpFilterParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.freq = 30;
    S.band = 'low';
    S.prefix = 'f';
end

function S = downsampleParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.fsample_new = 200;
    S.prefix = 'd';
end

function S = dashedEpochsParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    
    S.prefix = 'dashed_e';
    
    S.timewin = [500 5500];
    S.trialdef.eventtype = 'dashed';
    S.trialdef.eventvalue = 0;
    S.trialdef.conditionlabel = 'dashed';
end

function S = solidEpochsParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    
    S.prefix = 'solid_e';
    
    S.timewin = [500 2500];
    S.trialdef.eventtype = 'solid';
    S.trialdef.eventvalue = 1;
    S.trialdef.conditionlabel = 'solid';
end

function S = averageParamsSub(prevS)
    S.D = getOutputFromPrevS(prevS);
    S.robust.bycondition = 0;
    S.robust.removebad = 0;
    S.prefix = 'm';
end

function output = getOutputFromPrevS(prevS)
    [~, prevInputName, ~] = fileparts(prevS.D);
    output = [prevS.prefix prevInputName '.mat'];
end
