JAGS_setup_revision;
%% simulate model recovery of simulaions of 6 behaviors
% get simu
data = load(fullfile('../data/all_revision/bayes_2noise_2cond.mat')).(['bayes_data_2cond']);
for repi = 1:50
    name = {'_'};
    scalefactors = [1/4 1/2 1 2 4];
    tfile = fullfile(W.mkdir('../bayesoutput_revision/scalemodel'), sprintf('bayes_scalemodel_simu_rep%d.mat', repi));
    if ~exist(tfile, 'file')
        simu = {};
        for si = 1:length(scalefactors)
            mi = 1;
            tparam = load(fullfile(outputdir, ['HBI_DetRanNoise_2cond' name{mi} 'stat.mat'])).stats.mean;
            if ~isfield(tparam, 'NoiseRan_sub')
                tparam.NoiseRan_sub = zeros(size(tparam.NoiseDet_sub));
            end
            if ~isfield(tparam, 'NoiseDet_sub')
                tparam.NoiseDet_sub = zeros(size(tparam.NoiseRan_sub));
            end
            simu{si, 1} = EEsimulate_bayes_2noise_2cond(data, tparam.Infobonus_sub, ...
                tparam.bias_sub, tparam.NoiseRan_sub * scalefactors(si), tparam.NoiseDet_sub);
            simu{si, 2} = EEsimulate_bayes_2noise_2cond(data, tparam.Infobonus_sub, ...
                tparam.bias_sub, tparam.NoiseRan_sub, tparam.NoiseDet_sub * scalefactors(si));
        end
        save(tfile,'simu');
    end
end
%%
global muteprint
muteprint = 1;
simugp = cell(50,6);
for repi = 1:50
    W.disp(repi,'');
    simu = load(fullfile('../bayesoutput/simu6model/', sprintf('bayes_6model_simu_rep%d.mat', repi))).simu;
    for mi = 1:6
        gamenow = game0;
        for si = 1:length(idxsub)
            gamenow.choice_5(idxsub{si}) = simu{mi}.choice(si,1:simu{mi}.nTrial(si))' + 1;
        end
        %% reprocess 
        [tsimu_sub] = W.analysis_pipeline(gamenow, opt_sub, opt_preprocess, ...
            opt_game_sub, opt_analysis, [], idxsub);
        simugp{repi, mi} = W.analysis_1group(tsimu_sub, [], ...
            {{'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'},...
             {'p_inconsistent13'},{'p_inconsistent22'}});
    end
end
W.save('./Temp/6model_simubeh.mat', 'simugp', simugp);