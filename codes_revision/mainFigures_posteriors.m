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