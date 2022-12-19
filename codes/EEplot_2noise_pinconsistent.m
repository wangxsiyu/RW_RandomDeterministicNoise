function plt = EEplot_2noise_pinconsistent(plt, gp, ver13, ver22, strpfx)
    if ~exist('ver13', 'var') || isempty(ver13)
        ver13 = '';
    end
    if ~exist('ver22', 'var') || isempty(ver22)
        ver22 = '';
    end
    if ~exist('strpfx', 'var') || isempty(strpfx)
        strpfx = '';
    end
    leg = {'behavioral data','deterministic noise only','random noise only'};
    plt.setfig('xlabel', {'horizon','horizon'}, 'ylabel', {'p(inconsistent)','p(inconsistent)'}, ...
        'title', {'[1 3] condition','[2 2] condition'}, 'legloc', {'SW','SW'}, ...
        'legend', {leg,leg}, ...
        'xlim', {[0.5 2.5],[0.5 2.5]}, 'xtick', {[1 2],[1 2]}, 'xticklabel', {[1 6],[1 6]});
    plt.plot(1:2,gp.([strpfx 'GPav_p_inconsistent13']), gp.([strpfx 'GPste_p_inconsistent13']), 'line', ...
        'color', 'AZcactus');
    plt.plot(1:2,[0 0], [0 0],'line', 'color', 'AZblue');
    plt.plot(1:2,gp.([strpfx 'GPav_p_inconsistent13_randomtheory' ver13]), ...
        gp.([strpfx 'GPste_p_inconsistent13_randomtheory' ver13]),'line', 'color', 'AZred');
    plt.sigstar_y(gp.([strpfx 'GPav_p_inconsistent13']), 1:2, gp.([strpfx 'GPpvalue_p_inconsistent13']), 'right');
    plt.new;
    plt.plot(1:2,gp.([strpfx 'GPav_p_inconsistent22']), gp.([strpfx 'GPste_p_inconsistent22']),'line', ...
        'color', 'AZsand');
    plt.plot(1:2,[0 0], [0 0],'line', 'color', 'AZblue');
    plt.plot(1:2,gp.([strpfx 'GPav_p_inconsistent22_randomtheory' ver22]), ...
        gp.([strpfx 'GPste_p_inconsistent22_randomtheory' ver22]),'line', 'color', 'AZred');
    plt.sigstar_y(gp.([strpfx 'GPav_p_inconsistent22']), 1:2, gp.([strpfx 'GPpvalue_p_inconsistent22']), 'right');
    try
        W.print('det13: %g,%g, t:%g,%g', gp.([strpfx 'GPpvalue_p_inconsistent13_vs0']), gp.([strpfx 'GPtstat_p_inconsistent13_vs0']));
        W.print('det22: %g,%g, t:%g,%g', gp.([strpfx 'GPpvalue_p_inconsistent22_vs0']), gp.([strpfx 'GPtstat_p_inconsistent22_vs0']));
        W.print('ran13: %g,%g, t:%g,%g', gp.([strpfx 'GPpvalue_p_inconsistent13_vs_p_inconsistent13_randomtheory' ver13]), gp.([strpfx 'GPtstat_p_inconsistent13_vs_p_inconsistent13_randomtheory' ver13]));
        W.print('ran22: %g,%g, t:%g,%g', gp.([strpfx 'GPpvalue_p_inconsistent22_vs_p_inconsistent22_randomtheory' ver22]), gp.([strpfx 'GPtstat_p_inconsistent22_vs_p_inconsistent22_randomtheory' ver22]));
    end
    plt.update('pinconsistent');
end