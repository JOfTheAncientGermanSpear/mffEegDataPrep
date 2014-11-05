function pipelineInput = createPipelineInput(test, mffPathBase)
%function pipelineInput = createPipelineInput(test, mffPathBase)

mffPath = [mffPathBase test '.mff'];

[mffEvents, Fs] = readMffEvents(mffPath);
mff.events = mffEvents;
mff.Fs = Fs;

events = prepEvents(mff);

pipelineInput.mffEvents = mffEvents';
pipelineInput.events = events;
pipelineInput.test = test;
pipelineInput.mffPath = mffPath;

end