function events = calcEvents(mffPath, timeOutputsPath, timeOffset)
%function calcEvents(mffPath, timeOutputsPath, timeOffset)

    if nargin < 3
        timeOffset = 0;
    end
    
    
    timeOutputs = load(timeOutputsPath);
    isAbstract = logical(timeOutputs(:, 3));
    starts = timeOutputs(:, 1);
    starts = starts - min(starts);
    starts = starts * 10^(-9);
    starts = starts + timeOffset;
    
    events = repmat(struct('type', '', 'time', NaN, 'label', ''), length(starts), 1);
    
    for i = 1:length(events)
        events(i).time = starts(i);
        label = 'concrete';
        value = 1;
        if isAbstract(i)
            label = 'abstract';
            value = 0;
        end
        events(i).label = label;
        events(i).type = label;
        events(i).value = value;
    end

    mffEvents = readMffEvents(mffPath);
    mffSettings = getMffSettings(mffPath);
    fs = mffSettings.Fs;

    compStrings = @(str, cells) cellfun(@(t)strcmp(t, str), cells);
    
    dins = compStrings('DIN1', {mffEvents(1:end).type});
    
    dinSamples = [mffEvents(dins).sample]/fs;
    
    mffSamples = [mffEvents(:).sample]/fs;
    
    concreteSamples = [events(~isAbstract).time];
    abstractSamples = [events(isAbstract).time];
    
    figure;
    
    hold on;
    scatter(mffSamples, ones(numel(mffSamples),1), 'gx');
    scatter(dinSamples, ones(numel(dinSamples),1), 'x');
    
    stem(concreteSamples, ones(numel(concreteSamples),1), 'b');
    stem(abstractSamples, ones(numel(abstractSamples),1), 'y');
    
    legend('MFF', 'MFF DIN', 'Concrete', 'Abstract');
    hold off;
    
    
end