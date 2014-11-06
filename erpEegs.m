function pipelineInputs = erpEegs(tests, mffBasePath, edfBasePath, skipConvert)
%function pipelineInputs = erpEegs(tests, mffBasePath, edfBasePath, skipConvert)
%   inputs:
%       skipConvert: if .mat & .dat files already created, speeds
%       processing
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


if nargin < 4, skipConvert = 0; end;

processInputsSub(pipelineInputs, skipConvert);

end

function processInputsSub(pipelineInputs, skipConvert)
    numInputs = length(pipelineInputs);
    
    montage = [cd filesep 'avref_vref.mat'];
    
    for i = 1:numInputs
        input = pipelineInputs(i);
        input.montage = montage;
        
        runPipeline(input, skipConvert);
    end
end