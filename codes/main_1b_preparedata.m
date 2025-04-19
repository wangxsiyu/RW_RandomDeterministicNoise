addpath(genpath('../codes_support/'))
%% prepare data
load('../data/all/idxsub_exclude.mat');
game = readtable('../data/all/data_all.csv', 'Delimiter', ',');
g = W.tab_autofieldcombine(game);
dI = arrayfun(@(x)getdI_onegame(g.choice(x,:), g.reward(x,:)), 1:size(g,1));
game.dIvar = dI';

bayesdata = EEbayes_reformat(game, idxsub(id), 'EE2noise');
save('../data/all/bayesdata.mat', 'bayesdata');


% bayes_data_2condKF = EEbayes_reformat(game, idxsub(id), '2noisemodel_2condKF');
% save('../data/all_revision/bayes_2noise_2condKF.mat', 'bayes_data_2condKF');
% %%

% p_mu_obs = generate_likelihood();
% g = W.tab_autofieldcombine(game);
% dI = arrayfun(@(x)getdI_onegame(g.choice(x,:), g.reward(x,:), p_mu_obs), 1:size(g,1));
% game.dIvar = dI';
% bayes_data_2cond_dIvar = EEbayes_reformat(game, idxsub(id), '2noisemodel_2cond_dIvar');
% save('../data/all_revision/bayes_2noise_2cond_dIvar.mat', 'bayes_data_2cond_dIvar');
%%
% 
% bayes_data_2cond_dIvar2 = EEbayes_reformat(game, idxsub(id), '2noisemodel_2cond_dIvar');
% save('../data/all_revision/bayes_2noise_2cond_dIvar2.mat', 'bayes_data_2cond_dIvar2');
