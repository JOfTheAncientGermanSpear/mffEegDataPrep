function plotMffAndEvents(mffEvents, events)
%function plotMffAndEvents(mffEvents, events)

    compStrings = @(str, cells) cellfun(@(t)strcmp(t, str), cells);
    
    dins = compStrings('DIN1', {mffEvents(1:end).type});
    
    dinSamples = [mffEvents(dins).sample]/1000;
    
    mffSamples = [mffEvents(:).sample]/1000;
    
    eventSamples = [events(:).time];
    
    solidEvents = compStrings('solid', {events(:).type});
    dashedEvents = compStrings('dashed', {events(:).type});
    
    solidSamples = eventSamples(solidEvents);
    dashedSamples = eventSamples(dashedEvents);
    
    figure;
    
    hold on;
    scatter(mffSamples, ones(numel(mffSamples),1), 'gx');
    scatter(dinSamples, ones(numel(dinSamples),1), 'x');
    
    stem(solidSamples, ones(numel(solidSamples),1), 'b');
    stem(dashedSamples, ones(numel(dashedSamples),1), 'y');
    hold off;
    
    
end