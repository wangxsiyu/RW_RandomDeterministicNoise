%% get version
addpath(genpath('../codes_support/'));
ver = 'all_revision';
%%
W.cd();
outputdir = fullfile('../bayesoutput_revision', ver);
outputdir = W.get_fullpath(W.mkdir(outputdir));
wj = W_JAGS;
%% set up chains
nchains = 4; % How Many Chains?
nburnin = 2000; % How Many Burn-in Samples?
nsamples = 2000; % How Many Recorded Samples?
HBItest = '';
wj.setup_params(nchains, nburnin, nsamples);
%% test
% HBItest = 'test_';
% wj.setup_params;
%%
nchains = wj.bayes_params.nchains;
W.library_wang('Wang_EEHorizon', 1);
W.library('JAGS', 1);