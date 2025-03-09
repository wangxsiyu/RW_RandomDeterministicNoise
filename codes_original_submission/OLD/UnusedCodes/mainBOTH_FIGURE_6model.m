%% setup
ver = 'all';
verout = 'all_50chains';
% ver = 'paironly';
% verout = ver;
outputdir = fullfile('../bayesoutput/', verout);
figdir = '../figures';
plt = W_plt;
plt.setup_W_plt('fig_dir', fullfile(figdir,verout), 'fig_suffix', '','fig_projectname', 'RanDetNoise');
%% 6-model comparison (simulation)
% data = load(fullfile('../data', ver, 'bayes_2noise.mat')).(['bayes_data']);
% name = {'','B_','C_','D_','E_','F_'};
% simu = {};
% isoverwrite = true;
% for repi = 1:50
%     disp(repi);
%     tfile = fullfile('../data', verout, sprintf('bayes_6model_simu_rep%d.mat', repi));
%     if ~exist(tfile) || isoverwrite
%         for mi = 1:6
%             tparam = load(fullfile(outputdir, ['HBI_DetRanNoise_' name{mi} 'stat.mat'])).stats.mean;
%             if ~isfield(tparam, 'NoiseRan_sub')
%                 tparam.NoiseRan_sub = zeros(size(tparam.NoiseDet_sub));
%             end
%             if ~isfield(tparam, 'NoiseDet_sub')
%                 tparam.NoiseDet_sub = zeros(size(tparam.NoiseRan_sub));
%             end
%             simu{mi} = EEsimulate_bayes_2noise(data, tparam.Infobonus_sub', ...
%                 tparam.bias_sub', tparam.NoiseRan_sub', tparam.NoiseDet_sub');
%         end
%         save(tfile,'simu');
%     end
% end
%%
% basic analysis of simulated behavior
% files = dir(fullfile('../data', ver, sprintf('data_%s.csv', ver)));
% filename = fullfile(files.folder, files.name);
% game0 = readtable(filename, 'Delimiter', ',');
% idx = load(fullfile('../data', ver, 'idxsub_exclude'));
% tid = idx.idxsub(idx.id);
% 
% sub = readtable(fullfile('../data', ver, 'SUB_EE_blinkCuriosity_2016S.csv'),'Delimiter', ',');
% gp = W_sub.analysis_1group(sub(idx.id,:));
% 
% temp = {};
% for repi = 1:50
%     disp(repi);
%     load(fullfile('../data',verout, sprintf('bayes_6model_simu_rep%d.mat', repi)));
%     game = [];
%     for mi = 1:6
%         game{mi} = [];
%         for si = 1:length(tid)
%             tgame = game0(tid{si},:);
%             tgame.choice_5 = simu{mi}.choice(si,1:simu{mi}.nTrial(si))' + 1;
%             game{mi} = vertcat(game{mi} , tgame);
%         end
%         opt_sub = {'subjectID', 'date', 'time'};
%         opt_preprocess = 'EEpreprocess_game_basic';
%         opt_game_sub = W.iif(strcmp(ver, 'all'), {'EEpreprocess_game_sub_repeatedgame'},...
%             {'EEpreprocess_game_sub_repeatedpaironly'});
%         opt_analysis = {'EEanalysis_sub_basic'};
%         [simusub{mi}] = W_sub.analysis_pipeline(game{mi}, opt_sub, opt_preprocess, opt_game_sub, opt_analysis);
%         temp{repi, mi} = W_sub.analysis_1group(simusub{mi});
%     end
% end
% simugp = temp;
% save(fullfile('../data',verout, 'output_6model_simugp.mat'),'simugp');
%%
% load(fullfile('../data',verout, 'output_6model_simugp.mat'));
% for mi = 1:6
%     sgp.(['model' char(64 + mi)]) = W_sub.analysis_1group(vertcat(simugp{:,mi}),[],[],'');
% end
%% plotting 6 panel
% EEplot_2noise_modelcomparison1(plt, gp, simugp);
% EEplot_2noise_modelcomparison(plt, gp, sgp);
% %% parameter recovery of fitted simulations (A-F)
% name = {'A_','B_','C_','D_','E_','F_'};
% sp = {};
% for i = 1:6
%     disp(i);
%     sp{i} = load(fullfile(outputdir, [sprintf('HBI_DetRanNoise_fitmodel_') name{i} 'samples.mat'])).samples;
% %     for repi = 2:7
% %         disp(sprintf('%d,%d', i, repi));
% %         te = load(fullfile(outputdir, [sprintf('HBI_DetRanNoise_fitmodel_rep%d_',repi) name{i} 'samples.mat'])).samples;
% %         fns = {'NoiseRan', 'dNoiseRan', 'NoiseDet', 'dNoiseDet'};
% %         for fi = 1:length(fns)
% %             sp{i}.(fns{fi}) = cat(2, sp{i}.(fns{fi}), te.(fns{fi}));
% %         end
% %     end
% end
%%
EEplot_2noise_hyperprior_6model(plt, sp);