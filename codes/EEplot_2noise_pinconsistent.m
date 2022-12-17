function plt = EEplot_2noise_pinconsistent(plt, gp, ver)
    if ~exist('ver', 'var') || isempty(ver)
        ver = '';
    end
    leg = {'behavioral data','deterministic noise only','random noise only'};
    plt.setfig('xlabel', {'horizon','horizon'}, 'ylabel', {'p(inconsistent)','p(inconsistent)'}, ...
        'title', {'[1 3] condition','[2 2] condition'}, 'legloc', {'SW','SW'}, ...
        'legend', {leg,leg}, ...
        'xlim', {[0.5 2.5],[0.5 2.5]}, 'xtick', {[1 2],[1 2]}, 'xticklabel', {[1 6],[1 6]});
    plt.plot(1:2,gp.GPav_p_inconsistent13, gp.GPste_p_inconsistent13, 'line', ...
        'color', 'AZcactus');
    plt.plot(1:2,[0 0], [0 0],'line', 'color', 'AZblue');
    plt.plot(1:2,gp.(['GPav_p_inconsistent13_randomtheory' ver]), ...
        gp.(['GPste_p_inconsistent13_randomtheory' ver]),'line', 'color', 'AZred');
    plt.sigstar_y(gp.GPav_p_inconsistent13, 1:2, gp.GPpvalue_p_inconsistent13, 'right');
    plt.new;
    plt.plot(1:2,gp.GPav_p_inconsistent22, gp.GPste_p_inconsistent22,'line', ...
        'color', 'AZsand');
    plt.plot(1:2,[0 0], [0 0],'line', 'color', 'AZblue');
    plt.plot(1:2,gp.(['GPav_p_inconsistent22_randomtheory' ver]), ...
        gp.(['GPste_p_inconsistent22_randomtheory' ver]),'line', 'color', 'AZred');
    plt.sigstar_y(gp.GPav_p_inconsistent22, 1:2, gp.GPpvalue_p_inconsistent22, 'right');
    plt.update('pinconsistent');
end