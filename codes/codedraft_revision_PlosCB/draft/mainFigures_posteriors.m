%% bayesian plots
plt = W_plt('savedir', '../figures_revision', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true, 'extension',{'svg', 'jpg'});
outputdir = '../bayesoutput_revision/all_revision';
%% figure - posterior 
suffix = {''};
paramsub = [];
for gi = 1:1
    paramsub{gi} = load(fullfile(outputdir, ['HBI_DetRanNoise_2cond' suffix{gi} '_samples.mat'])).samples;
end
%% posterior
sz = [0.02 0.02;
    0.06 0.02];
for gii = 1:1
    plt.set_pltsetting('savesfx', suffix{gii});
    old = plt.param_plt.fontsize_title;
    plt.param_plt.fontsize_title = 15;
    plt.figure(2,2,'is_title', 'all');
    gi = W.mod0(gii, 2);
    plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
        'ylim', []);
    EEplot_2noise_hyperpriors_2cond(plt, paramsub{gii}, sz(gi,:));
    plt.param_plt.fontsize_title = old;
end
%%
paramsub = load(fullfile(outputdir, ['HBI_DetRanNoise_2condKF2_samples.mat'])).samples;
paramsub = load(fullfile(outputdir, ['HBI_DetRanNoise_dI_2condA_samples.mat'])).samples;
paramsub = load(fullfile(outputdir, ['HBI_DetRanNoise_dI2_2condA_samples.mat'])).samples;
%%
sz = [0.02 0.02;
    0.06 0.02];
plt.set_pltsetting('savesfx', {'KF'});
old = plt.param_plt.fontsize_title;
plt.param_plt.fontsize_title = 15;
plt.figure(2,2,'is_title', 'all');
gi = W.mod0(1, 2);
% plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
%     'ylim', []);
EEplot_2noise_hyperpriors_2cond(plt, paramsub, sz(gi,:)*1);
plt.param_plt.fontsize_title = old;
%%
fns = {'InfoBonus_mu_n'};
    color = {{'AZred50','AZred'},{'AZblue50','AZblue'}};
sp = paramsub;
i = 1;
stepsize = 0.002;
plt.figure(1,2);
xbins = [-.2:stepsize(i):.2];
fn = fns{i};
plt.ax(i*2-1);
td = sp.(fn);
plt.setfig('legend', {{'h = 1, [1 3]','h = 1, [2 2]','h = 6, [1 3]','h = 6, [2 2]'},{'change, [1 3]', 'change, [2 2]'}},...
    'xlabel', {'InfoBonus [points]', 'InfoBonus [points]'});
for hi = 1:2
    tm = []; tl = [];
    for j = 1:2
        [tl(j,:), tm(j,:)] = W.JAGS_density(td(:,:,hi, j), xbins);
    end
    plt.plot(tm, tl, [], 'line', 'color', {color{1}{hi}, color{2}{hi}});
end
hold on;
ylm = get(gca,'ylim');
plot([0 0],ylm, '--k','LineWidth', plt.param_plt.linewidth/2);
hold off;
fn = 'InfoBonus'
plt.ax(i*2);
td = sp.(['d' fn]);
tm = []; tl = [];
for j = 1:2
    [tl(j,:), tm(j,:)] = W.JAGS_density(td(:,:,j), xbins);
end
plt.plot(tm, tl, [], 'line', 'color', {'AZred', 'AZblue'});
hold on;
%         ylm = get(gca,'ylim');
plot([0 0],ylm, '--k','LineWidth', plt.param_plt.linewidth/2);
hold off;
% plt.setfig_ax('xlabel', 'InfoBonus');
plt.update;