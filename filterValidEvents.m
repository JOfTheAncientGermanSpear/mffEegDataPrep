function validEvents = filterValidEvents(mffEvents)
%function validEvents = filterValidEvents(mffEvents)
% retains only din events that follow pattern of 1 time space 1 1 1 time
% interval
%inputs:
%   mffEvents struct array of events from mff
%outputs:
%   validEvents


numMffEvents = length(mffEvents);


dinIndices = zeros(1, numMffEvents);
dinCount = 0;
for i = 1:numMffEvents
    if strcmp(mffEvents(i).type, 'DIN1')
        dinCount = dinCount + 1;
        dinIndices(dinCount) = i;
    end
end

dinIndices = dinIndices(1:dinCount);

validEvents = mffEvents(dinIndices);

mffSamples = [validEvents.sample];

numSamples = numel(mffSamples);

valids = zeros(1, numSamples);

i = 0;
while i < numSamples
    i = i + 1;
    
    sample = mffSamples(i);
    if i > 1 && i + 2 <= numSamples
        has1ToTheLeft = mffSamples(i - 1) + 3500 > sample;
        isGroupOf3 = mffSamples(i + 2) - 2500 < sample;
        
        if isGroupOf3 && has1ToTheLeft
            valids(i-1:i+2) = ones(1,4);
            i = i + 3;
        end
    end
end

validEvents = validEvents(logical(valids));