%% prepare data
load('../data/all/idxsub_exclude.mat');
game = readtable('../data/all/data_all.csv', 'Delimiter', ',');
addpath('../codes/')
bayes_data_2cond = EEbayes_reformat(game, idxsub(id), '2noisemodel_2cond');
save('../data/all_revision/bayes_2noise_2cond.mat', 'bayes_data_2cond');


bayes_data_2condKF = EEbayes_reformat(game, idxsub(id), '2noisemodel_2condKF');
save('../data/all_revision/bayes_2noise_2condKF.mat', 'bayes_data_2condKF');
