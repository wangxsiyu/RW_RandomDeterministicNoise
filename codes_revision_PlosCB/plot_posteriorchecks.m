function plot_posteriorchecks(plt, gp, simugp)
    plt.figure(1,4,'is_title',1);
    plt.setfig('xlabel', [repmat({'horizon'},1,4)], ...
        'ylabel', [{'p(high info)', 'p(low mean)', 'p(inconsistent), [1 3]', 'p(inconsistent), [2 2]'}], ...
        'ylim', repmat({[0.35 0.65],[0 0.35],[0 0.45],[0 0.45]},1,1), ...
        'ytick', repmat({[0.4:0.1:0.6],[0:.1:0.3],[0:.1:0.5],[0:.1:0.5]},1,1));
    plt.setfig_all('xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6], ...
        'legloc', 'SE');

    tgp = simugp;
    plt.ax(1,1);
    plt.plot(1:2,tgp.GPav_p_hi13, tgp.GPste_p_hi13,'line','color','AZblue');
    plt.plot(1:2,gp.GPav_p_hi13, gp.GPste_p_hi13,'line','color','AZred');
    plt.setfig_ax('legend',{'model','data'});
    plt.ax(1,2);
    plt.plot(1:2,tgp.GPav_p_lm22, tgp.GPste_p_lm22,'line','color','AZblue');
    plt.plot(1:2,gp.GPav_p_lm22, gp.GPste_p_lm22,'line','color','AZred');
    plt.setfig_ax('legend',{'model','data'});
    plt.ax(1,3);
    plt.plot(1:2,tgp.GPav_p_inconsistent13_randomtheory_byR, tgp.GPste_p_inconsistent13_randomtheory_byR,'line', 'color', 'AZblue50','linestyle','--');
    plt.plot(1:2,tgp.GPav_p_inconsistent13, tgp.GPste_p_inconsistent13,'line', 'color', 'AZblue');
    plt.plot(1:2,gp.GPav_p_inconsistent13, gp.GPste_p_inconsistent13,'line', 'color', 'AZred');
    %         plt.plot(1:2,gp.GPav_p_inconsistent13_randomtheory_byR, gp.GPste_p_inconsistent13_randomtheory_byR,'line', 'color', 'AZred50','linestyle','--');
    plt.setfig_ax('legend',{'\sigma^{ran} only','model','data'});
    %         plt.setfig_ax('legend',{'data','model'});

    plt.ax(1,4);
    plt.plot(1:2,tgp.GPav_p_inconsistent22_randomtheory_byR, tgp.GPste_p_inconsistent22_randomtheory_byR,'line', 'color', 'AZblue50','linestyle','--');
    plt.plot(1:2,tgp.GPav_p_inconsistent22, tgp.GPste_p_inconsistent22,'line', 'color', 'AZblue');
    plt.plot(1:2,gp.GPav_p_inconsistent22, gp.GPste_p_inconsistent22,'line', 'color', 'AZred')
    %         plt.plot(1:2,gp.GPav_p_inconsistent22_randomtheory_byR, gp.GPste_p_inconsistent22_randomtheory_byR,'line', 'color', 'AZred50','linestyle','--');
    plt.setfig_ax('legend',{'\sigma^{ran} only','model','data'});
    %         plt.setfig_ax('legend',{'data','model'});
    plt.update();
end