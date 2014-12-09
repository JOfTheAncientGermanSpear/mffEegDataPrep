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
    
    
    if nargin < 2, stepIndices = [-inf inf]; end;
    if length(stepIndices) == 1, 
        stepIndices = [stepIndices, stepIndices];
    end
    withinRange = @(i) stepIndices(1) <= i && stepIndices(2) >= i;

    if withinRange(1), spm_eeg_convert(pipelineInput.convert); end;
    
    if withinRange(2), prepEegData(pipelineInput.dataPrep); end;

    if withinRange(3), spm_eeg_montage(pipelineInput.montage); end;
    
    if withinRange(4), spm_eeg_filter(pipelineInput.hpFilter); end;

    if withinRange(5), spm_eeg_downsample(pipelineInput.downsample); end;
        
    if withinRange(6), spm_eeg_filter(pipelineInput.lpFilter); end;
    
    if withinRange(7), spm_eeg_epochs(pipelineInput.epochs); end;
    
    if withinRange(8), spm_eeg_average(pipelineInput.average); end;
    
    if withinRange(9), spm_jobman('run', pipelineInput.forwardModel); end;
    
    if withinRange(10), spm_jobman('run', pipelineInput.sourceInversion); end;
    
    if withinRange(11), spm_jobman('run', pipelineInput.inversionResults); end;
    
    if withinRange(12), res = ttestData(pipelineInput.ttestDataFile); end;

    cd(callerDir);
end

function [callerDir, sandboxDir] = mkdirSub(pipelineInput)
    callerDir = cd;
    sandboxDir = [pipelineInput.test '_sandbox'];
    mkdir(sandboxDir);
end