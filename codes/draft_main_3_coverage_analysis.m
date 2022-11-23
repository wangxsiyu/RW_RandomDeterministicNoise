JAGS_setup;
%% load fitted params
paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_stat.mat'])).stats.mean;
param = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_samples.mat'])).samples;
%% simulate behavior
data = importdata('../data/all/bayes_2noise.mat');
data.modelname = ['2noisemodel'];
for numi = 1:100
    simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
        paramsub.bias_sub', paramsub.NoiseRan_sub', paramsub.NoiseDet_sub');
    % fit
    wj.setup_data_dir(simugame, outputdir);
    wjinfo = EEbayes_analysis(simugame, nchains, mdpath);
    wj.setup(wjinfo.modelfile, wjinfo.params, wjinfo.init0, ['DetRanNoise_' vv 'simu' num2str(numi)]);
    wj.run;
end