function plt = plot_det_vs_ran(plt, st1, st2)
    plt.figure(2,4, 'is_title', 'all');
    cond = {'[1 3]', '[2 2]'};
    for ci = 1:2
        for hi = 1:2
            plt.ax(ci, hi);
            ylab = W.iif(hi == 1, {cond{ci}, 'Deterministic'}, {'Deterministic'});
            str = plt.scatter(squeeze(st1.NoiseRan_sub(ci, hi,:)), squeeze(st1.NoiseDet_sub(ci, hi,:)), 'corr');
            plt.setfig_ax('xlabel', 'Random', 'ylabel', ylab, 'title', sprintf('data, H = %d', hi), 'legend', str)

            plt.ax(ci, hi + 2);
            str = plt.scatter(squeeze(st2.NoiseRan_sub(ci, hi,:)), squeeze(st2.NoiseDet_sub(ci, hi,:)), 'corr');
            plt.setfig_ax('xlabel', 'Random', 'ylabel', 'Deterministic', 'title', sprintf('shuffled, H = %d', hi), 'legend', str)
        end
    end
    plt.update;
end