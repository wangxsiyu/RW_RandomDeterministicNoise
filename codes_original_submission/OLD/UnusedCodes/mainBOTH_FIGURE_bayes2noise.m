%% setup
ver = 'all_50chains';
outputdir = fullfile('../bayesoutput', ver);
figdir = fullfile('../figures', ver);
plt = W_plt;
% %% reduced models - dRonly, dIonly, 0model, no-bias
% plt.initialize('new', 'fig_dir', figdir,'fig_suffix', '', 'fig_projectname', 'RanDetNoise');
% sp = {};
% sp{2} = load(fullfile(outputdir, ['HBI_DetRanNoise_samples.mat'])).samples;
% % sp{2} = load(fullfile(outputdir, ['HBI_DetRanNoise_nobias_samples.mat'])).samples;
% sp{1} = load(fullfile(outputdir, ['HBI_DetRanNoise_dRonly_samples.mat'])).samples;
% % sp{4} = load(fullfile(outputdir, ['HBI_DetRanNoise_dIonly_samples.mat'])).samples;
% % sp{5} = load(fullfile(outputdir, ['HBI_DetRanNoise_0model_samples.mat'])).samples;
% plt.setfig_new;
% EEplot_2noise_reduced(plt, sp);


% plt.save('ratio1');
% %% ratio plot (random/deterministic)
% sp = load(fullfile(outputdir, ['HBI_DetRanNoise_samples.mat'])).samples;
% plt.figure(1,1);
% plt.new;
% stepsize = 0.02;
% xbins = [-1:stepsize:10];
% fns = {'NoiseRan', 'NoiseDet'};
% plt.setfig_ax('color', {'AZred', 'AZblue'}, 'legend', {'H = 1', 'H = 6'}, ...
%     'xlabel', 'Ran/Det', 'ylabel', 'density');
% tt = [];
% for hi = 1:2
%     td = sp.(fns{1});
%     td1 = squeeze(td(:,:,hi));
%     td1 = reshape(td1, 1, []);
%     td = sp.(fns{2});
%     td2 = squeeze(td(:,:,hi));
%     td2 = reshape(td2, 1, []);
%     tt(hi,:) = hist(td1./td2, xbins)/(length(td1./td2)*stepsize);
% end
% plt.lineplot(tt, [], xbins);
% plt.update;
% % plt.save('ratio');
% %% ratio plot (bias)
% plt.figure;
% plt.new;
% stepsize = 0.02;
% xbins = [-3:stepsize:3];
% fns = {'bias_mu_n'};
% plt.setfig('color', {'AZred', 'AZblue'}, 'legend', {'H = 1', 'H = 6'}, ...
%     'xlabel', 'bias', 'ylabel', 'density');
% tt = [];
% for hi = 1:2
%     td = sp.(fns{1});
%     td1 = squeeze(td(:,:,hi));
%     td1 = reshape(td1, 1, []);
%     tt = hist(td1, xbins)/(length(td1)*stepsize);
%     plt.lineplot(tt, [], xbins);
% end
% plt.update;
% % plt.save('ratio2');
%%
% plt.figure();
% plt.new;
% stepsize = 0.02;
% xbins = [-1:stepsize:3];
% fns = {'NoiseRan', 'NoiseDet'};
% plt.setfig('xlabel','ratio ran', 'ylabel', 'ratio det');
% tt = {};
% for mi = 1:2
%     fn = fns{mi};
%     td = sp.(fn);
%     td1 = squeeze(td(:,:,1));
%     td1 = reshape(td1, 1, []);
%     td2 = squeeze(td(:,:,2));
%     td2 = reshape(td2, 1, []);
%     tt{mi} = td2./td1;
% end
% str = plt.scatter(tt{1}', tt{2}', 'corr');
% plt.setfig('legend',str);
% plt.update;
% plt.save('ratio3');