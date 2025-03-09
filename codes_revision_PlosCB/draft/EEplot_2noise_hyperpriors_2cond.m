function EEplot_2noise_hyperpriors_2cond(plt, sp, stepsize)
    if ~exist('stepsize', 'var')
        stepsize = [0.02, 0.02];
    end
    names = {'Random noise - \sigma_{ran}',{'Change in random noise - \sigma_{ran}'},...
        'Deterministic noise - \sigma_{det}',{'Change in deterministic noise - \sigma_{det}'}};
    plt.setfig_all('ylabel', 'posterior density', ...
        'ytick', []);
%     plt.setfig('xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15});
    color = {{'AZred50','AZred'},{'AZblue50','AZblue'}};
    fns = {'NoiseRan', 'NoiseDet'};
    plt.setfig('legend', {{'h = 1, [1 3]','h = 1, [2 2]','h = 6, [1 3]','h = 6, [2 2]'},{'change, [1 3]', 'change, [2 2]'},...
        {'h = 1, [1 3]','h = 1, [2 2]','h = 6, [1 3]','h = 6, [2 2]'},{'change, [1 3]', 'change, [2 2]'}},...
        'xlabel', {'','','noise standard deviation [points]', 'noise standard deviation [points]'}, ...
        'title', names);
    for i = 1:2
        xbins = [-10:stepsize(i):30];
        fn = fns{i};
        plt.ax(i*2-1);
        td = sp.(fn);
        for hi = 1:2
            tm = []; tl = [];
            for j = 1:2
                [tl(j,:), tm(j,:)] = W.JAGS_density(td(:,:,hi, j), xbins);
            end
            plt.plot(tm, tl, [], 'line', 'color', {color{1}{hi}, color{2}{hi}});
        end
        hold on;
        ylm = get(gca,'ylim');
        plot([0 0],ylm, '--k','LineWidth', plt.param_plt.linewidth/2);
        hold off;
        
        plt.ax(i*2);
        td = sp.(['d' fn]);
        tm = []; tl = [];
        for j = 1:2
            [tl(j,:), tm(j,:)] = W.JAGS_density(td(:,:,j), xbins);
        end
        plt.plot(tm, tl, [], 'line', 'color', {'AZred', 'AZblue'});
        hold on;
%         ylm = get(gca,'ylim');
        plot([0 0],ylm, '--k','LineWidth', plt.param_plt.linewidth/2);
        hold off;
    end
    plt.update('hyperprior');
end
