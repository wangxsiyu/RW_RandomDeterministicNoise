%% load fitted data
st0 = W.load(fullfile('../bayesoutput/allR1', ['HBI_DetRanNoiseR1_stat']));
st0 = st0.stats.mean;
%% simulate data from fitted model
st_shuffled = st0;
nsub = size(st_shuffled.Infobonus_sub, 2);
% for i = 1:2
%     id1 = randperm(nsub);
%     st_shuffled.NoiseRan_sub(i,:) = st_shuffled.NoiseRan_sub(i,id1);
%     id1 = randperm(nsub);
%     st_shuffled.NoiseDet_sub(i,:) = st_shuffled.NoiseDet_sub(i,id1);
% end
id1 = randperm(nsub*2);
st_shuffled.NoiseRan_sub = reshape(st_shuffled.NoiseRan_sub(id1),2,[]);
id1 = randperm(nsub*2);
st_shuffled.NoiseDet_sub = reshape(st_shuffled.NoiseDet_sub(id1),2,[]);
simu_shuffled = EEsimulate_bayes_2noise_simple(data, st_shuffled.Infobonus_sub, ...
    st_shuffled.bias_sub, st_shuffled.NoiseRan_sub, st_shuffled.NoiseDet_sub);
save(fullfile('./Temp', ['simugames_shuffle_overall']), 'simu_shuffled', 'st_shuffled');
%% fit model
% simu = EEsimulate_bayes_2noise_simple(data, st0.Infobonus_sub, ...
%     st0.bias_sub, st0.NoiseRan_sub, st0.NoiseDet_sub);
% d = simu;
% wj.isoverwrite = true;
% d.modelname = '2noisemodel';
% wj.setup_data_dir(d, './Temp');
% wjinfo = EEbayes_analysis(d, nchains);
% wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fit_real']);
% wj.run;
%%
d = simu_shuffled;
wj.isoverwrite = true;
d.modelname = '2noisemodel';
wj.setup_data_dir(d, './Temp');
wjinfo = EEbayes_analysis(d, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fit_shuffled_overall']);
wj.run;
%% calculate recovery matrix for simulated data
st1 = W.load('./Temp/HBI_fit_shuffled_overall_stat');
st1 = st1.stats.mean;
%%
st_shuffled = W.load('./Temp/simugames_shuffle_overall.mat');
plt = W_plt('savedir', '../figures', 'savepfx', 'R1_shuffle', 'isshow', true, ...
    'issave', true);
%%
plot_det_vs_ran(plt, st_shuffled.st_shuffled, st1)
%%
% st2 = W.load('./Temp/HBI_fit_real_stat');
% st2 = st2.stats.mean;
% plot_det_vs_ran(plt, st0, st2)
