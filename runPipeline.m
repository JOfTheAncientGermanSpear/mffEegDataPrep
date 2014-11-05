function runPipeline(pipelineInput)
    [callerDir, sandboxDir] = mkdirSub(pipelineInput);
    cd(sandboxDir);
    
    spm_eeg_convert(convertParamsSub(pipelineInput));
    
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