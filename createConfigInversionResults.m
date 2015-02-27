function inversionResults = createConfigInversionResults(inversionInterval, timeWindow, template)
    maxTime = timeWindow(2);
    minTime = timeWindow(1);
    inversionCount = ceil( (maxTime - minTime)/inversionInterval);
    
    for i = 1:inversionCount
        start = (i - 1) * inversionInterval + 1 + minTime;
        stop = start + inversionInterval - 1;
        
        if start > maxTime
            break;
        end
        if stop > maxTime
            stop = maxTime;
        end
        
        template.woi = [start stop];
        inversionResults(i).batch{1}.spm.meeg.source.results = template;
    end
    
end