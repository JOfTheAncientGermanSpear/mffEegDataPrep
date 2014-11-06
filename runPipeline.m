function runPipeline(pipelineInput, skipConvert)
    [callerDir, sandboxDir] = mkdirSub(pipelineInput);
    cd(sandboxDir);
    
    if ~skipConvert
        spm_eeg_convert(convertParamsSub(pipelineInput));
    end
    
    spm_eeg_montage(montageParamsSub(pipelineInput));
    
    %D = spm_eeg_filter(hpFilterParamsSub(pipelineInput));
    
    %D = spm_eeg_filter(lpFilterParamsSub(pipeLineInput), D);
    
    %D = spm_eeg_downsample(downsampleParamsSub(pipelineInput), D);
    
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