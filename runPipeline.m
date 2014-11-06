function resultFiles = runPipeline(pipelineInputs)
%function resultFiles = runPipeline(pipelineInputs)
    
    resultFiles = arrayfun(@(i) singleRunSub(i), pipelineInputs, 'UniformOutput', 0);
end

function resultFile = singleRunSub(pipelineInput)
    [callerDir, sandboxDir] = mkdirSub(pipelineInput);
    cd(sandboxDir);

    if ~pipelineInput.skipConvert
        spm_eeg_convert(convertParamsSub(pipelineInput));
    end

    D = spm_eeg_montage(montageParamsSub(pipelineInput));

    D = spm_eeg_filter(hpFilterParamsSub(D));

    D = spm_eeg_filter(lpFilterParamsSub(D));

    D = spm_eeg_downsample(downsampleParamsSub(D));
    
    D=D.events(1, pipelineInput.events);
    
    resultFile = D.fullfile;

    cd(callerDir);
end

function [callerDir, sandboxDir] = mkdirSub(pipelineInput)
    callerDir = cd;
    sandboxDir = [pipelineInput.test '_sandbox'];
    mkdir(sandboxDir);
end

function S = convertParamsSub(pipelineInput)
    S.dataset = pipelineInput.edfPath;
    S.mode = 'continuous';
    S.checkboundary = 0;
    
    startTime = pipelineInput.events(1).time - .1;
    stopTime = pipelineInput.events(end).time + .1;
    if startTime < 0, startTime = 0; end;
    
    S.timewin = [startTime stopTime];
end


function S = montageParamsSub(pipelineInput)
    S.montage = pipelineInput.montage;
    S.D = ['spmeeg_' pipelineInput.test '.mat'];
end

function S = hpFilterParamsSub(D)
    S.D = D;
    S.freq = .1;
    S.band = 'high';
end

function S = lpFilterParamsSub(D)
    S.D = D;
    S.freq = 30;
    S.band = 'low';
end

function S = downsampleParamsSub(D)
    S.D = D;
    S.fsample_new = 200;
end