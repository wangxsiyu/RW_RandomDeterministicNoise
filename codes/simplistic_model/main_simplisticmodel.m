%% generate simulated data
n = 100;
nran = 0.001;
ndet = 5;
bayes = getbayessimu(n, nran, ndet);
%%
cd(W.funcout('fileparts', 1, matlab.desktop.editor.getActiveFilename));
outputdir = fullfile('../../bayesoutput', 'simplistic');
outputdir = GetFullPath(outputdir);
wj = W_JAGS;
wj.isoverwrite = true;
%% set up chains
nchains = 4; % How Many Chains?
nburnin = 2000; % How Many Burn-in Samples?
nsamples = 2000; % How Many Recorded Samples?
HBItest = '';
wj.setup_params(nchains, nburnin, nsamples);
%%
nchains = wj.bayes_params.nchains;
%% main bayes
wj.setup_data_dir(bayes, outputdir);
% paths = strsplit(path, ':');
% pid = find(contains(string(paths), 'HBI_models'));
% mdpath = paths{pid};
mdpath = GetFullPath('../HBI_models');
mdfile = fullfile(mdpath, 'simple_2noise.txt');
params = {'NoiseRan','NoiseDet'};
wj.setup(mdfile, params, struct, 'simplistic');
wj.run;
%% load result
plt = W_plt;
sp = importdata(fullfile(outputdir, 'HBI_simplistic_samples.mat'));
plt.figure(1,2);
fns = {'NoiseDet', 'NoiseRan'};
stepsize = 0.02;
xbins = [-20:stepsize:20];
for i = 1:2
    plt.new;
    fn = fns{i};
    td = sp.(fn);
    td = squeeze(td(:));
    td = reshape(td, 1, []);
    tl = hist(td, xbins)/(length(td)*stepsize);
    plt.lineplot(tl, [], xbins);
end
hold on;
ymax = 1.2;
plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
hold off;
