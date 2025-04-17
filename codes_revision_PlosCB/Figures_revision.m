%% example posterior for non-hierarchical models
sp = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_nonhierarchical_samples.mat'])).samples;
sp2 = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_samples.mat'])).samples;
%%
plt = W_plt;
plt.figure(1,2);
subi = 20;
xbins = -5:.1:200;
plt.ax(1);
td = sp.NoiseRan_sub(:,:,1,1,subi);
td2 = sp2.NoiseRan_sub(:,:,1,1,subi);
[tl, tm] = W.JAGS_density(td, xbins);
plt.plot(tm, tl, [], 'line', 'color', 'red');
[tl, tm] = W.JAGS_density(td2, xbins);
plt.plot(tm, tl, [], 'line', 'color', 'black');
hold on;
ylm = get(gca,'ylim');
plot([0 0],ylm, '--k','LineWidth', plt.param_plt.linewidth/2);
hold off;
%% parameter recovery for non-hierarchical models
p1 = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_nonhierarchical_stat.mat'])).stats.mean;
p2 = load(fullfile(outputdir, ['HBI_DetRanNoise_simu_non_hierarchical_stat.mat'])).stats.mean;
plt.figure(2,2);
EEplot_2noise_parameter_recovery(plt, p1, p2, -1)
%% correlation between simulation and fit
p2 = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_stat.mat'])).stats.mean;
p1 = load(fullfile(outputdir, ['HBI_DetRanNoise_simu_non_hierarchical_stat.mat'])).stats.mean;
p2 = load(fullfile(outputdir, ['HBI_DetRanNoise_simu_non_hierarchical_shuffled_stat.mat'])).stats.mean;


p1 = load(fullfile(outputdir, ['HBI_DetRanNoiseR1_2cond_stat.mat'])).stats.mean;
p2 = load(fullfile(outputdir, ['HBI_DetRanNoise_simu_shuffled_stat.mat'])).stats.mean;

%%
plt.setfig_all('legloc', 'NW');
plt.figure(2,2);
i = 1;
for hi = 1:2
    plt.ax(i, hi);
    d1 = p2.NoiseRan_sub(hi,1,:);
    d2 = p2.NoiseDet_sub(hi,1,:);
    d1 = [d1(:)];
    d2 = [d2(:)];
    str = plt.scatter(d1', d2', 'corr'); %{i*2-2+hi}
    plt.setfig_ax('legend', str);
    %             lsline
end
i = 2;
for hi = 1:2
    plt.ax(i, hi);
    d1 = p2.NoiseRan_sub(hi,2,:);
    d2 = p2.NoiseDet_sub(hi,2,:);
    d1 = [d1(:)];
    d2 = [d2(:)];
    str = plt.scatter(d1', d2', 'corr'); %{i*2-2+hi}
    plt.setfig_ax('legend', str);
    %             lsline
end
plt.update;