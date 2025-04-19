JAGS_setup;
%% load fitted params
paramsub = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoiseR1_2cond_stat.mat'])).stats.mean;
% param = load(fullfile(outputdir, [HBItest 'HBI_DetRanNoise_samples.mat'])).samples;
%% simulate behavior
data = importdata('../data/all_revision/bayesdata.mat');
data.modelname = ['2noisemodel_2cond'];
for numi = 1:20
    W.print('rep: %d', numi);
    simugame = EEsimulate_bayes_2noise_2cond(data, paramsub.Infobonus_sub, ...
        paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
    % fit
    wj.setup_data_dir(simugame, '../bayesoutput_revision/simurepeat');
    wjinfo = EEbayes_analysis(simugame, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_simu_' num2str(numi)]);
    wj.run;
    W.save(sprintf('../bayesoutput_revision/simurepeat/simugame_%d.mat', numi), ...
        'simugame', simugame);
end
%% non-hierarchical
data = load(fullfile('../data/all_revision/bayesdata.mat')).(['bayesdata']);
st = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_nonhierarchical_stat.mat'])).stats.mean;
tfile = fullfile(W.mkdir('../bayesoutput_revision/all_revision'), 'bayes_nonhierarchical.mat');
simu = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub, ...
    st.bias_sub, st.NoiseRan_sub, st.NoiseDet_sub);
save(tfile,'simu');

simu.modelname = '2noisemodel_2cond_nonhierarchical';

% fit
wj.setup_data_dir(simu, '../bayesoutput_revision/all_revision');
wjinfo = EEbayes_analysis(simu, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, 'DetRanNoise_simu_non_hierarchical');
wj.run;
%% simulate behavior non-hierarchical
st = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_nonhierarchical_stat.mat'])).stats.mean;
data = importdata('../data/all_revision/bayesdata.mat');
data.modelname = ['2noisemodel_2cond'];
for numi = 1:2
    W.print('rep: %d', numi);
    simugame = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub, ...
        st.bias_sub, st.NoiseRan_sub, st.NoiseDet_sub);
    % fit
    % wj.setup_data_dir(simugame, '../bayesoutput_revision/simurepeat');
    % wjinfo = EEbayes_analysis(simugame, nchains);
    % wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_nonhierarchical_simu_' num2str(numi)]);
    % wj.run;
    W.save(sprintf('../bayesoutput_revision/simurepeat/simugame_nonhierarchical_%d.mat', numi), ...
        'simugame', simugame);
end
%% shuffled non-hierarchical
data = load(fullfile('../data/all_revision/bayesdata.mat')).(['bayesdata']);
st = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_nonhierarchical_stat.mat'])).stats.mean;
tfile = fullfile(W.mkdir('../bayesoutput_revision/all_revision'), 'bayes_nonhierarchical_shuffled.mat');
nsub = size(st.Infobonus_sub, 2);
id1 = randperm(nsub);
id2 = randperm(nsub);
id3 = randperm(nsub);
id4 = randperm(nsub);
simu_shuffled = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub(:,id1), ...
    st.bias_sub(:, id2), st.NoiseRan_sub(:,:,id3), st.NoiseDet_sub(:,:,id4));
save(tfile,'simu_shuffled');

simu.modelname = '2noisemodel_2cond_nonhierarchical';

% fit
wj.setup_data_dir(simu, '../bayesoutput_revision/all_revision');
wjinfo = EEbayes_analysis(simu, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, 'DetRanNoise_simu_non_hierarchical_shuffled');
wj.run;
%% shuffled hierarchical
data = load(fullfile('../data/all_revision/bayesdata.mat')).(['bayesdata']);
st = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_stat.mat'])).stats.mean;
tfile = fullfile(W.mkdir('../bayesoutput_revision/all_revision'), 'bayes_shuffled.mat');
nsub = size(st.Infobonus_sub, 2);
id1 = randperm(nsub);
id2 = randperm(nsub);
id3 = randperm(nsub);
id4 = randperm(nsub);
simu_shuffled = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub(:,id1), ...
    st.bias_sub(:, id2), st.NoiseRan_sub(:,:,id3), st.NoiseDet_sub(:,:,id4));

st.Infobonus_sub = st.Infobonus_sub(:,id1);
st.bias_sub = st.bias_sub(:,id2);
st.NoiseRan_sub = st.NoiseRan_sub(:,:,id3);
st.NoiseDet_sub = st.NoiseDet_sub(:,:,id4);
save(tfile,'simu_shuffled', 'st');
st = W.load('../bayesoutput_revision/all_revision/bayes_shuffled')

% fit
simu_shuffled.modelname = '2noisemodel_2cond';
wj.setup_data_dir(simu_shuffled, '../bayesoutput_revision/all_revision');
wjinfo = EEbayes_analysis(simu_shuffled, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, 'DetRanNoise_simu_shuffled');
wj.run;

%% shuffled non-hierarchical
simu_shuffled.modelname = '2noisemodel_2cond_nonhierarchical';
wj.setup_data_dir(simu_shuffled, '../bayesoutput_revision/all_revision');
wjinfo = EEbayes_analysis(simu_shuffled, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, 'DetRanNoise_simu_non_hierarchical_shuffled');
wj.run;