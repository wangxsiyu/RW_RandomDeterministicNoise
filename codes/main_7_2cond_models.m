%% test convergence
JAGS_setup_R1;
nchains = 4; % How Many Chains?
nburnin = 0; % How Many Burn-in Samples?
nsamples = 5000; % How Many Recorded Samples?
wj.setup_params(nchains, nburnin, nsamples);
d = load(fullfile('../data/all', 'bayesdata.mat')).(['bayesdata']);
d.modelname = '2noisemodel_2cond';
wj.setup_data_dir(d, outputdir);
wjinfo = EEbayes_analysis(d, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, 'DetRanNoiseR1_convergence');
wj.run;
%% main bayes (base classes)
% set of models
% 1cond vs 2cond
% dI vs dIvar
suffix = {'', '_dIvar', '_2cond', '_2cond_dIvar', '_2cond_dIvar_both', '_2cond_dRonly', '_2cond_nobias', ...
    'B_2cond','C_2cond','D_2cond','E_2cond','F_2cond','_2cond_nonhierarchical'};% reviewer fit non-hierarchical
for fi = 1:length(suffix)
    JAGS_setup_R1;
    d = load(fullfile('../data/all', 'bayesdata.mat')).(['bayesdata']);
    d.modelname = sprintf('2noisemodel%s', suffix{fi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoiseR1' suffix{fi}]);
    wj.run;
end
%% explained variance
sp = W.load('../bayesoutput/allR1/HBI_DetRanNoiseR1_2cond_samples.mat');
%% get explained variance
det = []; ran = [];
vardet = [];
for i = 1:2
    det(i,:) = reshape(sp.NoiseDet(:,:,i),1,[]);
    ran(i,:) = reshape(sp.NoiseRan(:,:,i),1,[]);
    vardet(i,:) = det(i,:).^2./(det(i,:).^2 + ran(i,:).^2);
end
ddet = reshape(sp.dNoiseDet,1,[]);
dran = reshape(sp.dNoiseRan,1,[]);
vard = (ddet.^2./(ddet.^2+dran.^2));
W.print('explained variance: %.2f', mean(vardet, 'all')*100);
W.print('explained variance 5%%: %.2f', quantile(reshape(vardet,1,[]),[0.025 0.975])*100);
%% bayesian plots
plt = W_plt('savedir', '../figures', 'savepfx', 'R1', 'isshow', true, ...
    'issave', true, 'extension',{'svg', 'jpg'});
%% figure - posterior dI
sp = W.load(fullfile(outputdir, 'HBI_DetRanNoiseR1_2cond_samples.mat'));
%% plot posterior
sz = [0.02 0.02];
old = plt.param_plt.fontsize_title;
plt.param_plt.fontsize_title = 15;
plt.param_plt.pixel_h = 150;
plt.figure(4,2,'is_title', 'all');
gi = 1;
plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4], [-1 10+10*gi], [-3 8 + gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
    'ylim', []);
EEplot_2noise_hyperpriors_2cond(plt, sp, sz);
plt.param_plt.fontsize_title = old;
%% ratio plot (h = 6/h = 1, for ran and det)
plt.param_plt.pixel_h = 300;
plt.figure(1,1);
stepsize = 0.02;
xbins = [-20:stepsize:20];
fns = {'NoiseRan', 'NoiseDet'};
plt.setfig('xlabel', 'noise(H = 6)/noise(H = 1)', 'ylabel', 'posterior density', ...
    'title','','ytick', '', ...
    'xlim', [0,6]);
plt.setfig_all('legend',{'Random, [1 3]', 'Random, [2 2]', 'Deterministic, [1 3]', 'Deterministic, [2 2]'})

cols = {'AZcactus', 'AZsand', 'AZcactus50', 'AZsand50'};
for mi = 1:2
    fn = fns{mi};
    td = sp.(fn);
    [tl, tm] = W.JAGS_density(td(:,:,2,1)./td(:,:,1,1), xbins);
    plt.plot(tm, tl, [], 'line', 'color', cols{mi});
    [tl, tm] = W.JAGS_density(td(:,:,2,2)./td(:,:,1,2), xbins);
    plt.plot(tm, tl, [], 'line', 'color', cols{mi+2});
end
plt.update('ratio_2cond',' ');
%% figure - posterior dIvar
sp = W.load(fullfile(outputdir, 'HBI_DetRanNoiseR1_dIvar_samples.mat'));
%%
sz = [0.02 0.02];
gi = 1;
plt.param_plt.pixel_h = 300;
plt.set_pltsetting('savesfx', 'dIvar');
old = plt.param_plt.fontsize_title;
plt.param_plt.fontsize_title = 15;
plt.figure(2,2,'is_title', 'all');
plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
    'ylim', []);
EEplot_2noise_hyperpriors(plt, sp, sz(gi,:));
plt.param_plt.fontsize_title = old;
% run get explained variance section
