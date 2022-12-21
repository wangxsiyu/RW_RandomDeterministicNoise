%% get version
ver = 'all';
versave = 'all_50chains';
% ver = 'paironly';
%%
cd(W.funcout('fileparts', 1, matlab.desktop.editor.getActiveFilename));
outputdir = fullfile('../bayesoutput', versave);
outputdir = GetFullPath(outputdir);
wj = W_JAGS;
%% set up chains
nchains = 50; % How Many Chains?
nburnin = 2000; % How Many Burn-in Samples?
nsamples = 1000; % How Many Recorded Samples?
HBItest = '';
wj.setup_params(nchains, nburnin, nsamples);
wj.openpool;
%% test
% HBItest = 'test_';
% wj.setup_params;
%%
nchains = wj.bayes_params.nchains;
%% main bayes
files = {'bayes_2noise.mat', 'bayes_2noise_all.mat'};
suffix = {'','_all'};
for fi = 1:2
    d = load(fullfile(fullfile('../data',ver), files{fi})).(['bayes_data', suffix{fi}]);
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise' suffix{fi}]);
    wj.run;
end
%% 6 model comparison (rest of the 5 models)
data = load(fullfile(fullfile('../data',ver), 'bayes_2noise.mat')).(['bayes_data']);
for mi = 2:6
    data.modelname = ['2noisemodel' char(64 + mi)];
    wj.setup_data_dir(data, outputdir);
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' char(64 + mi)]);
    wj.run;
end
%% reduced model
files = {'bayes_2noise_dRonly.mat', 'bayes_2noise_0model.mat', 'bayes_2noise_dIonly.mat'};
suffix = {'_dRonly','_0model','_dIonly'};
for fi = 1:1 % just the first one
    d = load(fullfile(fullfile('../data',ver), files{fi})).(['bayes_data', suffix{fi}]);
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise' suffix{fi}]);
    wj.run;
end

%% model paironly
% data = load(fullfile('../data', 'bayes_2noise_paironly.mat')).(['bayes_data_paironly']);
% data.modelname = ['2noisemodel'];
% wj.setup_data_dir(data, outputdir);
% wjinfo = EEbayes_analysis(data, nchains);
% wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_paironly']);
% wj.run;
%%
vvs = {'','paironly_'};
vv2s = {'','_paironly'};
for i = 1:1 % just the original
    %% parameter recovery
    vv = vvs{i}; vv2 = vv2s{i};
    % load fitted params
    paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_' vv 'stat.mat'])).stats.mean;
    % simulate behavior
    data = load(fullfile(fullfile('../data',ver), ['bayes_2noise' vv2 '.mat'])).(['bayes_data' vv2]);
    data.modelname = ['2noisemodel'];
    for numi = 1:1
        simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
            paramsub.bias_sub', paramsub.NoiseRan_sub', paramsub.NoiseDet_sub');
        % fit
        wj.setup_data_dir(simugame, outputdir);
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' vv 'simu' num2str(numi)]);
        wj.run;
    end
    %% parameter recovery (with only random noise and only deterministic noise)
    % load fitted params
    paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_' vv 'stat.mat'])).stats.mean;
    [nh, nsub] = size(paramsub.NoiseDet_sub);
    if ~isfield(paramsub, 'bias_sub')
        paramsub.bias_sub = zeros(nh, nsub);
    end
    % simulate behavior
    data = load(fullfile(fullfile('../data',ver), ['bayes_2noise' vv2 '.mat'])).(['bayes_data' vv2]);
    data.modelname = '2noisemodel';
    for numi = 1:1
        % zero det noise
        simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
            paramsub.bias_sub', paramsub.NoiseRan_sub', zeros(nsub, nh));
        % fit
        wj.setup_data_dir(simugame, outputdir);
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' vv 'simu_ranonly_' num2str(numi)]);
        wj.run;
        % zero ran noise
        simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
            paramsub.bias_sub', zeros(nsub, nh), paramsub.NoiseDet_sub');
        % fit
        wj.setup_data_dir(simugame, outputdir);
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' vv 'simu_detonly_' num2str(numi)]);
        wj.run;
    end
