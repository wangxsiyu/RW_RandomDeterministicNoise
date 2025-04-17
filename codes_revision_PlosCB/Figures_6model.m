%%
plt = W_plt('savedir', '../figures_revision', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true, 'extension',{'svg', 'jpg'});
%% load simulations
W.library_wang('Wang_EEHorizon');
game0 = readtable('../data/all/data_all.csv', 'Delimiter', ',');
idx = load('../data/all/idxsub_exclude');
tid = idx.idxsub(idx.id);
game0 = game0(vertcat(tid{:}),:);

opt_sub = {'subjectID', 'date', 'time'};
opt_preprocess = 'EEpreprocess_game_basic';
opt_game_sub = {'EEpreprocess_game_sub_repeatedgame'};
opt_analysis = {'EEanalysis_sub_basic'};
[sub, ~, idxsub] = W.analysis_pipeline(game0, opt_sub, opt_preprocess, opt_game_sub, opt_analysis, []);
gp = W.analysis_1group(sub, [], ...
            {{'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'},...
             {'p_inconsistent13'},{'p_inconsistent22'}});
%% single out simu
gamenow = game0;
for si = 1:length(idxsub)
    gamenow.choice_5(idxsub{si}) = simu.choice(si,1:simu.nTrial(si))' + 1;
end
[tsimu_sub] = W.analysis_pipeline(gamenow, opt_sub, opt_preprocess, ...
    opt_game_sub, opt_analysis, [], idxsub);
ttgp = W.analysis_1group(tsimu_sub, [], ...
    {{'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'},...
    {'p_inconsistent13'},{'p_inconsistent22'}});
sgp.modelA = W.analysis_1group(vertcat(ttgp, ttgp), false);
%%
global muteprint
muteprint = 1;
simugp = cell(10,6);
for repi = 1:10
    W.disp(repi,'');
    simu = load(fullfile('../bayesoutput_revision/simu6modelMAP/', sprintf('bayes_6model_simu_rep%d.mat', repi))).simu;
    for mi = 1:6
        gamenow = game0;
        for si = 1:length(idxsub)
            gamenow.choice_5(idxsub{si}) = simu{mi}.choice(si,1:simu{mi}.nTrial(si))' + 1;
        end
        %% reprocess 
        [tsimu_sub] = W.analysis_pipeline(gamenow, opt_sub, opt_preprocess, ...
            opt_game_sub, opt_analysis, [], idxsub);
        simugp{repi, mi} = W.analysis_1group(tsimu_sub, [], ...
            {{'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'},...
             {'p_inconsistent13'},{'p_inconsistent22'}});
    end
end
% W.save('./Temp/6model_simubeh.mat', 'simugp', simugp);
%%
sgp = struct;
for mi = 1:6
    sgp.(['model' char(64 + mi)]) = W.analysis_1group(vertcat(simugp{:,mi}),false);
    % sgp.(['model' char(64 + mi)]) = W.analysis_1group(vertcat(simugp{1,mi},simugp{1,mi}),false);
end
% W.save('./Temp/6model_simubeh.mat', 'simugp', simugp, 'simuavgp', sgp);
%%
% load('./Temp/6model_simubeh.mat');
% sgp = simuavgp;
%%
EEplot_2noise_modelcomparison(plt, gp, sgp);
%%
EEplot_2noise_modelcomparison1(plt, gp, sgp);
%% model-free analysis validation
W.unmuteprint()
plt.set_pltsetting('savesfx','validation');
plt.figure(1,2,'is_title',1);
leg = {'random noise only', 'simulated data (random noise only)', 'deterministic noise only'};
plt.setfig(1:2, 'ylim', {[0 0.45],[0 0.45]}, ...
    'ytick', 0:0.1:0.4, 'legend',{leg,leg});
plt = EEplot_2noise_pinconsistent(plt, sgp.modelE, '_byR', '_byR', 'GPav_');
%% non-hierarchical
repi = 1;
simu = load(fullfile('../bayesoutput_revision/simurepeat/', sprintf('simugame_%d.mat', repi))).simugame;
