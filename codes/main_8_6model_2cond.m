JAGS_setup_R1;
%% fit the 6 models
data = importdata('../data/all/bayesdata.mat');
for numi = 1:6
    W.print('model: %d', numi);
    data.modelname = sprintf('2noisemodel%s_2cond', char(numi + 'A' -1));
    wj.setup_data_dir(data, '../bayesoutput/6modelR1');
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['R1_fit_' char(numi + 'A' -1)]);
    wj.run;
end
%% simulate & fit with modelA (unused)
for repi = 1:10
    for numi = 2:6
        paramsub = load(fullfile('../bayesoutput/6modelR1', [HBItest 'HBI_R1_fit_' char(numi + 'A' -1) '_stat.mat'])).stats.mean;
        if ~isfield(paramsub, 'NoiseRan_sub')
            paramsub.NoiseRan_sub = zeros(size(paramsub.NoiseDet_sub));
        end
        if ~isfield(paramsub, 'NoiseDet_sub')
            paramsub.NoiseDet_sub = zeros(size(paramsub.NoiseRan_sub));
        end
        if ~exist(sprintf('../bayesoutput/6modelR1/R1_simugame_%s_%d.mat', char(numi + 'A' -1), repi), 'file')
            simugame = EEsimulate_bayes_2noise_2cond(data, paramsub.Infobonus_sub, ...
                paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
            W.save(sprintf('../bayesoutput/6modelR1/R1_simugame_%s_%d.mat', char(numi + 'A' -1), repi), ...
                'simugame', simugame);
        else
            simugame = W.load(sprintf('../bayesoutput/6modelR1/R1_simugame_%s_%d.mat', char(numi + 'A' -1), repi));
        end
        % fit
        simugame.modelname = '2noisemodelA_2cond';
        wj.setup_data_dir(simugame, '../bayesoutput/6modelR1');
        wjinfo = EEbayes_analysis(simugame, nchains);
        savename = sprintf('R1_fitA_simugame_%s_%d', char(numi + 'A' -1), repi);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, savename);
        wj.run;
    end
