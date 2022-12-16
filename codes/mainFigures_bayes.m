%% bayesian plots
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
outputdir = '../bayesoutput/all';
%% figure - posterior 
suffix = {'','_all','_paironly'};
paramsub = [];
for gi = 1:3
    paramsub{gi} = load(fullfile(outputdir, ['HBI_DetRanNoise' suffix{gi} '_samples.mat'])).samples;
end
%% posterior
sz = [0.02 0.02;
    0.06 0.02];
for gii = 1:3
    plt.set_pltsetting('savesfx', suffix{gii});
    plt.figure(2,2,'is_title', 'all');
    gi = W.mod0(gii, 2);
    plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
        'ylim', []);
    EEplot_2noise_hyperpriors(plt, paramsub{gii}, sz(gi,:));
end
%% reduced models
sp = {};
sp{2} = paramsub{1};
sp{1} = load(fullfile(outputdir, ['HBI_DetRanNoise_dRonly_samples.mat'])).samples;
%
EEplot_2noise_reduced(plt, sp);
%% ratio of deterministic vs random noise
%% ratio plot (h = 6/h = 1, for ran and det, A and b)
sp = paramsub{1};
plt.figure(4,1,'istitle',0,'rect',[0 0 0.5 0.9],...
    'margin',[0.1 0.11 0.02 0.02]);
stepsize = 0.04;
xbins = [-30:stepsize:30];
fns = {'NoiseRan', 'NoiseDet','InfoBonus_mu_n','bias_mu_n'};
plt.setfig('legend', {'Random noise', 'Deterministic noise','Information bonus','spatial bias'}, ...
   'xlabel', {'','','','ratio of increase (H = 6/H = 1)'}, 'ylabel', {'\sigma_{Ran}','\sigma_{Det}','A','b'},'title','','ytick', '', ...
   'xlim', [-10,10]);
tt = [];
cols = {'AZred', 'AZblue','AZcactus','AZsand'};
for mi = 1:4
    plt.ax(mi);
    fn = fns{mi};
    td = sp.(fn);
    [tl, tm] = W.JAGS_density((td(:,:,2)./td(:,:,1)), xbins);
    plt.plot(tm, tl, [], 'line', 'color', cols{mi});
end
plt.update;
%% ratio plot (h = 6/h = 1, for ran and det)
plt.figure(1,1);
stepsize = 0.01;
xbins = [-20:stepsize:20];
fns = {'NoiseRan', 'NoiseDet'};
plt.setfig('xlabel', 'noise(H = 6)/noise(H = 1)', 'ylabel', 'posterior density', ...
   'title','','ytick', '', ...
   'xlim', [0,6]);
plt.setfig_all('legend',{'Random noise', 'Deterministic noise'})
cols = {'AZred', 'AZblue'};
for mi = 1:2
    fn = fns{mi};
    td = sp.(fn);
    [tl, tm] = W.JAGS_density(td(:,:,2)./td(:,:,1), xbins);
    plt.plot(tm, tl, [], 'line', 'color', cols{mi});
end
plt.update('ratio');