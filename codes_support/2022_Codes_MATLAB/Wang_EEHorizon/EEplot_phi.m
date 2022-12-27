function plt = EEplot_phi(plt, gp)
    plt.setfig_ax('xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6], ...
        'xlabel', 'horizon', 'ylabel', 'p(high info)', 'legloc', 'NW', ...
        'title', 'directed exploration');
    plt.plot(1:2, gp.GPav_p_hi13, gp.GPste_p_hi13, 'line', 'color', {'AZcactus'});
    plt.sigstar_y(gp.GPav_p_hi13, 1:2, gp.GPpvalue_p_hi13, 'right');
end