end
%% simulate - mean
for numi = 1:6
    paramsub = load(fullfile('../bayesoutput/6modelR1', [HBItest 'HBI_R1_fit_' char(numi + 'A' -1) '_stat.mat'])).stats.mean;
    for repi = 1:50
        savename = sprintf('../bayesoutput/6modelR1/R1_simugame_%s_%d.mat', char(numi + 'A' -1), repi);
        if ~exist(savename, 'file')
            if ~isfield(paramsub, 'NoiseRan_sub')
                paramsub.NoiseRan_sub = zeros(size(paramsub.NoiseDet_sub));
            end
            if ~isfield(paramsub, 'NoiseDet_sub')
                paramsub.NoiseDet_sub = zeros(size(paramsub.NoiseRan_sub));
            end
            simugame = EEsimulate_bayes_2noise_2cond(data, paramsub.Infobonus_sub, ...
                paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
            W.save(savename, ...
                'simugame', simugame);
        end
    end
    W.print('complete - simulate from mean')
end
%% simulate - MAP
for numi = 1:6
    paramsub = load(fullfile('../bayesoutput/6modelR1', [HBItest 'HBI_R1_fit_' char(numi + 'A' -1) '_samples.mat']));
    paramsub = getMAP(paramsub.samples);
    for repi = 1:50
        savename = sprintf('../bayesoutput/6modelR1/R1_MAP_simugame_%s_%d.mat', char(numi + 'A' -1), repi);
        if ~exist(savename, 'file')
            if ~isfield(paramsub, 'NoiseRan_sub')
                paramsub.NoiseRan_sub = zeros(size(paramsub.NoiseDet_sub));
            end
            if ~isfield(paramsub, 'NoiseDet_sub')
                paramsub.NoiseDet_sub = zeros(size(paramsub.NoiseRan_sub));
            end
            simugame = EEsimulate_bayes_2noise_2cond(data, paramsub.Infobonus_sub, ...
                paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
            W.save(savename, ...
                'simugame', simugame);
        end
    end
    W.print('complete - simulate from MAP');
end
%% simulate - DIST
for numi = 1:6
    paramsub = load(fullfile('../bayesoutput/6modelR1', [HBItest 'HBI_R1_fit_' char(numi + 'A' -1) '_samples.mat']));
    paramsub = paramsub.samples;
    for repi = 1:50
        savename = sprintf('../bayesoutput/6modelR1/R1_DIST_simugame_%s_%d.mat', char(numi + 'A' -1), repi);
        % if ~exist(savename, 'file')
            if ~isfield(paramsub, 'NoiseRan_sub')
                paramsub.NoiseRan_sub = zeros(size(paramsub.NoiseDet_sub));
            end
            if ~isfield(paramsub, 'NoiseDet_sub')
                paramsub.NoiseDet_sub = zeros(size(paramsub.NoiseRan_sub));
            end
            simugame = EEsimulate_bayes_2noise_2condDIST(data, paramsub.Infobonus_sub, ...
                paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
            W.save(savename, ...
                'simugame', simugame);
        % end
    end
    W.print('complete - simulate from DIST');
end
%% posterior checks - data
game0 = readtable('../data/all/data_all.csv', 'Delimiter', ',');
idx = load('../data/all/idxsub_exclude');
idxsub = idx.idxsub(idx.id);
tid = idx.idxsub(idx.id);
game0 = game0(vertcat(tid{:}),:);
idxsub = W.selectsubject(game0, {'date', 'time', 'subjectID'});
gp = getgpsimu(game0, idxsub);
%% loop over 3 ways 
sgp = cell(3,6);
sgp1 = cell(3,6);
names = {'','DIST_','MAP_'};
for wi = 1:3
    for mi = 1:6
        files = W.ls(sprintf('../bayesoutput/6modelR1/R1_%ssimugame_%s*', names{wi}, char(mi + 'A' -1)));
        simus = W.load(files);
        gps = W.cellfun(@(x)getgpsimu(game0, idxsub, x), simus);
        sgp{wi,mi} = vertcat(gps{:});
        sgp1{wi,mi} = W.analysis_1group(sgp{wi,mi},false);
    end
end
W.save('./Temp/6model_simudata_2cond', 'sgp', sgp, 'sgp1', sgp1)
%%
names = {'mean', 'dist', 'map'};
for wi = 1:3
    tgp = struct;
    for mi = 1:6
        tgp.(['model' char(64 + mi)]) = sgp1{wi, mi};
    end
    %%
    plt = W_plt('savedir', '../figures', 'savepfx', 'R1', 'isshow', true, ...
        'issave', true, 'extension',{'svg', 'jpg'});
    plt.set_pltsetting('savesfx', names{wi});
    EEplot_2noise_modelcomparison(plt, gp, tgp);
    %%
    EEplot_2noise_modelcomparison1(plt, gp, tgp);
end
%% calculate pval
ss = {};
for wi = 1:3
    summary = [];
    for mi = 1:6
        tsimu = sgp{wi, mi};
        summary(mi,:) = [mean(tsimu.GPpvalue_p_inconsistent13_vs_p_inconsistent13_randomtheory_byR < 0.05), ...
            mean(tsimu.GPpvalue_p_inconsistent22_vs_p_inconsistent22_randomtheory_byR < 0.05)];
    end
    ss{wi} = summary;
end
W.save('./Temp/summary_p_inconsistent22_vs_random', 'ss', ss);
%% 












% %% simulate MAP
% % st0 = W.load('..\bayesoutput_revision\R1_6model\HBI_R1_fit_A_stat.mat');
% % st0 = st0.stats.mean;
% % sp1 = W.load('..\bayesoutput_revision\R1_6model\HBI_R1_fit_A_samples.mat');
% % st1map = W.cellfun(@(x)getMAP(x), sp1, false);
% 
% sgp = cell(1,6);
% parfor mi = 1:6
% %     if mi == 1
% %         files = W.ls('../bayesoutput_revision/R1_simurepeat_2cond/R1_simugame*');
% %     else  
%     files = W.ls(sprintf('../bayesoutput_revision/R1_6model/R1_MAP_simugame_%s*', char(mi + 'A' -1)));
%     % end
%     simus = W.load(files);
%     gps = W.cellfun(@(x)getgpsimu(game0, idxsub, x), simus);
%     sgp{mi} = W.analysis_1group(vertcat(gps{:}),false);
% end
% %%
% gp3 = struct;
% for mi = 1:6
%     gp3.(['model' char(64 + mi)]) = sgp{mi};
% end
% plt = W_plt('savedir', '../figures_revision', 'savepfx', 'RDBayes_MAP', 'isshow', true, ...
%     'issave', true, 'extension',{'svg', 'jpg'});
% EEplot_2noise_modelcomparison(plt, gp, gp3);
% %%
% EEplot_2noise_modelcomparison1(plt, gp, gp3);
% 
% %% simulate distribution
% % st0 = W.load('..\bayesoutput_revision\R1_6model\HBI_R1_fit_A_stat.mat');
% % st0 = st0.stats.mean;
% % sp1 = W.load('..\bayesoutput_revision\R1_6model\HBI_R1_fit_A_samples.mat');
% % st1map = W.cellfun(@(x)getMAP(x), sp1, false);
% sgp = cell(1,6);
% parfor mi = 1:6
% %     if mi == 1
% %         files = W.ls('../bayesoutput_revision/R1_simurepeat_2cond/R1_simugame*');
% %     else  
%     files = W.ls(sprintf('../bayesoutput_revision/R1_6model/R1_DIST_simugame_%s*', char(mi + 'A' -1)));
%     % end
%     simus = W.load(files);
%     gps = W.cellfun(@(x)getgpsimu(game0, idxsub, x), simus);
%     sgp{mi} = W.analysis_1group(vertcat(gps{:}),false);
% end
% %%
% gp4 = struct;
% for mi = 1:6
%     gp4.(['model' char(64 + mi)]) = sgp{mi};
% end
% plt = W_plt('savedir', '../figures_revision', 'savepfx', 'RDBayes_DIST', 'isshow', true, ...
%     'issave', true, 'extension',{'svg', 'jpg'});
% EEplot_2noise_modelcomparison(plt, gp, gp4);
% %%
% EEplot_2noise_modelcomparison1(plt, gp, gp4);