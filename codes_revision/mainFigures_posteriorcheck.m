%%
addpath(genpath('../codes_support/'));

plt = W_plt('savedir', '../figures_revision', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true, 'extension',{'svg', 'jpg'});

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
%%
global muteprint
muteprint = 1;
simugp = cell(50,6);
for repi = 1:50
    W.disp(repi,'');
    simu = load(fullfile('../bayesoutput_revision/dIvar/', sprintf('bayes_dIvar_simu_rep%d.mat', repi))).simu;
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
end
W.save('./Temp/6model_simubeh_av.mat', 'simuavgp', sgp);
%%
load('./Temp/6model_simubeh_av.mat');
sgp = simuavgp;
%%
addpath('../codes/')
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

%%
tfile = fullfile(W.mkdir('../bayesoutput_revision/dIvar'), sprintf('bayes_dIvar_simu_rep%d.mat', repi));

%% ratio plot (h = 6/h = 1, for ran and det, A and b)
sp = paramsub{1};
%%
plt.figure(4,2,'istitle',0,'rect',[0 0 0.5 0.9],...
    'margin',[0.1 0.11 0.02 0.02]);
stepsize = 0.04;
xbins = [-30:stepsize:30];
fns = {'NoiseRan', 'NoiseDet','InfoBonus_mu_n','bias_mu_n'};
tt = [];
cols = {'AZred', 'AZblue','AZcactus','AZsand'};
plt.setfig([1 3 5 7],'legend', {'Random noise', 'Deterministic noise','Information bonus','spatial bias'}, ...
    'xlabel', {'','','','ratio of increase (H = 6/H = 1)'}, 'ylabel', {'\sigma_{Ran}','\sigma_{Det}','A','b'},'title','','ytick', '', ...
    'xlim', [-10,10]);
plt.setfig([1 3 5 7]+1,'legend', {'Random noise', 'Deterministic noise','Information bonus','spatial bias'}, ...
    'xlabel', {'','','','ratio of increase (H = 6/H = 1)'}, 'ylabel', {'\sigma_{Ran}','\sigma_{Det}','A','b'},'title','','ytick', '', ...
    'xlim', [-10,10]);
for j = 1:2
    for mi = 1:4
        plt.ax(mi,j);
        fn = fns{mi};
        td = sp.(fn);
        [tl, tm] = W.JAGS_density((td(:,:,2,j)./td(:,:,1,j)), xbins);
        plt.plot(tm, tl, [], 'line', 'color', cols{mi});

    end
end
plt.update;
