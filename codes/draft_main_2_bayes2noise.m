
%% 6 model comparison (rest of the 5 models)
data = load(fullfile(fullfile('../data',ver), 'bayes_2noise.mat')).(['bayes_data']);
for mi = 2:6
    data.modelname = ['2noisemodel' char(64 + mi)];
    wj.setup_data_dir(data, outputdir);
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' char(64 + mi)]);
    wj.run;
end
%% simplistic case (only noise, no dR, dI, bias, choice = dQ)
% load fitted params
vv = '';
vv2 = '';
paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_' vv 'stat.mat'])).stats.mean;
[nh, nsub] = size(paramsub.NoiseDet_sub);
if ~isfield(paramsub, 'bias_sub')
    paramsub.bias_sub = zeros(nh, nsub);
end
% simulate behavior
data = load(fullfile(fullfile('../data',ver), ['bayes_2noise' vv2 '.mat'])).(['bayes_data' vv2]);
data.modelname = '2noiseONLY';
for numi = 1:1
    % zero det noise
    simugame = EEsimulate_bayes_ONLYnoise(data, paramsub.NoiseRan_sub', zeros(nsub, nh));
    % fit
    wj.setup_data_dir(simugame, outputdir);
    wjinfo = EEbayes_analysis(simugame, nchains, mdpath);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' vv 'ONLYNOISE_ranonly_' num2str(numi)]);
    wj.run;
    % zero ran noise
    simugame = EEsimulate_bayes_ONLYnoise(data, zeros(nsub, nh), paramsub.NoiseDet_sub');
    % fit
    wj.setup_data_dir(simugame, outputdir);
    wjinfo = EEbayes_analysis(simugame, nchains, mdpath);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' vv 'ONLYNOISE_detonly_' num2str(numi)]);
    wj.run;
end
%%
vvs = {'','paironly_'};
vv2s = {'','_paironly'};
for i = 1:1 % just the original
    %% parameter recovery
    vv = vvs{i}; vv2 = vv2s{i};
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
    for numi = 1:10
        % zero det noise
        simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
            paramsub.bias_sub', paramsub.NoiseRan_sub', zeros(nsub, nh));
        % fit
        wj.setup_data_dir(simugame, outputdir);
        wjinfo = EEbayes_analysis(simugame, nchains, mdpath);
        wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' vv 'simu_ranonly_' num2str(numi)]);
        wj.run;
        % zero ran noise
        simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
            paramsub.bias_sub', zeros(nsub, nh), paramsub.NoiseDet_sub');
        % fit
        wj.setup_data_dir(simugame, outputdir);
        wjinfo = EEbayes_analysis(simugame, nchains, mdpath);
        wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' vv 'simu_detonly_' num2str(numi)]);
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
%         wjinfo = EEbayes_analysis(simugame, nchains, mdpath);
%         wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' vv 'simu01_ranonly_' num2str(numi)]);
%         wj.run;
%         % zero ran noise
%         simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
%             paramsub.bias_sub', zeros(nsub, nh), ones(nsub, nh) * numi);
%         % fit
%         wj.setup_data_dir(simugame, outputdir);
%         wjinfo = EEbayes_analysis(simugame, nchains, mdpath);
%         wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' vv 'simu01_detonly_' num2str(numi)]);
%         wj.run;
%     end
end

%% simulate model recovery of simulaions of 6 behaviors
% get simu
for repi = 1:10
    data = load(fullfile('../data', ver, 'bayes_2noise.mat')).(['bayes_data']);
    name = {'','B_','C_','D_','E_','F_'};
    simu = {};
    tfile = fullfile('../data', ver, sprintf('bayes_6model_simu_rep%d.mat', repi));
    if ~exist(tfile)
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
        wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, [sprintf('DetRanNoise_fitmodel_rep%d_', repi) char(64 + mi)]);
        wj.run;
    end
end
