function plt = EEplot_2noise_PureRanDet(plt, sp, sp2)
names = {'Random noise only - \sigma_{ran}','','Deterministic noise only - \sigma_{det}',...
    ''};

ymax = 2.5;
plt.figure(2,2,'istitle',0);
plt.setup_pltparams('fontsize_leg', 20, 'linewidth', 2);
plt.setfig('xlim', {[-1 22],[-3 12], [-1 22], [-3 12]}, 'ylim', [0 ymax], ...
    'ytick', [0:0.5:ymax], 'xtick',{0:4:20,-3:3:12,0:4:20,-3:3:12});
color = {'AZblue','AZred'};
fns = {'NoiseRan', 'NoiseDet'};
stepsize = 0.02;
xbins = [-10:stepsize:30];
plt.setfig('color', color, 'legend', {'h = 1','h = 6'},...
    'title', {'Random noise - \sigma_{ran}','Deterministic noise - \sigma_{det}','',''}, ...
    'xlabel', {'','','noise standard deviation [points]', 'noise standard deviation [points]'}, ...
    'ylabel', names, 'legloc', 'NorthEast');
for i = 1:2
    fn = fns{i};
    plt.new;
    for hi = 1:2
        td = sp.(fn);
        td = squeeze(td(:,:,hi));
        td = reshape(td, 1, []);
        tl = hist(td, xbins)/(length(td)*stepsize);
        plt.lineplot(tl, [], xbins);
    end
    hold on;
    plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
    hold off;
end
for i = 1:2
    fn = fns{i};
    plt.new;
    for hi = 1:2
        td = sp2.(fn);
        td = squeeze(td(:,:,hi));
        td = reshape(td, 1, []);
        tl = hist(td, xbins)/(length(td)*stepsize);
        plt.lineplot(tl, [], xbins);
    end
    hold on;
    plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
    hold off;
end
plt.update;
plt.save(['pure_ran_det_simu_hyperprior']);
end