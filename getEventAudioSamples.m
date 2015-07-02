function [samples, times] = getEventAudioSamples(events, Fs)
%function [samples, times] = getEventAudioSamples(events, Fs)
%returns the samples & times in the audio data that the events occured

if nargin < 2
    Fs = 8000;
end

if isempty(events)
    samples = [];
    times = [];
    return
end

startTime = events(1).time;

times = arrayfun(@(e) e.time - startTime, events);

samples = round(times.*Fs) + 1;