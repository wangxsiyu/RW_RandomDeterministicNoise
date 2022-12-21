function EEplot_2noise_pinconsistent(plt, gp)
    plt.figure(1,2,'istitle',1);
    plt.setfig('color', {{'AZcactus', 'AZblue', 'AZred'}, {'AZsand', 'AZblue', 'AZred'}});
    plt.setfig('xlabel', 'horizon', 'ylabel', {'p(inconsistent)','p(inconsistent)'}, ...
        'title', {'[1 3] condition','[2 2] condition'}, 'legloc', {'SouthWest','SouthWest'}, ...
        'legend', {'behavioral data','deterministic noise only','random noise only'}, ...
        'xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6]);
    plt.param_fig.colordelete = 1;
    plt.new;
    plt.lineplot(gp.av_p_inconsistent13, gp.ste_p_inconsistent13);
    plt.lineplot([0 0], [0 0]);
    plt.lineplot(gp.av_p_inconsistent13_randomtheory, gp.ste_p_inconsistent13_randomtheory);
    plt.sigstar_y(gp.av_p_inconsistent13, 1:2, gp.pvalue_p_inconsistent13, 'right');
    plt.new;
    plt.lineplot(gp.av_p_inconsistent22, gp.ste_p_inconsistent22);
    plt.lineplot([0 0], [0 0]);
    plt.lineplot(gp.av_p_inconsistent22_randomtheory, gp.ste_p_inconsistent22_randomtheory);
    plt.sigstar_y(gp.av_p_inconsistent22, 1:2, gp.pvalue_p_inconsistent22, 'right');
    plt.update;
    plt.param_fig.colordelete = 0;
    plt.addABCs;
    plt.save('2noise');
end