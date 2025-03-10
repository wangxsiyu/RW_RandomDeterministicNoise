%% main bayes
suffix = {'', '_2cond', '_2cond_dIvar', '_2cond_dIvar_both'};
for fi = 1:4
    JAGS_setup_revision;
%     wj.setup_params;
    d = load(fullfile(fullfile('../data',ver), 'bayesdata.mat')).(['bayesdata']);
    d.modelname = sprintf('2noisemodel%s', suffix{fi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoiseR1' suffix{fi}]);
    wj.run;
end
%% compute data likelihood
%% posterior checks