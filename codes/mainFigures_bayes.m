%% bayesian plots
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
outputdir = '../bayesoutput/all';
%% figure - posterior 
suffix = {'','_all'};
paramsub = [];
for gi = 1:2
    paramsub{gi} = load(fullfile(outputdir, ['HBI_DetRanNoise' suffix{gi} '_samples.mat'])).samples;
end
%%
sz = [0.02 0.02;
    0.06 0.02];
for gi = 1:2
    plt.set_pltsetting('savesfx', suffix{gi});
    plt.figure(2,2,'is_title', 'all');
    plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
        'ylim', []);
    EEplot_2noise_hyperpriors(plt, paramsub{gi}, sz(gi,:));
end