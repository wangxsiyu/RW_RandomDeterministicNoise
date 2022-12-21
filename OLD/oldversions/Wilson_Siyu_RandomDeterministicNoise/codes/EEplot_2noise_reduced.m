function plt = EEplot_2noise_reduced(plt, sp)
names = {'Random noise - \sigma_{ran}','Deterministic noise - \sigma_{det}'};
plt.setfig_loc('ylabel', {'horizon = 1','','horizon = 6',''}, ...
    'xlim',{[0 20],[0 10],[0 20],[0 10]});
ymax = 2.5;
plt.figure(2,2,'istitle',1,'gap',[0.07 0.07]);
plt.setup_pltparams('fontsize_leg', 20, 'linewidth', 2,'fontsize_face',20);
plt.setfig('ylim', [0 ymax], ...
    'ytick', [0:0.5:ymax]);
color = {{'AZred50','AZred'},{'AZblue50','AZblue'},...
    {'AZred50','AZred'},{'AZblue50','AZblue'}};
fns = {'NoiseRan', 'NoiseDet'};
stepsize = 0.02;
xbins = [-10:stepsize:30];
plt.setfig(1:2, 'title', names);
plt.setfig([-1 0] + length(sp)*2, 'xlabel', {'noise standard deviation [points]', 'noise standard deviation [points]'});
plt.setfig('color', color, 'legend', {'reduced model','full model'}, 'legloc', 'NorthEast');
for hi = 1:2
    for i = 1:2
        fn = fns{i};
        plt.new;
        tl = [];
        for spi = 1:2
            td = sp{spi}.(fn);
            td = squeeze(td(:,:,hi));
            td = reshape(td, 1, []);
            tl(spi,:) = hist(td, xbins)/(length(td)*stepsize);
        end
        plt.lineplot(tl, [], xbins);
        hold on;
        plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
        hold off;
    end
end
plt.update;
plt.save('reduced_model');
end