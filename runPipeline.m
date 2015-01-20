function res = runPipeline(pipelineInput, stepIndices)
%function runPipeline(pipelineInput, stepIndices)
%   pipelineInput: 
%       see createPipelineInput
%   stepIndices: optional
%       steps to execute within, useful for quickly debugging
%       defaults to [-inf inf]
%       saved files from previous steps must be available
%   outputs:
%       res: ttest results and montaged data

    [callerDir, sandboxDir] = mkdirSub(pipelineInput);
    cd(sandboxDir);
    
    %so we can still call fxns
    addpath ..
    
    numPreProcessSteps = length(pipelineInput.preProcessSteps);
    
    function invokeFn(index)
        step = pipelineInput.preProcessSteps{index};
        input = pipelineInput.(step);
        if strcmpi(step, 'dataPrep')
            prepEegData(input);
        else
            if strcmpi(step, 'lpFilter') || strcmpi(step, 'hpFilter')
                step = 'filter';
            end
            fn = str2func(['spm_eeg_' step]);
            fn(input);
        end
    end
    
    if nargin < 2, stepIndices = [-inf inf]; end;
    if length(stepIndices) == 1, 
        stepIndices = [stepIndices, stepIndices];
    end
    
    withinRange = @(i) stepIndices(1) <= i && stepIndices(2) >= i;
    
    for i = 1:numPreProcessSteps
        if withinRange(i), invokeFn(i); end;
    end
    
    if withinRange(i + 1), spm_jobman('run', pipelineInput.forwardModel); end;
    
    if withinRange(i + 2), spm_jobman('run', pipelineInput.sourceInversion); end;
    
    if withinRange(i + 3), spm_jobman('run', pipelineInput.inversionResults); end;
    
    if withinRange(i + 4), res = ttestData(pipelineInput.ttestDataFile); end;

    cd(callerDir);
end

function [callerDir, sandboxDir] = mkdirSub(pipelineInput)
    callerDir = cd;
    sandboxDir = [pipelineInput.test '_sandbox'];
    mkdir(sandboxDir);
end