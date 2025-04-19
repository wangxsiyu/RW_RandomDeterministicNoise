JAGS_setup;
%% 6 model comparison (rest of the 5 models)
data = load(fullfile(fullfile('../data',ver), 'bayes_2noise.mat')).(['bayes_data']);
for mi = 2:6
    data.modelname = ['2noisemodel' char(64 + mi)];
    wj.setup_data_dir(data, outputdir);
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' char(64 + mi)]);
    wj.run;
end