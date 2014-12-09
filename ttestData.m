function res = ttestData(dataFile)
%function ttestData(dataFile)
%inputs:
%   dataFile: montaged data of 2 trials
%outputs:
%   res: t_tests and data from montage file

data = spm_eeg_load(dataFile);

res.trial1 = data(1:256,:,1);
res.trial2 = data(1:256,:,2);

    function str = wrapTtestInStruct(t1, t2)
        [str.H, ...
        str.P, ...
        str.CI,...
        str.stats] = ttest2(t1, t2);
    end


res.t_scores_per_sample = wrapTtestInStruct(res.trial1, res.trial2);

res.t_scores_per_channel = wrapTtestInStruct(res.trial1', res.trial2');

end