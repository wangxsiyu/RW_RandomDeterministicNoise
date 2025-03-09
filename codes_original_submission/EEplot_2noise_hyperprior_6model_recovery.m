function EEplot_2noise_hyperprior_6model_recovery(plt, sp)
    plt.figure(6,4, 'fontsize_label', 18, 'fontsize_leg',15, 'fontsize_axes',18, 'fontsize_title', 20, ...
        'gapH_custom', [0 0 0 0 0 0 10]);
    names = {'Random noise','\Delta Random noise',...
        'Deterministic noise','\Delta Deterministic noise'};
    plt.setfig_all('ytick', []);
    color = {{'AZred50','AZred'},{'black'},{'AZblue50','AZblue'},{'black'}};
    fns = {'NoiseRan', 'NoiseDet'};
    legs = {{'h = 1','h = 6'},{'change'},{'h = 1','h = 6'},{'change'}};
    ylabs = {'density','','',''};
    stepsize = 0.02;
    xbins = [-10:stepsize:30];
    plt.setfig(21:24, 'xlabel', {'\sigma_{ran}','\Delta \sigma_{ran}','\sigma_{det}','\Delta \sigma_{det}'});
    plt.setfig(1:4, 'title', names);
    fns = {'NoiseRan', 'NoiseDet'};
    plt.setfig('ylabel', [{'\sigma^{ran}_{horizon}, \sigma^{det}_{horizon}'} repmat({''},1,3), {'\sigma^{ran}_{horizon}, \sigma^{det}_{}'} repmat({''},1,3), ...
        {'\sigma^{ran}_{}, \sigma^{det}_{horizon}'} repmat({''},1,3), {'\sigma^{ran}_{}, \sigma^{det}_{}'} repmat({''},1,3), ...
        {'\sigma^{ran}_{horizon}'} repmat({''},1,3), {'\sigma^{det}_{horizon}'} repmat({''},1,3)]);
    for mi = 1:6
        for i = 1:length(fns)
            fn = fns{i};
            plt.ax(mi, 2*i-2+1);
            tl = [];
            for hi = 1:2
                td = sp{mi}.(fn);
                [tl(hi,:), tm] = W.JAGS_density(td(:,:,hi), xbins);
            end
            ymax = max(tl* 1.05,[],'all');
            plt.setfig_ax('ylim', [0 ymax], 'xtick', 0:5:40,'xlim', [0 20], ...
                'legend', legs{i*2 - 1});
            plt.plot(tm, tl, [], 'line', 'color', color{i*2 -1});%, 'ylabel', ylabs{i*2-1});
            
            plt.ax(mi, 2*i-2+2);
            plt.setfig_ax('ylim', [0 ymax], 'xlim', [-3 15], ... 
                'legend', legs{i*2});%, 'ylabel', ylabs{i*2});
            td = sp{mi}.(['d' fn]);
            [tl, tm] = W.JAGS_density(td, xbins);
            plt.plot(tm, tl, [], 'line', 'color', color{i*2});
            plt.dashY(0, [0 ymax])
        end
    end
    plt.update('2noise_hyperprior_6model_recovery');
end