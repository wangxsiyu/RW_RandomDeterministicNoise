JAGS_setup_revision;
%% 6 model comparison (rest of the 5 models)
data = load(fullfile(fullfile('../data',ver), 'bayes_2noise_2cond.mat')).(['bayes_data_2cond']);
for mi = 2:6
    data.modelname = ['2noisemodel_2cond' char(64 + mi)];
    wj.setup_data_dir(data, outputdir);
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_2cond' char(64 + mi)]);
    wj.run;
end