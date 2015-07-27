function runPipeline(config, stepIndices)
%function runPipeline(config, stepIndices)
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
        fnInfo = config.preProcessSteps{index};
        
        if iscell(fnInfo)
            fn = fnInfo{1};
            inputKey = fnInfo{2};
        else
            fn = fnInfo;
            inputKey = fnInfo;
        end
        
        input = config.(inputKey);
        
        if ischar(fn)
            fn = str2func(fn);
        end
        
        fn(input);
        %if strcmpi(fn, 'dataPrep')
        %    prepEegData(input);
        %else
        %    if strcmpi(fn, 'lpFilter') || strcmpi(fn, 'hpFilter')
        %        fn = 'filter';
        %    end
        %    fn = str2func(['spm_eeg_' fn]);
        %    fn(input);
        %end
    end
    
    if nargin < 2, stepIndices = [-inf inf]; end;
    if length(stepIndices) == 1, 
        stepIndices = [stepIndices, stepIndices];
    end
    
    withinRange = @(i) stepIndices(1) <= i && stepIndices(2) >= i;
    
    for i = 1:numPreProcessSteps
        if withinRange(i), invokeFn(i); end;
    end
    
end

function [callerDir, sandboxDir] = mkdirSub(config)
    callerDir = cd;
    sandboxDir = [config.sandboxDir '_sandbox'];
    mkdir(sandboxDir);
end
