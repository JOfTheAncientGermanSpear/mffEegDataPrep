function config = skipConvertConfig(preppedDataPath, mriPath)
%function config = skipConvertConfig(preppedDataPath, mriPath)
    config.preProcessSteps = {'montage', 'hpFilter', 'downsample', ...
        'lpFilter', 'epochs', 'average'};
    
    config.montage.D = preppedDataPath;
    config.montage.montage = [cd filesep 'avref_vref.mat'];
    config.montage.prefix = 'M';
    
    config.hpFilter.D = prependToFilename(config.montage.D, config.montage.prefix);
    config.hpFilter.freq = .1;
    config.hpFilter.band = 'high';
    config.hpFilter.prefix = 'f';
    
    config.downsample.D = prependToFilename(config.hpFilter.D, config.hpFilter.prefix);
    config.downsample.fsample_new = 200;
    config.downsample.prefix = 'd';
    
    config.lpFilter.D = prependToFilename(config.downsample.D, config.downsample.prefix);
    config.lpFilter.freq = 30;
    config.lpFilter.band = 'low';
    config.lpFilter.prefix = 'f';
    
    config.epochs.D = prependToFilename(config.lpFilter.D, config.lpFilter.prefix);
    config.epochs.prefix = 'e';
    config.epochs.timewin = [500 2500];
    trialdef = @(t, v) struct('eventtype',t,'conditionlabel',t,'eventvalue',v);
    config.epochs.trialdef(1) = trialdef('dashed', 0);
    config.epochs.trialdef(2) = trialdef('solid', 1);
    
    config.average.D = prependToFilename(config.epochs.D, config.epochs.prefix);
    config.average.robust.bycondition = 1;
    config.average.robust.removebad = 0;
    config.average.prefix = 'm';
    
    
    datafile = prependToFilename(config.average.D, config.average.prefix);
    
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.D = {datafile};
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.val = 1;
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.comment = '';
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.meshing.meshes.mri = {mriPath};
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.meshing.meshres = 2;
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'nas';
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.select = 'nas';
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'lpa';
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.select = 'lpa';
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.select = 'rpa';
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
    config.forwardModel.batch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
    
    config.sourceInversion.batch{1}.spm.meeg.source.invert.D = {datafile};
    config.sourceInversion.batch{1}.spm.meeg.source.invert.val = 1;
    config.sourceInversion.batch{1}.spm.meeg.source.invert.whatconditions.all = 1;
    config.sourceInversion.batch{1}.spm.meeg.source.invert.isstandard.standard = 1;
    config.sourceInversion.batch{1}.spm.meeg.source.invert.modality = {'EEG'};
    
    config.inversionResults.batch{1}.spm.meeg.source.results.D = {datafile};
    config.inversionResults.batch{1}.spm.meeg.source.results.val = 1;
    config.inversionResults.batch{1}.spm.meeg.source.results.woi = [160 1560];
    config.inversionResults.batch{1}.spm.meeg.source.results.foi = [0 0];
    config.inversionResults.batch{1}.spm.meeg.source.results.ctype = 'evoked';
    config.inversionResults.batch{1}.spm.meeg.source.results.space = 1;
    config.inversionResults.batch{1}.spm.meeg.source.results.format = 'image';
end
