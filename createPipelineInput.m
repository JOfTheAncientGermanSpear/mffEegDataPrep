function pipelineInput = createPipelineInput(test, mffBasePath, edfBasePath)
%function pipelineInput = createPipelineInput(test, mffBasePath, edfBasePath)

mffPath = [mffBasePath filesep test '.mff'];

[mffEvents, Fs] = readMffEvents(mffPath);
mff.events = mffEvents;
mff.Fs = Fs;

events = prepEvents(mff);

pipelineInput.mffEvents = mffEvents';
pipelineInput.events = events;
pipelineInput.test = test;
pipelineInput.mffPath = mffPath;

edfPath = [edfBasePath filesep test '.edf'];
pipelineInput.edfPath = edfPath;

end