function EEplot_2noise_hyperprior_6model(plt, sp)
    plt.figure(6,4);
    plt.setup_pltparams('fontsize_face', 20, 'fontsize_leg', 10, 'linewidth', 2);
    names = {'Random noise','\Delta Random noise',...
        'Deterministic noise','\Delta Deterministic noise'};
    plt.setfig('ytick', []);
    color = {{'AZred50','AZred'},{'black'},{'AZblue50','AZblue'},{'black'}};
    fns = {'NoiseRan', 'NoiseDet'};
    legs = {{'h = 1','h = 6'},{'change'},{'h = 1','h = 6'},{'change'}};
    ylabs = {'density','','',''};
    stepsize = 0.02;
    xbins = [-10:stepsize:30];
    plt.param_fig.colordelete = 1;
    plt.setfig(21:24, 'xlabel', {'\sigma_{ran}','\Delta \sigma_{ran}','\sigma_{det}','\Delta \sigma_{det}'});
    plt.setfig(1:4, 'title', names);
    fns = {'NoiseRan', 'NoiseDet'};
    for mi = 1:6
        for i = 1:length(fns)
            fn = fns{i};
            plt.new;
            tl = [];
            for hi = 1:2
                td = sp{mi}.(fn);
                td = squeeze(td(:,:,hi));
                td = reshape(td, 1, []);
                tl(hi,:) = hist(td, xbins)/(length(td)*stepsize);
            end
            ymax = max(tl* 1.05,[],'all');
            plt.setfig_ax('ylim', [0 ymax], 'xtick', 0:4:20,'xlim', [0 20], 'color', color{i*2 -1}, ...
                'legend', legs{i*2 - 1}, 'ylabel', ylabs{i*2-1});
            plt.lineplot(tl, [], xbins);
%             hold on;
%             plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
%             hold off;
            
            plt.new;
            plt.setfig_ax('ylim', [0 ymax], 'xlim', [-3 9], 'color', color{i*2}, ...
                'legend', legs{i*2}, 'ylabel', ylabs{i*2});
            td = sp{mi}.(['d' fn]);
            td = reshape(td, 1, []);
            tl = hist(td, xbins)/(length(td)*stepsize);
            plt.lineplot(tl, [], xbins);
            hold on;
            plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
            hold off;
        end
    end
    plt.update;
    plt.save('2noise_hyperprior_6model');
end