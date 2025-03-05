JAGS_setup_revision;
%% simulate model recovery of simulaions of 6 behaviors
% get simu
data = load(fullfile('../data/all_revision/bayes_2noise_2cond.mat')).(['bayes_data_2cond']);
for repi = 1:50
    name = {'_','B_','C_','D_','E_','F_'};
    simu = {};
    tfile = fullfile(W.mkdir('../bayesoutput_revision/simu6model'), sprintf('bayes_6model_simu_rep%d.mat', repi));
    if ~exist(tfile, 'file')
        for mi = 1:6
            tparam = load(fullfile(outputdir, ['HBI_DetRanNoise_2cond' name{mi} 'stat.mat'])).stats.mean;
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
    %%
%     data1 = importdata(tfile);
%     for mi = 1:6
%         wj.setup_data_dir(data1{mi}, '../bayesoutput/simu6model');
%         wjinfo = EEbayes_analysis(data1{mi}, nchains);
%         wj.setup(wjinfo.modelfile, wjinfo.params, struct, [sprintf('DetRanNoise_fitmodel_rep%d_', repi) char(64 + mi)]);
%         wj.run;
%     end
end
%%
data = load(fullfile('../data/all_revision/bayes_2noise_2cond.mat')).(['bayes_data_2cond']);
for repi = 1:50
    name = {'_','B_','C_','D_','E_','F_'};
    simu = {};
    tfile = fullfile(W.mkdir('../bayesoutput_revision/simu6model'), sprintf('bayes_6model_simu_rep%d.mat', repi));
    if ~exist(tfile, 'file')
        for mi = 1:6
            tparam = load(fullfile(outputdir, ['HBI_DetRanNoise_2cond' name{mi} 'stat.mat'])).stats.mean;
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
    %%
%     data1 = importdata(tfile);
%     for mi = 1:6
%         wj.setup_data_dir(data1{mi}, '../bayesoutput/simu6model');
%         wjinfo = EEbayes_analysis(data1{mi}, nchains);
%         wj.setup(wjinfo.modelfile, wjinfo.params, struct, [sprintf('DetRanNoise_fitmodel_rep%d_', repi) char(64 + mi)]);
%         wj.run;
%     end
end
%%%



%%
files = W.dir('Y:\RW_RandomDeterministicNoise\bayesoutput\simu6model\*stat.mat');
files.model = W.strs_selectbetween2patterns(files.filename, '_', '_', -2, -1);
files.data = W.strs_selectbetween2patterns(files.filename, 'fitmodel', '_rep', 1, 1);
files.data(files.data == "") = "A_";
files.data = W.strs_selectbetween2patterns(files.data, [], '_');
files.rep = W.strs_selectbetween2patterns(files.filename, 'rep', '_', 1, -2);
files.rep = str2double(files.rep);
%%
dd = W.load(files.fullpath);
dic = W.cellfun(@(x)x.stats.dic, dd);
files.dic = dic';
%%
ff = files(files.rep  <= 4, 4:end);
dics = repmat({NaN(6, 6)}, 1, 4);
for i = 1:4
    for j = 1:6
        tf = ff(ff.rep == i & ff.model == char(64+j),:);
        dics{i}(j,:) = sortrows(tf, 'data').dic;
    end
end

av = W.cell_avse(dics);