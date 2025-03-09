addpath(genpath('../codes_support'))
JAGS_setup_revision;
%% main bayes
files = {'bayes_2noise_2cond_dIvar2.mat'};
suffix = {'v2', 'v3', 'v4'};
for fi = 1:3
    d = load(fullfile(fullfile('../data',ver), files{1})).(['bayes_data_2cond']);
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_2cond' suffix{fi}]);
    wj.run;
end
%% model no bias
% data = load(fullfile('../data', 'bayes_2noise.mat')).(['bayes_data']);
% data.modelname = ['2noisemodel_nobias'];
% wj.setup_data_dir(data, outputdir);
% wjinfo = EEbayes_analysis(data, nchains);
% wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_nobias']);
% wj.run;
% %% model paironly
% d = load(fullfile(fullfile('../data',ver), 'bayes_2noise_paironly.mat')).(['bayes_data_paironly']);
% d.modelname = ['2noisemodel'];
% wj.setup_data_dir(d, outputdir);
% wjinfo = EEbayes_analysis(d, nchains);
% wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_paironly']);
% wj.run;
% %% reduced model
% files = {'bayes_2noise_dRonly.mat', 'bayes_2noise_0model.mat', 'bayes_2noise_dIonly.mat'};
% suffix = {'_dRonly','_0model','_dIonly'};
% for fi = 1:1 % just the first one
%     d = load(fullfile(fullfile('../data',ver), files{fi})).(['bayes_data', suffix{fi}]);
%     wj.setup_data_dir(d, outputdir);
%     wjinfo = EEbayes_analysis(d, nchains);
%     wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise' suffix{fi}]);
%     wj.run;
% end
%% main bayes KF
JAGS_setup_revision;
nchains = 10; % How Many Chains?
nburnin = 10000; % How Many Burn-in Samples?
nsamples = 10000; % How Many Recorded Samples?
HBItest = '';
wj.setup_params(nchains, nburnin, nsamples);
files = {'bayes_2noise_2condKF.mat'};
suffix = {''};
for fi = 1:1
    d = load(fullfile(fullfile('../data',ver), files{fi})).(['bayes_data_2condKF', suffix{fi}]);
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_2condKF2' suffix{fi}]);
    wj.run;
end
%% plot posteriors

%% posterior checks
% get simu
data = load(fullfile('../data/all_revision/bayes_2noise_2cond_dIvar.mat')).(['bayes_data_2cond_dIvar']);
for repi = 1:50
    simu = {};
    name = {'A_','B_','C_','D_','E_','F_'};
    tfile = fullfile(W.mkdir('../bayesoutput_revision/dIvar'), sprintf('bayes_dIvar_simu_rep%d.mat', repi));
%     if ~exist(tfile, 'file')
        for mi = 1:6
            tparam = load(fullfile(outputdir, ['HBI_DetRanNoise_dI_2cond' name{mi} 'stat.mat'])).stats.mean;
            if ~isfield(tparam, 'NoiseRan_sub')
                tparam.NoiseRan_sub = zeros(size(tparam.NoiseDet_sub));
            end
            if ~isfield(tparam, 'NoiseDet_sub')
                tparam.NoiseDet_sub = zeros(size(tparam.NoiseRan_sub));
            end
            simu{mi} = EEsimulate_bayes_2noise_2conddIvar(data, tparam.Infobonus_sub, ...
                tparam.bias_sub, tparam.NoiseRan_sub, tparam.NoiseDet_sub);
%         end
        save(tfile,'simu');
    end
end





















% %% main bayes
% files = {'bayes_2noise_KF.mat'};
% suffix = {''};
% for fi = 1:1
%     d = load(fullfile(fullfile('../data',ver), files{fi})).(['bayes_data_KF', suffix{fi}]);
%     wj.setup_data_dir(d, outputdir);
%     wjinfo = EEbayes_analysis(d, nchains);
%     wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_KF' suffix{fi}]);
%     wj.run;
% 
%     d.modelname = '2noisemodel_2cond';
%     wj.setup_data_dir(d, outputdir);
%     wjinfo = EEbayes_analysis(d, nchains);
%     wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_2cond' suffix{fi}]);
%     wj.run;
% end