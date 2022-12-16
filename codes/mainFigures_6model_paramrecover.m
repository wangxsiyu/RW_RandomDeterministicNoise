%% original models (A-F)
outputdir = '../bayesoutput/all';
name = {'','B_','C_','D_','E_','F_'};
sp = cell(1,6);
for i = 1:6
    sp{i} = load(fullfile(outputdir, ['HBI_DetRanNoise_' name{i} 'samples.mat'])).samples;
end
%%
EEplot_2noise_hyperpriors_6model(plt, sp);
%% parameter recovery of fitted simulations (A-F)
name = {'A','B','C','D','E','F'};
spsimu = cell(50,6);
W.unmuteprint()
for i = 1:6
    for repi = 1:50
        W.print('version %s, rep %d', name{i}, repi);
        tspsimu = importdata(fullfile('../bayesoutput/simu6model', ...
            sprintf('HBI_DetRanNoise_fitmodel_rep%d_%s_samples.mat', repi, name{i})));
        
    end
end
%%
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
EEplot_2noise_hyperpriors_6model(plt, sp);