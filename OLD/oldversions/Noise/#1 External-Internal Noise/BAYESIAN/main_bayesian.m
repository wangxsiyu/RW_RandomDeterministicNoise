clear all, clc
path.main = pwd;
path.model = path.main;
path.result = '../';
path.data = '../';
path.param = path.main;
filename = 'data_bayesian.mat';
modelname = '2Sigma';
paramname = '2Sigma.mat';
%% load data 
load(fullfile(path.data, filename));
%% load param
load(fullfile(path.param, paramname));
%%
abe = analysis_bayesian(bayesdata, path.model, path.result);
%%
cd(path.main);
abe.analysis(modelname, params);
 