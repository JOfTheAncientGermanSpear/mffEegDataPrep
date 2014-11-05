function runPipeline(pipelineInput)
    [callerDir, sandboxDir] = mkdirSub(pipelineInput);
    cd(sandboxDir);
    
    D = spm_eeg_convert(convertParamsSub(pipelineInput));
    
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
end