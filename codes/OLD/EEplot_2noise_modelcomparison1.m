function EEplot_2noise_modelcomparison1(plt, gp, simugp)
    plt.figure(1,4,'istitle',1,'rect', [0 0.1 0.95 0.5],...
        'margin', [0.2, 0.06, 0.1, 0.07],'gap',[0.08 0.08]);
%     pltsetparams('fontsize_face', 20, 'fontsize_leg', 15, 'linewidth', 2);
%     plt_setparams('fontsize_leg', 20, 'linewidth', 2);
    plt.setfig('color', {'AZred', 'AZblue'});
    plt.setfig('xlabel', [repmat({'horizon'},1,4)], ...
        'ylabel', [{'p(high info)', 'p(low mean)', 'p(inconsistent), [1 3]', 'p(inconsistent), [2 2]'}], ...
        'xlim', [0.5 2.5], 'xtick', [1 2], 'xticklabel', [1 6], ...
        'legend', [repmat({{'',''}},1,3), {{'data', 'model'}}], ...
        'legloc', 'northeastoutside', ...
        'ylim', repmat({[0.35 0.65],[0 0.35],[0 0.45],[0 0.45]},1,1), ...
        'ytick', repmat({[0.4:0.1:0.6],[0:.1:0.3],[0:.1:0.5],[0:.1:0.5]},1,1));
    for mi = 1:1
        tgp = simugp.(['model' char(64+mi)]);
        plt.new;
        plt.lineplot(gp.av_p_hi13, gp.ste_p_hi13);
        plt.lineplot(tgp.av_p_hi13, tgp.ste_p_hi13);
        
        plt.new;
        plt.lineplot(gp.av_p_lm22, gp.ste_p_lm22);
        plt.lineplot(tgp.av_p_lm22, tgp.ste_p_lm22);
        
        plt.new;
        plt.lineplot(gp.av_p_inconsistent13, gp.ste_p_inconsistent13);
        plt.lineplot(tgp.av_p_inconsistent13, tgp.ste_p_inconsistent13);
        
        plt.new;
        plt.lineplot(gp.av_p_inconsistent22, gp.ste_p_inconsistent22);
        plt.lineplot(tgp.av_p_inconsistent22, tgp.ste_p_inconsistent22);
    end
    plt.addABCs([-0.01 0.07]);
    plt.update;
    
    plt.save('2noise_modelqualitative');
end