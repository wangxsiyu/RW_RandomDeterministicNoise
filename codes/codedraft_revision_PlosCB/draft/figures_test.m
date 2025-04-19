% 
% plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
%     'issave', false, 'extension',{'svg', 'jpg'});
% 
% old = plt.param_plt.fontsize_title;
% plt.param_plt.fontsize_title = 15;
% plt.figure(2,4,'is_title', 'all');
% gi = 1;
% EEplot_2noise_hyperpriors(plt, samples);
% plt.param_plt.fontsize_title = old;
% %%
% 
% plt.figure(1,1);
% stepsize = 0.01;
% xbins = [-20:stepsize:20];
% fns = {'NoiseRan', 'NoiseDet'};
% plt.setfig('xlabel', 'noise(H = 6)/noise(H = 1)', 'ylabel', 'posterior density', ...
%    'title','','ytick', '', ...
%    'xlim', [0,6]);
% plt.setfig_all('legend',{'Random noise', 'Deterministic noise'})
% cols = {'AZred', 'AZblue'; 'AZred50', 'AZblue50'};
% for ci = 1:2
%     for mi = 1:2
%         fn = fns{mi};
%         td = sp.(fn);
%         [tl, tm] = W.JAGS_density(td(:,:,2, ci)./td(:,:,1, ci), xbins);
%         plt.plot(tm, tl, [], 'line', 'color', cols{ci, mi});
%     end
% end
% plt.update('ratio',' ');
% %%
% 
% plt.figure(1,4);
% stepsize = 0.01;
% xbins = [15:stepsize:30];
% % cols = {'AZred', 'AZblue'};
% % 
% % for i = 1:4
% %     plt.ax(i)
% %     [tl, tm] = W.JAGS_density(result{i}, xbins);
% %     plt.plot(tm, tl, [], 'line', 'color', cols{1});
% %     [tl, tm] = W.JAGS_density(result{i+4}, xbins);
% %     plt.plot(tm, tl, [], 'line', 'color', cols{2});
% % end
% 
% plt.figure(1,1);
% cols = {'AZred', 'AZblue', 'AZcactus', 'AZsand'};
% 
% for i = 1:4
%     [tl, tm] = W.JAGS_density(result{i}, xbins);
%     plt.plot(tm, tl, [], 'line', 'color', cols{i});
% end