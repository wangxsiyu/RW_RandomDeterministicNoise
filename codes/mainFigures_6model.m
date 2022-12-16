%%
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
%% load simulations
game0 = readtable('../data/all/data_all.csv', 'Delimiter', ',');
idx = load('../data/all/idxsub_exclude');
tid = idx.idxsub(idx.id);
game0 = game0(vertcat(tid{:}),:);

opt_sub = {'subjectID', 'date', 'time'};
opt_preprocess = 'EEpreprocess_game_basic';
opt_game_sub = {'EEpreprocess_game_sub_repeatedgame'};
opt_analysis = {'EEanalysis_sub_basic'};
[sub, ~, idxsub] = W.analysis_pipeline(game0, opt_sub, opt_preprocess, opt_game_sub, opt_analysis, []);
gp = W.analysis_1group(sub);
%%
global muteprint
muteprint = 1;
simugp = cell(50,6);
for repi = 1:50
    W.disp(repi,'');
    simu = load(fullfile('../bayesoutput/simu6model/', sprintf('bayes_6model_simu_rep%d.mat', repi))).simu;
    for mi = 1:6
        gamenow = game0;
        for si = 1:length(idxsub)
            gamenow.choice_5(idxsub{si}) = simu{mi}.choice(si,1:simu{mi}.nTrial(si))' + 1;
        end
        %% reprocess 
        [tsimu_sub] = W.analysis_pipeline(gamenow, opt_sub, opt_preprocess, ...
            opt_game_sub, opt_analysis, [], idxsub);
        simugp{repi, mi} = W.analysis_1group(tsimu_sub);
    end
end
%%
sgp = struct;
for mi = 1:6
    sgp.(['model' char(64 + mi)]) = W.analysis_1group(vertcat(simugp{:,mi}));
end
%%
EEplot_2noise_modelcomparison(plt, gp, sgp);
%%
EEplot_2noise_modelcomparison1(plt, gp, sgp);
