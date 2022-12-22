clear all, clc;
addpath('S:\ANALYSIS\HORIZONTASK');
explist = {'AU_2015_personality', 'AU_2015_testRetestAndPersonality', ...
    'AU_017-Data_Fall2016','AU_075_Horizon1_Original'};
%     explist = {'AU_075_Horizon1_Original'};
cond_exptrial = 1;
cond_site = 1;
cond_repeated = 1;
[data, summary] = select_datasets(cond_exptrial, cond_site, cond_repeated, explist);
save('data_arizona','data','summary');
explist = {};
cond_exptrial = 1;
cond_site = 2;
cond_repeated = 1;
[data, summary] = select_datasets(cond_exptrial, cond_site, cond_repeated, explist);
save('data_princeton','data','summary');