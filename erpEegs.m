function pipelineInputs = erpEegs(tests, mffBasePath)
%function pipelineInputs = erpEegs(tests, mffBasePath)
%for example:
%   tests = {'hand1', 'hand2', 'hand3', 'lang1', 'lang2'};
%   mffBasePath = '/depot/home/lbuser/data/eeg1028/mffs/';
%assumptions:
%   mff import installed, see help prepEvents
%   spm installed
%   mff files can be found by concatenating mffBasePath with test name
%       /depot/home/lbuser/data/eeg1028/mffs/lang2.mff

pipelineInputs = cellfun(@(t) createPipelineInput(t, mffBasePath), tests, 'UniformOutput', false);
pipelineInputs = [pipelineInputs{:}];

processInputsSub(pipelineInputs);

end

function processInputsSub(pipelineInputs)
    numInputs = length(pipelineInputs);
    
    for i = 1:numInputs
        input = pipelineInputs(i);
        test = input.test;
        mkdir([test '_sandbox']);
    end
end