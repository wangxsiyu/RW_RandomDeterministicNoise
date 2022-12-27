function plt = EEplot_plm(plt, gp, islm13)
    if ~exist('islm13', 'var') || isempty(islm13)
        islm13 = 0;
    end
    plt.setfig_ax('xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6], ...
        'xlabel', 'horizon', 'ylabel', 'p(low mean)', 'legloc', 'NW', ...
        'title', 'random exploration');
    if islm13
        plt.plot(1:2, gp.GPav_p_lm13, gp.GPste_p_lm13,'line', 'color', {'AZcactus'});
        plt.sigstar_y(gp.GPav_p_lm13, 1:2, gp.GPpvalue_p_lm13, 'left');
    end
    plt.plot(1:2, gp.GPav_p_lm22, gp.GPste_p_lm22,'line', 'color', {'AZsand'});
    plt.sigstar_y(gp.GPav_p_lm22, 1:2, gp.GPpvalue_p_lm22, 'right');
end