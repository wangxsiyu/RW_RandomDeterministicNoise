function EEplot_2noise_hyperpriors_2cond(plt, sp, stepsize)
    if ~exist('stepsize', 'var')
        stepsize = [0.02, 0.02];
    end
    names = {'Random noise - \sigma_{ran} [1 3]',{'Change in random noise - \sigma_{ran} [1 3]'},...
        'Deterministic noise - \sigma_{det} [1 3]',{'Change in deterministic noise - \sigma_{det} [1 3]'}, ...
        'Random noise - \sigma_{ran} [2 2]',{'Change in random noise - \sigma_{ran} [2 2]'},...
        'Deterministic noise - \sigma_{det} [2 2]',{'Change in deterministic noise - \sigma_{det} [2 2]'}};
    plt.setfig_all('ylabel', 'posterior density', ...
        'ytick', []);
    % plt.setfig('xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15});
    color = {{'AZred50','AZred'},{'AZblue50','AZblue'}};
    fns = {'NoiseRan', 'NoiseDet'};
    plt.setfig('legend', {{'h = 1','h = 6'},{'change'},{'h = 1','h = 6'},{'change'},{'h = 1','h = 6'},{'change'},{'h = 1','h = 6'},{'change'}},...
        'xlabel', {'','','','','','','noise standard deviation [points]', 'noise standard deviation [points]'}, ...
        'title', names);
    for ci = 1:2
        for i = 1:2
            xbins = [-10:stepsize(i):50];
            fn = fns{i};
            plt.ax(ci * 2 + i - 2, 1);
            td = sp.(fn);
            for hi = 1:2
                [tl, tm] = W.JAGS_density(td(:,:,hi, ci), xbins);
                plt.plot(tm, tl, [], 'line', 'color', color{i}{hi});
            end
            hold on;
            ylm = get(gca,'ylim');
            plot([0 0],ylm, '--k','LineWidth', plt.param_plt.linewidth/2);
            hold off;

            plt.ax(ci * 2 + i - 2, 2);
            td = sp.(['d' fn]);
            [tl, tm] = W.JAGS_density(td(:,:,ci), xbins);
            plt.plot(tm, tl, [], 'line', 'color', 'black');
            hold on;
            %         ylm = get(gca,'ylim');
            plot([0 0],ylm, '--k','LineWidth', plt.param_plt.linewidth/2);
            hold off;
        end
    end
    plt.update('hyperprior');
end
