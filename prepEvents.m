function events = prepEvents(mff)
%function events = prepEvents(mff)
%inputs
%   mff: string of file full path
%   or
%   struct with following fields
%       Fs (sampling frequency)
%       events (events from mff file)
%outputs
%   events: spm readable events struct array
%make sure mff import is installed
%   http://www.wbic.cam.ac.uk/Members/sc672/files/mffimport1-0.zip
%   addpath [path to mffimport/]
%   javaaddpath [path to mffimport/MFF-1.0.d0004.jar]

    if ischar(mff)
        [mffEvents, Fs] = readMffEvents(mff);
    else
        Fs = mff.Fs;
        mffEvents = mff.events;
    end
    
    validEvents = filterValidEvents(mffEvents);
    
    samples = [validEvents(:).sample]./Fs;
    
    numSamples = numel(samples);
    
    %allocate to improve performance
    events = repmat(struct('type', '', 'time', NaN), numSamples, 1);
    
    numEvents = 0;
    i = 1;
    while i < numSamples
        numEvents = numEvents + 1;
        events(numEvents).time = samples(i);
        if mod(i,2)
            events(numEvents).type = 'solid';
            i = i + 1;
        else
            events(numEvents).type = 'dashed';
            i = i + 3;
        end
    end
    
    events = events(1:numEvents);
    
end