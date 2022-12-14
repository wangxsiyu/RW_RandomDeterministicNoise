outputdir = '../bayesoutput/all/';
sp = load(fullfile(outputdir, ['HBI_DetRanNoise_samples.mat'])).samples;
%% compute confidence interval
ci = struct;
ci.dNoiseRan = quantile(reshape(sp.dNoiseRan,1,[]), [0.025, 0.975]);
ci.dNoiseDet = quantile(reshape(sp.dNoiseDet,1,[]), [0.025, 0.975]);
for i = 1:2
    ci.NoiseRan(i,:) = quantile(reshape(sp.NoiseRan(:,:,i),1,[]), [0.025, 0.975]);
    ci.NoiseDet(i,:) = quantile(reshape(sp.NoiseDet(:,:,i),1,[]), [0.025, 0.975]);
end
%% compute coverage
simudir = '../bayesoutput/simurepeat';
coverage = struct;
for repi = 1:200
    tstat = load(fullfile(simudir, sprintf('HBI_DetRanNoise_simu_%d_stat.mat', repi)));
    coverage.dNoiseRan(repi) = W.is_between(tstat.stats.mean.dNoiseRan, ci.dNoiseRan);
    coverage.dNoiseDet(repi) = W.is_between(tstat.stats.mean.dNoiseDet, ci.dNoiseDet);
    for i = 1:2
        coverage.NoiseRan(repi, i) = W.is_between(tstat.stats.mean.NoiseRan(i), ci.NoiseRan(i,:));
        coverage.NoiseDet(repi, i) = W.is_between(tstat.stats.mean.NoiseDet(i), ci.NoiseDet(i,:));
    end
end
%%

%     simunum = num2str(i);
%     plt.setup_W_plt('fig_dir', fullfile(figdir,'parameter_recovery'),...
%         'fig_suffix', [simunum],'fig_projectname', ['RanDetNoise' vv],...
%         'isshow', true);
%     sp2 = load(fullfile(outputdir, ['HBI_DetRanNoise_fitmodel_A_samples.mat'])).samples;
%     plt = EEplot_2noise_parameter_recovery_hyperprior(plt, sp, sp2);