%     %% parameter recovery (with only random noise and only deterministic noise)
%     % load fitted params
%     paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_' vv 'stat.mat'])).stats.mean;
%     [nh, nsub] = size(paramsub.NoiseDet_sub);
%     if ~isfield(paramsub, 'bias_sub')
%         paramsub.bias_sub = zeros(nh, nsub);
%     end
%     % simulate behavior
%     data = load(fullfile('../data', ['bayes_2noise' vv2 '.mat'])).(['bayes_data' vv2]);
%     data.modelname = '2noisemodel';
%     for numi = 1:10
%         % zero det noise
%         simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
%             paramsub.bias_sub', ones(nsub, nh) * numi, zeros(nsub, nh));
%         % fit
%         wj.setup_data_dir(simugame, outputdir);
%         wjinfo = EEbayes_analysis(simugame, nchains);
%         wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' vv 'simu01_ranonly_' num2str(numi)]);
%         wj.run;
%         % zero ran noise
%         simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
%             paramsub.bias_sub', zeros(nsub, nh), ones(nsub, nh) * numi);
%         % fit
%         wj.setup_data_dir(simugame, outputdir);
%         wjinfo = EEbayes_analysis(simugame, nchains);
%         wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' vv 'simu01_detonly_' num2str(numi)]);
%         wj.run;
%     end
end
% %% full-grid parameter recovery (with only random noise and only deterministic noise)
% vv = '';
% vv2 = '';
% % load fitted params
% paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_' vv 'stat.mat'])).stats.mean;
% [nh, nsub] = size(paramsub.NoiseDet_sub);
% if ~isfield(paramsub, 'bias_sub')
%     paramsub.bias_sub = zeros(nh, nsub);
% end
% % simulate behavior
% data = load(fullfile(fullfile('../data',ver), ['bayes_2noise' vv2 '.mat'])).(['bayes_data' vv2]);
% data.modelname = '2noisemodel';
% for numi = 0:10
%     for numj = 0:10
%         disp(sprintf('%d,%d', numi, numj));
%         % zero det noise
%         simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
%             paramsub.bias_sub', ones(nsub, nh) * numi, ones(nsub, nh) * numj);
%         % fit
%         wj.setup_data_dir(simugame, fullfile(outputdir, 'simugrid'));
%         wjinfo = EEbayes_analysis(simugame, nchains);
%         wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' vv sprintf('simugrid_ran%ddet%d',numi,numj)]);
%         wj.run;
%     end
% end
%% simulate model recovery of simulaions of 6 behaviors
% get simu
isoverwrite = true;
for repi = 1:1
    data = load(fullfile('../data', ver, 'bayes_2noise.mat')).(['bayes_data']);
    name = {'','B_','C_','D_','E_','F_'};
    simu = {};
    tfile = fullfile('../data', ver, sprintf('bayes_6model_simu_rep%d.mat', repi));
    if ~exist(tfile) || isoverwrite
        for mi = 1:6
            tparam = load(fullfile(outputdir, ['HBI_DetRanNoise_' name{mi} 'stat.mat'])).stats.mean;
            if ~isfield(tparam, 'NoiseRan_sub')
                tparam.NoiseRan_sub = zeros(size(tparam.NoiseDet_sub));
            end
            if ~isfield(tparam, 'NoiseDet_sub')
                tparam.NoiseDet_sub = zeros(size(tparam.NoiseRan_sub));
            end
            simu{mi} = EEsimulate_bayes_2noise(data, tparam.Infobonus_sub', ...
                tparam.bias_sub', tparam.NoiseRan_sub', tparam.NoiseDet_sub');
        end
        save(tfile,'simu');
    end
    %%
    data = importdata(fullfile('../data',ver,sprintf('bayes_6model_simu_rep%d.mat', repi)));
    for mi = 1:6
        wj.setup_data_dir(data{mi}, outputdir);
        wjinfo = EEbayes_analysis(data{mi}, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, [sprintf('DetRanNoise_fitmodel_rep%d_', repi) char(64 + mi)]);
        wj.run;
    end
end
%% model no bias
data = load(fullfile('../data', 'bayes_2noise.mat')).(['bayes_data']);
data.modelname = ['2noisemodel_nobias'];
wj.setup_data_dir(data, outputdir);
wjinfo = EEbayes_analysis(data, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_nobias']);
wj.run;