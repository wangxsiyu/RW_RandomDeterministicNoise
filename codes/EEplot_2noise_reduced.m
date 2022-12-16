function plt = EEplot_2noise_reduced(plt, sp)
    plt.figure(2,2,'is_title',1,'gapW_custom',[10 0 0]);
    names = {'Random noise - \sigma_{ran}','Deterministic noise - \sigma_{det}'};
    plt.setfig('xlim', {[0 20],[0 10],[0 20],[0 10]}, ...
        'ylabel', {{'horizon = 1','Posterior density'},'Posterior density',{'horizon = 6','Posterior density'},'Posterior density'});
    ymax = 1;
    plt.setfig('ylim', {[0 ymax],[0 ymax],[0 0.7],[0 0.7]});
    plt.setfig_all('ytick', [0:0.2:ymax]);
    color = {{'AZred50','AZred'},{'AZblue50','AZblue'},...
        {'AZred50','AZred'},{'AZblue50','AZblue'}};
    fns = {'NoiseRan', 'NoiseDet'};
    stepsize = 0.02;
    xbins = [-10:stepsize:30];
    plt.setfig(1:2, 'title', names);
    plt.setfig([-1 0] + length(sp)*2, 'xlabel', {'noise standard deviation [points]', 'noise standard deviation [points]'});
    plt.setfig_all('legend', {'reduced model','full model'}, 'legloc', 'NE');
    for hi = 1:2
        for i = 1:2
            fn = fns{i};
            plt.ax(hi, i);
            tl = [];
            for spi = 1:2
                td = sp{spi}.(fn);
                [tl(spi,:), tm] = W.JAGS_density(td(:,:,hi), xbins);
            end
            plt.plot(tm, tl, [], 'line', 'color', color{hi*2-2+i});
%             plt.dashY(0, [0 ymax])
        end
    end
    plt.update('reduced_model');
end