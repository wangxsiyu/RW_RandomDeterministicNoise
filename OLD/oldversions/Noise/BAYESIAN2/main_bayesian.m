clear all, clc
path.main = pwd;
path.model = path.main;
path.result = path.main;
path.data = './';
path.param = path.main;
filename = '075fake_bayesian.mat';
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
abe.analysis(modelname, params, filename(1:end-4));
%%
r1 = importdata('result_2Sigma.mat');
r2 = importdata('result_075fake_bayesian.mat');
idx = importdata('ro_075fake.mat');
s1 = r1.stats;
s2 = r2.stats;
m1 = s1.mean;
m2 = s2.mean;
for hi = 1:2
    figure(1);
    subplot(1,2,hi);
    hold on;
    scatter(m1.As(hi,idx), m2.As(hi,:));
    mi = min([m1.As(hi,:),m2.As(hi,:)]);
    ma = max([m1.As(hi,:),m2.As(hi,:)]);
    plot([mi, ma],[mi ma],'r');
    figure(2);
    subplot(1,2,hi);
    hold on;
    scatter(m1.bs(hi,idx), m2.bs(hi,:));
    mi = min([m1.bs(hi,:),m2.bs(hi,:)]);
    ma = max([m1.bs(hi,:),m2.bs(hi,:)]);
    plot([mi, ma],[mi ma],'r');
    figure(3);
    subplot(1,2,hi);
    hold on;
    scatter(m1.dNs(hi,idx), m2.dNs(hi,:));
    mi = min([m1.dNs(hi,:),m2.dNs(hi,:)]);
    ma = max([m1.dNs(hi,:),m2.dNs(hi,:)]);
    plot([mi, ma],[mi ma],'r');
    figure(4);
    subplot(1,2,hi);
    hold on;
    scatter(m1.Eps(hi,idx), m2.Eps(hi,:));
    mi = min([m1.Eps(hi,:),m2.Eps(hi,:)]);
    ma = max([m1.Eps(hi,:),m2.Eps(hi,:)]);
    plot([mi, ma],[mi ma],'r');
    
end