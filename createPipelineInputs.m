function pipelineInputs = createPipelineInputs(tests, mffBasePath, edfBasePath)
%function pipelineInputs = createPipelineInputs(tests, mffBasePath, edfBasePath)
%for example:
%   tests = {'hand1', 'hand2', 'hand3', 'lang1', 'lang2'};
%   mffBasePath = '/depot/home/lbuser/data/eeg1028/mffs/';
%   eegBasePath = '/depot/home/lbuser/data/eeg1028/edfs/'
%assumptions:
%   1) mff import installed, see help prepEvents
%   2) spm installed
%   3) spm eeg initialized
%   4) mff files can be found by concatenating mffBasePath with test name
%       /depot/home/lbuser/data/eeg1028/mffs/lang2.mff
%   5) same as 4 with edf files & base path

pipelineInputs = cellfun(@(t) createPipelineInputSub(t, mffBasePath, edfBasePath), tests, 'UniformOutput', false);
pipelineInputs = [pipelineInputs{:}];

end

function pipelineInput = createPipelineInputSub(test, mffBasePath, edfBasePath)

pipelineInput.test = test;

mffPath = [mffBasePath filesep test '.mff'];

[mffEvents, Fs] = readMffEvents(mffPath);
mff.events = mffEvents;
mff.Fs = Fs;

events = prepEvents(mff);

pipelineInput.mffEvents = mffEvents';
pipelineInput.events = events;

pipelineInput.mffPath = mffPath;

edfPath = [edfBasePath filesep test '.edf'];
pipelineInput.edfPath = edfPath;

montage = [cd filesep 'avref_vref.mat'];
pipelineInput.montage = montage;


pipelineInput.skipConvert = 0;

end