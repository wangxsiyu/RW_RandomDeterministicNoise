function plt = EEplot_2noise_reduced(plt, sp)
names = {'Random noise - \sigma_{ran}','Deterministic noise - \sigma_{det}'};

ymax = 2.5;
plt.figure(length(sp),2,'istitle',1);
plt.setup_pltparams('fontsize_leg', 20, 'linewidth', 2);
plt.setfig('ylim', [0 ymax], ...
    'ytick', [0:0.5:ymax]);
color = {'AZblue','AZred'};
fns = {'NoiseRan', 'NoiseDet'};
stepsize = 0.02;
xbins = [-10:stepsize:30];
plt.setfig(1:2, 'title', names);
plt.setfig([-1 0] + length(sp)*2, 'xlabel', {'noise standard deviation [points]', 'noise standard deviation [points]'});
plt.setfig('color', color, 'legend', {'h = 1','h = 6'}, 'legloc', 'NorthEast');
for spi = 1:length(sp)
    if spi > 3
        xbins = [-10:stepsize:150];
    end
    for i = 1:2
        fn = fns{i};
        plt.new;
        for hi = 1:2
            td = sp{spi}.(fn);
            td = squeeze(td(:,:,hi));
            td = reshape(td, 1, []);
            tl = hist(td, xbins)/(length(td)*stepsize);
            plt.lineplot(tl, [], xbins);
        end
        hold on;
        plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
        hold off;
    end
end
plt.update;
plt.save('reduced_model');
end