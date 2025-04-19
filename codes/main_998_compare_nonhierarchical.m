files = fullfile('../bayesoutput/allR1',{'HBI_DetRanNoiseR1_stat','HBI_DetRanNoiseR1_nonhierarchical_stat'});
st = W.load(files);
st = W.cellfun(@(x)x.stats.mean, st, false);
%%
y1 = W.load('./Temp/HBI_fit_real_stat'); y1 = y1.stats.mean;
%% simuilate non-hierarchical
simu = EEsimulate_bayes_2noise_simple(data, st{2}.Infobonus_sub, ...
    st{2}.bias_sub, st{2}.NoiseRan_sub, st{2}.NoiseDet_sub);
d = simu;
d.modelname = sprintf('2noisemodel');
wj.setup_data_dir(d, './Temp');
wjinfo = EEbayes_analysis(d, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fit_simu_nonhierarchical']);
wj.run;
%%
y2 = W.load('./Temp/HBI_fit_simu_nonhierarchical_stat'); y2 = y2.stats.mean;
%%
plt = W_plt;
plt.figure(2,2, 'is_title', 'all', 'gapW_custom', [7 0 0])
plt.ax(1);
plt = plot_nonhierarchical(plt, st{1}, y1, 3, [1 2], 'hierarchical');
plt.ax(2);
plt = plot_nonhierarchical(plt, st{2}, y2, 3, [3 4], 'non-hierarchical');
plt.update;