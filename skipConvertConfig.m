function config = skipConvertConfig(preppedDataPath, mriPath)
%function config = skipConvertConfig(preppedDataPath, mriPath)
    config.preProcessSteps = {'spm_eeg_montage', {'spm_eeg_filter', 'hpFilter'}, 'spm_eeg_downsample', ...
        {'spm_eeg_filter', 'lpFilter'}, 'spm_eeg_epochs', 'spm_eeg_average'};
    
    config.spm_eeg_montage.D = preppedDataPath;
    config.spm_eeg_montage.montage = [cd filesep 'avref_vref.mat'];
    config.spm_eeg_montage.prefix = 'M';
    
    config.hpFilter.D = prependToFilename(config.spm_eeg_montage.D, config.spm_eeg_montage.prefix);
    config.hpFilter.freq = .1;
    config.hpFilter.band = 'high';
    config.hpFilter.prefix = 'f';
    
    config.spm_eeg_downsample.D = prependToFilename(config.hpFilter.D, config.hpFilter.prefix);
    config.spm_eeg_downsample.fsample_new = 200;
    config.spm_eeg_downsample.prefix = 'd';
    
    config.lpFilter.D = prependToFilename(config.spm_eeg_downsample.D, config.spm_eeg_downsample.prefix);
    config.lpFilter.freq = 30;
    config.lpFilter.band = 'low';
    config.lpFilter.prefix = 'f';
    
    config.spm_eeg_epochs.D = prependToFilename(config.lpFilter.D, config.lpFilter.prefix);
    config.spm_eeg_epochs.prefix = 'e';
    config.spm_eeg_epochs.timewin = [500 2500];
    trialdef = @(t, v) struct('eventtype',t,'conditionlabel',t,'eventvalue',v);
    config.spm_eeg_epochs.trialdef(1) = trialdef('dashed', 0);
    config.spm_eeg_epochs.trialdef(2) = trialdef('solid', 1);
    
    config.spm_eeg_average.D = prependToFilename(config.spm_eeg_epochs.D, config.spm_eeg_epochs.prefix);
    config.spm_eeg_average.robust.bycondition = 1;
    config.spm_eeg_average.robust.removebad = 0;
    config.spm_eeg_average.prefix = 'm';
    
    
    datafile = prependToFilename(config.spm_eeg_average.D, config.spm_eeg_average.prefix);
    
end
