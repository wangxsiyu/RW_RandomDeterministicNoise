function EEplot_2noise_modelcomparison(plt, gp, simugp)
    plt.figure(6,4,'fontsize_label', 18, 'fontsize_leg',15, 'fontsize_axes',18, 'fontsize_title', 20, ...
        'gapH_custom', [10 0 0 0 0 0 10], 'gapW_custom', [10 0 0 0 0]);   
    plt.setfig('xlabel', [repmat({''},1,20), repmat({'horizon'},1,4)], ...
        'ylabel', [{'\sigma^{ran}_{horizon}, \sigma^{det}_{horizon}'} repmat({''},1,3), {'\sigma^{ran}_{horizon}, \sigma^{det}_{}'} repmat({''},1,3), ...
        {'\sigma^{ran}_{}, \sigma^{det}_{horizon}'} repmat({''},1,3), {'\sigma^{ran}_{}, \sigma^{det}_{}'} repmat({''},1,3), ...
        {'\sigma^{ran}_{horizon}'} repmat({''},1,3), {'\sigma^{det}_{horizon}'} repmat({''},1,3)], ...
        'title', [{'p(high info)', 'p(low mean)', 'p(inconsistent), [1 3]', 'p(inconsistent), [2 2]', ...
        } repmat({''}, 1, 20)], 'xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6], ...
        'ylim', repmat({[0.35 0.65],[0 0.35],[0 0.45],[0 0.45]},1,6), ...
        'ytick', repmat({[0.4:0.1:0.6],[0:.1:0.3],[0:.1:0.5],[0:.1:0.5]},1,6));
    plt.setfig_all('legloc', 'SE');
    for mi = 1:6
        tgp = simugp.(['model' char(64+mi)]);
        plt.ax(mi,1);
        plt.plot(1:2,gp.GPav_p_hi13, gp.GPste_p_hi13,'line','color','AZred');
        plt.plot(1:2,tgp.GPav_GPav_p_hi13, tgp.GPav_GPste_p_hi13,'line','color','AZblue');
        plt.setfig_ax('legend',{'data','model'});

        plt.ax(mi,2);
        plt.plot(1:2,gp.GPav_p_lm22, gp.GPste_p_lm22,'line','color','AZred');
        plt.plot(1:2,tgp.GPav_GPav_p_lm22, tgp.GPav_GPste_p_lm22,'line','color','AZblue');
        plt.setfig_ax('legend',{'data','model'});
        
        plt.ax(mi,3);
        plt.plot(1:2,gp.GPav_p_inconsistent13, gp.GPste_p_inconsistent13,'line', 'color', 'AZred');
%         plt.plot(1:2,gp.GPav_p_inconsistent13_randomtheory_byR, gp.GPste_p_inconsistent13_randomtheory_byR,'line', 'color', 'AZred50','linestyle','--');
        plt.plot(1:2,tgp.GPav_GPav_p_inconsistent13, tgp.GPav_GPste_p_inconsistent13,'line', 'color', 'AZblue');
        plt.plot(1:2,tgp.GPav_GPav_p_inconsistent13_randomtheory_byR, tgp.GPav_GPste_p_inconsistent13_randomtheory_byR,'line', 'color', 'AZblue50','linestyle','--');
        plt.setfig_ax('legend',{'data','model','\sigma^{ran} only'});
%         plt.setfig_ax('legend',{'data','model'});
        
        plt.ax(mi,4);
        plt.plot(1:2,gp.GPav_p_inconsistent22, gp.GPste_p_inconsistent22,'line', 'color', 'AZred')
%         plt.plot(1:2,gp.GPav_p_inconsistent22_randomtheory_byR, gp.GPste_p_inconsistent22_randomtheory_byR,'line', 'color', 'AZred50','linestyle','--');
        plt.plot(1:2,tgp.GPav_GPav_p_inconsistent22, tgp.GPav_GPste_p_inconsistent22,'line', 'color', 'AZblue');
        plt.plot(1:2,tgp.GPav_GPav_p_inconsistent22_randomtheory_byR, tgp.GPav_GPste_p_inconsistent22_randomtheory_byR,'line', 'color', 'AZblue50','linestyle','--');
        plt.setfig_ax('legend',{'data','model','\sigma^{ran} only'});
%         plt.setfig_ax('legend',{'data','model'});
    end
    plt.update('2noise_6modelcomparison');
end