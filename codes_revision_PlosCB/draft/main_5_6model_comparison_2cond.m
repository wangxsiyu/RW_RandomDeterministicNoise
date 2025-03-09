JAGS_setup_revision;
%% 6 model comparison (rest of the 5 models)
data = load(fullfile(fullfile('../data',ver), 'bayes_2noise_2cond_dIvar.mat')).(['bayes_data_2cond_dIvar']);
for mi = 1:6
    data.modelname = ['2noisemodel_dI_2cond' char(64 + mi)];
    wj.setup_data_dir(data, outputdir);
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_dI_2cond' char(64 + mi)]);
    wj.run;
end

%%
data = load(fullfile(fullfile('../data',ver), 'bayes_2noise_2cond_dIvar2.mat')).(['bayes_data_2cond_dIvar2']);
for mi = 1:1
    data.modelname = ['2noisemodel_dI_2cond' char(64 + mi)];
    wj.setup_data_dir(data, outputdir);
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_dI2_2cond' char(64 + mi)]);
    wj.run;
end