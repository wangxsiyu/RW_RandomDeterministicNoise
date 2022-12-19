outputdir = '../bayesoutput/all/';
sp = load(fullfile(outputdir, ['HBI_DetRanNoise_samples.mat'])).samples;
% %% compute confidence interval
% ci = struct;
% ci.dNoiseRan = quantile(reshape(sp.dNoiseRan,1,[]), [0.025, 0.975]);
% ci.dNoiseDet = quantile(reshape(sp.dNoiseDet,1,[]), [0.025, 0.975]);
% for i = 1:2
%     ci.NoiseRan(i,:) = quantile(reshape(sp.NoiseRan(:,:,i),1,[]), [0.025, 0.975]);
%     ci.NoiseDet(i,:) = quantile(reshape(sp.NoiseDet(:,:,i),1,[]), [0.025, 0.975]);
% end
%% compute coverage
simudir = '../bayesoutput/simurepeat';
coverage = struct;
recovered = struct;
for repi = 1:200
    tstat = load(fullfile(simudir, sprintf('HBI_DetRanNoise_simu_%d_stat.mat', repi)));
    recovered.dNoiseRan(repi) = tstat.stats.mean.dNoiseRan;
    recovered.dNoiseDet(repi) = tstat.stats.mean.dNoiseDet;
    coverage.dNoiseRan(repi) = W.is_between(mean(sp.dNoiseRan,'all'), [tstat.stats.ci_low.dNoiseRan tstat.stats.ci_high.dNoiseRan]);
    coverage.dNoiseDet(repi) = W.is_between(mean(sp.dNoiseDet,'all'), [tstat.stats.ci_low.dNoiseDet tstat.stats.ci_high.dNoiseDet]);
    for i = 1:2
        coverage.NoiseRan(repi, i) = W.is_between(mean(sp.NoiseRan(:,:,i),'all'), [tstat.stats.ci_low.NoiseRan(i) tstat.stats.ci_high.NoiseRan(i)]);
        coverage.NoiseDet(repi, i) = W.is_between(mean(sp.NoiseDet(:,:,i),'all'), [tstat.stats.ci_low.NoiseDet(i) tstat.stats.ci_high.NoiseDet(i)]);
    end
    recovered.NoiseRan(repi,:) = tstat.stats.mean.NoiseRan;
    recovered.NoiseDet(repi,:) = tstat.stats.mean.NoiseDet;
end
%% hyper prior recovery
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
plt.figure(2,3, 'is_title', 1);
names = ["NoiseRan", "NoiseDet"];
xbins = -10:0.02:50;
color = {{'AZred','AZred'},{'AZblue','AZblue'}};
plt.setfig([1 4 2 5 3 6], 'xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15, 0:4:50,-3:3:15});
plt.setfig([1 4 2 5 3 6], 'xlim', {[-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1], [-3 8 + 1 *4]});
plt.setfig_all('ylim', [0 1.2], 'legend', {'fitted posterior mean', 'true posterior'});
plt.setfig('legloc',{'NE','NW','NE','NE','NW','NE'})
plt.setfig([1:3],'xlabel','random noise', 'ylabel', 'histogram/posterior', ...
    'title', {'H = 1', 'H = 6', '\Delta noise'});
plt.setfig([4:6],'xlabel','deterministic noise', 'ylabel', 'histogram/posterior', ...
    'title', {'', '', ''});
for i = 1:2
    for h = 1:2
        plt.ax(i*3-3+h);
        [tl, tm] = hist(recovered.(names(i))(:,h));
        tl = tl./max(tl);
        plt.plot(tm, tl,[],'bar', 'color', strcat(color{i}{h},'50'));
        tsp = sp.(names(i))(:,:,h);
        [tl,tm] = W.JAGS_density(tsp, xbins);
        tl = tl./max(tl);
        plt.plot(tm, tl,[],'line', 'color', color{i}{h});
        plt.dashY(mean(tsp,'all'), [0 1.2], 'color', color{i}{h});
    end
    
    plt.ax(i*3);
    [tl, tm] = hist(recovered.(strcat('d',names(i))));
    tl = tl./max(tl);
    plt.plot(tm, tl,[],'bar', 'color', 'gray');
    tsp = sp.(strcat('d',names(i)));
    [tl,tm] = W.JAGS_density(tsp, xbins);
    tl = tl./max(tl);
    plt.plot(tm, tl,[],'line', 'color', 'black');
    plt.dashY(mean(tsp,'all'), [0 1.2],'color', 'black');
end
plt.update('parameterrecovery_hyperprior');
%%

%     simunum = num2str(i);
%     plt.setup_W_plt('fig_dir', fullfile(figdir,'parameter_recovery'),...
%         'fig_suffix', [simunum],'fig_projectname', ['RanDetNoise' vv],...
%         'isshow', true);
%     sp2 = load(fullfile(outputdir, ['HBI_DetRanNoise_fitmodel_A_samples.mat'])).samples;
%     plt = EEplot_2noise_parameter_recovery_hyperprior(plt, sp, sp2);