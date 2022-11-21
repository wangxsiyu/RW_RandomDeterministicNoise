function plt = EEplot_2noise_parameter_recovery_hyperprior(plt, sp, sp2)
names = {'Random noise - \sigma_{ran}','Random noise - \sigma_{ran}',...
    'Deterministic noise - \sigma_{det}','Deterministic noise - \sigma_{det}'};
plt.figure(2,2,'title');
plt.setup_pltparams('fontsize_leg', 20, 'linewidth', 2);
plt.setfig('xlim', {[-1 22],[-3 12], [-1 22], [-3 12]}, 'ylim', [0 1.2], ...
    'ytick', [0:0.2:1.2], 'xtick',{0:4:20,-3:3:12,0:4:20,-3:3:12});
color = {{'AZblue','AZblue50','AZred','AZred50'},{'black','black50'}, ...
    {'AZblue','AZblue50','AZred','AZred50'},{'black','black50'}};
fns = {'NoiseRan', 'NoiseDet'};
stepsize = 0.02;
xbins = [-10:stepsize:30];
lg1 = {'original, h = 1','recovered, h = 1','original, h = 6', 'recovered, h = 6'};
lg2 = {'original, change', 'recovered change'};
plt.setfig('color', color, 'legend', ...
    {lg1,lg2,lg1,lg2},...
    'ylabel', {'posterior density','','posterior density',''}, ...
    'xlabel', {'','','noise standard deviation [points]', 'noise standard deviation [points]'}, ...
    'title', names);
ymax = 1.2;
plt.param_fig.colordelete = 1;
for i = 1:2
    fn = fns{i};
    plt.new;
    for hi = 1:2
        td = sp.(fn);
        td = squeeze(td(:,:,hi));
        td = reshape(td, 1, []);
        tl = hist(td, xbins)/(length(td)*stepsize);
        plt.lineplot(tl, [], xbins);
        
        td = sp2.(fn);
        td = squeeze(td(:,:,hi));
        td = reshape(td, 1, []);
        tl = hist(td, xbins)/(length(td)*stepsize);
        plt.lineplot(tl, [], xbins);
    end
    hold on;
    plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
    hold off;
    
    plt.new;
    td = sp.(['d' fn]);
    td = reshape(td, 1, []);
    tl = hist(td, xbins)/(length(td)*stepsize);
    plt.lineplot(tl, [], xbins);
    td = sp2.(['d' fn]);
    td = reshape(td, 1, []);
    tl = hist(td, xbins)/(length(td)*stepsize);
    plt.lineplot(tl, [], xbins);
    hold on;
    plot([0 0],[0 ymax], '--k','LineWidth', plt.param_figsetting.linewidth/2);
    hold off;
end
plt.update;
plt.save('parameter_recovery_hyperprior');
end