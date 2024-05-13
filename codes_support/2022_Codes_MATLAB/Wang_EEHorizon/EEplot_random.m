function plt = EEplot_random(plt, gp, col22, statside22)
    if ~exist('col22', 'var') || isempty(col22)
        col22 = {'AZsand'};
    end
    if ~exist('statside22', 'var') || isempty(statside22)
        statside22 = 'right';
    end
    plt.setfig_ax('xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6], ...
        'xlabel', 'horizon', 'ylabel', 'decision noise', 'legloc', 'NW');
    plt.plot(1:2, gp.GPav_MLE_noise, gp.GPste_MLE_noise,'line', 'color', col22);
    plt.sigstar_y(gp.GPav_MLE_noise, 1:2, gp.GPpvalue_MLE_noise, statside22);
end