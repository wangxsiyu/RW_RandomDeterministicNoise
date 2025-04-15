function plt = EEplot_directed(plt, gp, cols, statside)
    if ~exist('cols', 'var') || isempty(cols)
        cols = {'AZcactus'};
    end
    if ~exist('statside', 'var') || isempty(statside)
        statside = 'right';
    end
    plt.setfig_ax('xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6], ...
        'xlabel', 'horizon', 'ylabel', 'information bonus', 'legloc', 'NW');
    plt.plot(1:2, gp.GPav_MLE2_infobonus, gp.GPste_MLE2_infobonus, 'line', 'color', cols);
    plt.sigstar_y(gp.GPav_MLE2_infobonus, 1:2, gp.GPpvalue_MLE2_infobonus, statside);
    % plt.plot(1:2, gp.GPav_MLE_infobonus, gp.GPste_MLE_infobonus, 'line', 'color', cols);
    % plt.sigstar_y(gp.GPav_MLE_infobonus, 1:2, gp.GPpvalue_MLE_infobonus, statside);
end