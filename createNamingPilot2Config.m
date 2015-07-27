function config = createNamingPilot2Config(edfPath, sensorCoordinatesPath, events)
%function config = createNamingPilot2Config(edfPath, sensorCoordinatesPath, events)
    config.preProcessSteps = {'spm_eeg_convert', 'prepEegData', ...
        {@prepChannels, 'badChannels'}, 'spm_eeg_epochs', 'spm_eeg_average'};
    
    config.spm_eeg_convert.dataset = edfPath;
    config.spm_eeg_convert.D = edfPath;
    config.spm_eeg_convert.events = events;
    config.spm_eeg_convert.timewin = getEventsTimeWin(config.spm_eeg_convert.events);
    config.spm_eeg_convert.headerformat = 'EEG';
    config.spm_eeg_convert.mode = 'continuous';
    config.spm_eeg_convert.checkboundary = 0;
    config.spm_eeg_convert.prefix = 'spmeeg_';

    function fname = sameDirPrepend(fname, prefix)
        fname = prependToFilename(fname, prefix);
        fname = fname(2:end);
    end
        
    sameDirChangeMat = sameDirFnGen(@changeToMat);
    
    config.prepEegData.D = sameDirPrepend(sameDirChangeMat(config.spm_eeg_convert.D), config.spm_eeg_convert.prefix);
    config.prepEegData.prefix = 'DataPrep';
    config.prepEegData.events = config.spm_eeg_convert.events;
    config.prepEegData.sensorCoordinatesPath = sensorCoordinatesPath;
    
    
    preppedFileName = sameDirPrepend(config.prepEegData.D, config.prepEegData.prefix);
    
    function prepChannels(badChannels)
        D = spm_eeg_load(preppedFileName);
        D = badchannels(D, badChannels, 1);
        newChanLabels = cellfun(@(c) ['EEG ' c], D.chanlabels(), 'UniformOutput', 0);
        D = D.chanlabels(:, newChanLabels);
        D = D.chantype(:, 'EEG');
        D.save();
    end
    
    config.badChannels = [202 203];

    
    config.spm_eeg_epochs.D = preppedFileName;
    config.spm_eeg_epochs.prefix = 'e';
    config.spm_eeg_epochs.timewin = [-500 2500];
    trialdef = @(t, v) struct('eventtype',t,'conditionlabel',t,'eventvalue',v);
    config.spm_eeg_epochs.trialdef(1) = trialdef('abstract', 0);
    config.spm_eeg_epochs.trialdef(2) = trialdef('concrete', 1);
    
    config.spm_eeg_average.D = sameDirPrepend(config.spm_eeg_epochs.D, config.spm_eeg_epochs.prefix);
    config.spm_eeg_average.robust.bycondition = 1;
    config.spm_eeg_average.robust.removebad = 0;
    config.spm_eeg_average.prefix = 'm';

end

function fn = sameDirFnGen(fileNameFn)
    function fname = fnTmp(fname)
        fname = fileNameFn(fname);
        fname = fname(2:end);
    end
    fn = @fnTmp;
end
