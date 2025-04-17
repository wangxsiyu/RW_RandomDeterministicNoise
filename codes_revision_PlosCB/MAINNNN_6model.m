JAGS_setup;
%%
data = importdata('../data/all_revision/bayesdata.mat');
for numi = 1:6
    W.print('model: %d', numi);
    data.modelname = sprintf('2noisemodel%s_2cond', char(numi + 'A' -1));
    wj.setup_data_dir(data, '../bayesoutput_revision/R1_6model');
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['R1_fit_' char(numi + 'A' -1)]);
    wj.run;
end
%% simulate 
for repi = 1:10
    for numi = 2:6
        paramsub = load(fullfile('../bayesoutput_revision/R1_6model', [HBItest 'HBI_R1_fit_' char(numi + 'A' -1) '_stat.mat'])).stats.mean;
        if ~isfield(paramsub, 'NoiseRan_sub')
            paramsub.NoiseRan_sub = zeros(size(paramsub.NoiseDet_sub));
        end
        if ~isfield(paramsub, 'NoiseDet_sub')
            paramsub.NoiseDet_sub = zeros(size(paramsub.NoiseRan_sub));
        end
        simugame = EEsimulate_bayes_2noise_2cond(data, paramsub.Infobonus_sub, ...
            paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
        W.save(sprintf('../bayesoutput_revision/R1_6model/R1_simugame_%s_%d.mat', char(numi + 'A' -1), repi), ...
            'simugame', simugame);
        % fit
        simugame.modelname = '2noisemodelA_2cond';
        wj.setup_data_dir(simugame, '../bayesoutput_revision/R1_6model');
        wjinfo = EEbayes_analysis(simugame, nchains);
        savename = sprintf('R1_fitA_simugame_%s_%d', char(numi + 'A' -1), repi);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, savename);
        wj.run;
    end
end
%% posterior checks
game0 = readtable('../data/all/data_all.csv', 'Delimiter', ',');
idx = load('../data/all/idxsub_exclude');
idxsub = idx.idxsub(idx.id);
tid = idx.idxsub(idx.id);
game0 = game0(vertcat(tid{:}),:);
idxsub = W.selectsubject(game0, {'date', 'time', 'subjectID'});
gp = getgpsimu(game0, idxsub);
%% 
sgp = struct;
for mi = 1:6
    if mi == 1
        files = W.ls('../bayesoutput_revision/R1_simurepeat_2cond/R1_simugame*');
    else
        files = W.ls(sprintf('../bayesoutput_revision/R1_6model/R1_simugame_%s*', char(mi + 'A' -1)));
    end
    simus = W.load(files);
    gps = W.cellfun(@(x)getgpsimu(game0, idxsub, x), simus);
    sgp.(['model' char(64 + mi)]) = W.analysis_1group(vertcat(gps{:}),false);
end
%%
EEplot_2noise_modelcomparison(plt, gp, sgp);
%%
EEplot_2noise_modelcomparison1(plt, gp, sgp);