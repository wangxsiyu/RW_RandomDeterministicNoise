function EEplot_2noise_hyperpriors(plt, sp)
    names = {'Random noise - \sigma_{ran}','Random noise - \sigma_{ran}',...
        'Deterministic noise - \sigma_{det}','Deterministic noise - \sigma_{det}'};
    plt.figure(2,2,'title');
    plt.setup_pltparams('fontsize_axes',15,'fontsize_leg', 15, ...
        'fontsize_face',25, 'linewidth', 2);
    plt.setfig('ylim', [0 1.2], ...
        'ytick', [], 'xtick',{0:4:20,-3:3:12,0:4:20,-3:3:12});
    color = {{'AZred50','AZred'},{'black'},{'AZblue50','AZblue'},{'black'}};
    fns = {'NoiseRan', 'NoiseDet'};
    stepsize = 0.02;
    xbins = [-10:stepsize:30];
    plt.param_fig.colordelete = 1;
    plt.setfig('color', color, 'legend', {{'h = 1','h = 6'},{'change'},{'h = 1','h = 6'},{'change'}},...
        'ylabel', {'posterior density','','posterior density',''}, ...
        'xlabel', {'','','noise standard deviation [points]', 'noise standard deviation [points]'}, ...
        'title', names);
    ymax = 1.2;
    for i = 1:2
        fn = fns{i};
        plt.new;
        for hi = 1:2
            td = sp.(fn);
            td = squeeze(td(:,:,hi));
            td = reshape(td, 1, []);
            tl = hist(td, xbins)/(length(td)*stepsize);
            plt.lineplot(tl, [], xbins);
        end
        hold on;
        plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
        hold off;
        
        plt.new;
        td = sp.(['d' fn]);
        td = reshape(td, 1, []);
        tl = hist(td, xbins)/(length(td)*stepsize);
        plt.lineplot(tl, [], xbins);
        hold on;
        plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
        hold off;
    end
    plt.param_fig.colordelete = 0;
    plt.update;
    plt.save('hyperprior');
end
