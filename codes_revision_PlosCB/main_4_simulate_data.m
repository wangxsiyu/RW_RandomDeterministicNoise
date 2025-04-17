JAGS_setup
%% 6 model comparison
data = load(fullfile('../data/all_revision/bayesdata.mat')).(['bayesdata']);
name = {'_','B_','C_','D_','E_','F_'};
for repi = 1:10
    simu = {};
    tfile = fullfile(W.mkdir('../bayesoutput_revision/simu6model'), sprintf('bayes_6model_simu_rep%d.mat', repi));
    if ~exist(tfile, 'file')
        for mi = 1:6
            tparam = load(fullfile(outputdir, ['HBI_DetRanNoiseR1' name{mi} '2cond_stat.mat'])).stats.mean;
            if ~isfield(tparam, 'NoiseRan_sub')
                tparam.NoiseRan_sub = zeros(size(tparam.NoiseDet_sub));
            end
            if ~isfield(tparam, 'NoiseDet_sub')
                tparam.NoiseDet_sub = zeros(size(tparam.NoiseRan_sub));
            end
            simu{mi} = EEsimulate_bayes_2noise_2cond(data, tparam.Infobonus_sub, ...
                tparam.bias_sub, tparam.NoiseRan_sub, tparam.NoiseDet_sub);
        end
        save(tfile,'simu');
    end
end

%% 6 model comparison DIST
data = load(fullfile('../data/all_revision/bayesdata.mat')).(['bayesdata']);
name = {'_','B_','C_','D_','E_','F_'};
td = {};
for mi = 1:6
    td{mi} = load(fullfile(outputdir, ['HBI_DetRanNoiseR1' name{mi} '2cond_samples.mat'])).samples;
end
%%
for repi = 1:10
    simu = {};
    tfile = fullfile(W.mkdir('../bayesoutput_revision/simu6modelMAP'), sprintf('bayes_6model_simu_rep%d.mat', repi));
    if ~exist(tfile, 'file')
        for mi = 1:6
            sp = td{mi};
            if ~isfield(sp, 'NoiseRan_sub')
                sp.NoiseRan_sub = sp.NoiseDet_sub * 0;
            end
            if ~isfield(sp, 'NoiseDet_sub')
                sp.NoiseDet_sub = sp.NoiseRan_sub * 0;
            end
            simu{mi} = EEsimulate_bayes_2noise_2condDIST(data, sp.Infobonus_sub, ...
                sp.bias_sub, sp.NoiseRan_sub, sp.NoiseDet_sub);
        end
        save(tfile,'simu');
    end
end