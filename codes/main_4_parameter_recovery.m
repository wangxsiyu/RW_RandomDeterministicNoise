JAGS_setup;
%% load fitted params
paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_stat.mat'])).stats.mean;
% param = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_samples.mat'])).samples;
%% simulate behavior
data = importdata('../data/all/bayes_2noise.mat');
data.modelname = ['2noisemodel'];
for numi = 1:200
    W.print('rep: %d', numi);
    simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
        paramsub.bias_sub', paramsub.NoiseRan_sub', paramsub.NoiseDet_sub');
    % fit
    wj.setup_data_dir(simugame, '../bayesoutput/simurepeat');
    wjinfo = EEbayes_analysis(simugame, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_simu_' num2str(numi)]);
    wj.run;
    W.save(sprintf('../bayesoutput/simurepeat/simugame_%d.mat', numi), ...
        'simugame', simugame);
end