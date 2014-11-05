function pipelineInputs = erpEegs(tests, mffBasePath, edfBasePath)
%function pipelineInputs = erpEegs(tests, mffBasePath)
%for example:
%   tests = {'hand1', 'hand2', 'hand3', 'lang1', 'lang2'};
%   mffBasePath = '/depot/home/lbuser/data/eeg1028/mffs/';
%   eegBasePath = '/depot/home/lbuser/data/eeg1028/edfs/'
%assumptions:
%   1) mff import installed, see help prepEvents
%   2) spm installed
%   3) spm initialized for eeg
%   4) mff files can be found by concatenating mffBasePath with test name
%       /depot/home/lbuser/data/eeg1028/mffs/lang2.mff
%   5) same as 4 with edf files & base path

pipelineInputs = cellfun(@(t) createPipelineInput(t, mffBasePath, edfBasePath), tests, 'UniformOutput', false);
pipelineInputs = [pipelineInputs{:}];

processInputsSub(pipelineInputs);

end

function processInputsSub(pipelineInputs)
    numInputs = length(pipelineInputs);
    
    montageData = load('avref_vref.mat');
    montage = montageData.montage;
    
    for i = 1:numInputs
        input = pipelineInputs(i);
        input.montage = montage;
        
        runPipeline(input);
    end
end