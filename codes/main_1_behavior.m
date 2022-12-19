%% main analysis 2016
rawdatadir = '../data';
savedir = '../data/all';
files = dir(fullfile(rawdatadir,'Imported_EE_blinkCuriosity_2016S.csv'));
filename = fullfile(files.folder, files.name);
%% basic analysis
W.library_wang('Wang_EEHorizon')
opt_sub = {'subjectID', 'date', 'time'};
opt_preprocess = 'EEpreprocess_game_basic';
opt_game_sub = {'EEpreprocess_game_sub_repeatedgame'};
opt_analysis = {'EEanalysis_sub_basic'};
[sub0, game, idxsub] = W.analysis_pipeline(filename, opt_sub, opt_preprocess, opt_game_sub, opt_analysis, savedir);
W.writetable(game, fullfile(savedir,'data_all.csv'));
%% exclude participants
sub0 = readtable('../data/all/SUB_EE_blinkCuriosity_2016S.csv', 'Delimiter', ',');
load('../data/all/idxsub_EE_blinkCuriosity_2016S.mat');
[suball, idall] = W.excludesubject(sub0, 'age', [18 NaN]);
[sub, id] = W.excludesubject(sub0, 'age', [18 NaN], 'pvalue_ac', [NaN 0.05]);
save(fullfile(savedir, 'idxsub_exclude.mat'), 'id', 'idall','idxsub');
%% analyze group
clear gp;
additionalcompare = {{'p_inconsistent13'},{'p_inconsistent22'},...
    {'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'}};
gp{1} = W.analysis_1group(sub, true, additionalcompare);
gp{2} = W.analysis_1group(suball, true, additionalcompare);
suffix = {'','_all'};
%% behavioral plots
plt = W_plt('savedir', '../figures', 'savepfx', 'RanDetNoise', 'isshow', true, ...
    'issave', true);
%%
for gi = 1:2
    plt.set_pltsetting('savesfx', suffix{gi});
    %% model-free plots
    plt.figure(1,2,'is_title',1);
    plt.setfig(1:2, 'ylim', {[0, 0.3] + gi*0.05,[0.35 0.65]}, ...
        'ytick', {0.1:.1:0.4, 0.4:.1:0.6}, ...
        'legend', {{'[2 2]','[1 3]'},{'[1 3]'}}, 'legloc',{'SE','SE'});
    plt = EEplot_modelfree(plt, gp{gi},1,1);
    %% 2 noise figure
    plt.figure(1,2,'is_title',1);
    plt.setfig(1:2, 'ylim', {[0 0.45],[0 0.45]}, ...
        'ytick', 0:0.1:0.4);
    plt = EEplot_2noise_pinconsistent(plt, gp{gi}, '_byR', '_byR');
end
%% save bayes data
load('../data/all/idxsub_exclude.mat');
game = readtable('../data/all/data_all.csv', 'Delimiter', ',');
bayes_data = EEbayes_reformat(game, idxsub(id), '2noisemodel');
bayes_data_all = EEbayes_reformat(game, idxsub(idall), '2noisemodel');
bayes_data_paironly = EEbayes_reformat(game, idxsub(id), '2noisemodel_paironly');
bayes_data_dRonly = EEbayes_reformat(game, idxsub(id), '2noisemodel_dRonly');
bayes_data_dIonly = EEbayes_reformat(game, idxsub(id), '2noisemodel_dIonly');
bayes_data_0model = EEbayes_reformat(game, idxsub(id), '2noisemodel_0model');
save('../data/all/bayes_2noise.mat', 'bayes_data');
save('../data/all/bayes_2noise_all.mat', 'bayes_data_all');
save('../data/all/bayes_2noise_paironly.mat', 'bayes_data_paironly');
save('../data/all/bayes_2noise_dRonly.mat', 'bayes_data_dRonly');
save('../data/all/bayes_2noise_dIonly.mat', 'bayes_data_dIonly');
save('../data/all/bayes_2noise_0model.mat', 'bayes_data_0model');
%%
% subject level parameter,
% det/ran noise at the subject level