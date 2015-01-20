function res = runPipeline(config, stepIndices)
%function res = runPipeline(config, stepIndices)
%   config: 
%       see defaultConfig.m or skipConvertConfig.m
%   stepIndices: optional
%       steps to execute within, useful for quickly debugging
%       defaults to [-inf inf]
%       saved files from previous steps must be available
%   outputs:
%       res: ttest results and montaged data
    
    numPreProcessSteps = length(config.preProcessSteps);
    
    function invokeFn(index)
        step = config.preProcessSteps{index};
        input = config.(step);
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
    
    if withinRange(i + 1), spm_jobman('run', config.forwardModel); end;
    
    if withinRange(i + 2), spm_jobman('run', config.sourceInversion); end;
    
    if withinRange(i + 3), spm_jobman('run', config.inversionResults); end;
    
    if withinRange(i + 4), res = ttestData(config.ttestDataFile); end;
end

function [callerDir, sandboxDir] = mkdirSub(config)
    callerDir = cd;
    sandboxDir = [config.sandboxDir '_sandbox'];
    mkdir(sandboxDir);
end