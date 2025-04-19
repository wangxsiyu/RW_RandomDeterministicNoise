JAGS_setup;
%% main bayes
files = {'bayes_2noise.mat', 'bayes_2noise_all.mat'};
suffix = {'','_all'};
for fi = 1:2
    d = load(fullfile(fullfile('../data',ver), files{fi})).(['bayes_data', suffix{fi}]);
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise' suffix{fi}]);
    wj.run;
end
%% model no bias
% data = load(fullfile('../data', 'bayes_2noise.mat')).(['bayes_data']);
% data.modelname = ['2noisemodel_nobias'];
% wj.setup_data_dir(data, outputdir);
% wjinfo = EEbayes_analysis(data, nchains);
% wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_nobias']);
% wj.run;
%% model paironly
d = load(fullfile(fullfile('../data',ver), 'bayes_2noise_paironly.mat')).(['bayes_data_paironly']);
d.modelname = ['2noisemodel'];
wj.setup_data_dir(d, outputdir);
wjinfo = EEbayes_analysis(d, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_paironly']);
wj.run;
%% reduced model
files = {'bayes_2noise_dRonly.mat', 'bayes_2noise_0model.mat', 'bayes_2noise_dIonly.mat'};
suffix = {'_dRonly','_0model','_dIonly'};
for fi = 1:1 % just the first one
    d = load(fullfile(fullfile('../data',ver), files{fi})).(['bayes_data', suffix{fi}]);
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise' suffix{fi}]);
    wj.run;
end