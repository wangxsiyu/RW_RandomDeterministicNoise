function EEplot_2noise_hyperpriors_6model(plt, sp)
    plt.figure(6,4, 'fontsize_label', 18, 'fontsize_leg',15, 'fontsize_axes',18, ...
        'gapH_custom', [0 0 0 0 0 0 10]);
    names = {'Random noise','\Delta Random noise',...
        'Deterministic noise','\Delta Deterministic noise'};
    plt.setfig_all('ytick', []);
    color = {{'AZred50','AZred'},{'black'},{'AZblue50','AZblue'},{'black'}};
    fns = {'NoiseRan', 'NoiseDet'};
    legs = {{'h = 1','h = 6'},{'change'},{'h = 1','h = 6'},{'change'}};
    ylabs = {'density','','',''};
    stepsize = 0.02;
    xbins = [-10:stepsize:30];
    plt.setfig(21:24, 'xlabel', {'\sigma_{ran}','\Delta \sigma_{ran}','\sigma_{det}','\Delta \sigma_{det}'});
    plt.setfig(1:4, 'title', names);
    fns = {'NoiseRan', 'NoiseDet'};
    for mi = 1:6
        for i = 1:length(fns)
            fn = fns{i};
            plt.ax(mi,i*2-2 + 1);
            tl = [];

            if ~isfield(sp{mi}, fn)
                tl(1,:) = zeros(1,length(xbins)-1);
                tm = W.bin_middle(xbins);
                tl(1,dsearchn(tm', 0)) = 1;
                tl(2,:) = tl(1,:); 
            else
                td = sp{mi}.(fn);
                sz = size(sp{mi}.(fn));
                if sz(end) == 2
                    for hi = 1:2
                        [tl(hi,:), tm] = W.JAGS_density(td(:,:,hi), xbins);
                    end
                else
                    [tl(1,:), tm] = W.JAGS_density(td, xbins);
                    tl(2,:) = tl(1,:);
                end
            end
            ymax = max(tl* 1.05,[],'all');
            plt.setfig_ax('ylim', [0 ymax], 'xtick', 0:5:40,'xlim', [0 20], ...
                'legend', legs{i*2 - 1}, 'ylabel', ylabs{i*2-1});
            plt.plot(tm, tl, [], 'line','color', color{i*2 -1});
            plt.ax(mi,i*2-2 +2);
            plt.setfig_ax('ylim', [0 ymax], 'xlim', [-3 15], ... 
                'legend', legs{i*2}, 'ylabel', ylabs{i*2});
            if isfield(sp{mi}, ['d' fn])
                td = sp{mi}.(['d' fn]);
                [tl, tm] = W.JAGS_density(td, xbins);
            else
                tl = zeros(1,length(xbins)-1);
                tm = W.bin_middle(xbins);
                tl(dsearchn(tm', 0)) = 1;
            end
            plt.plot(tm, tl, [], 'line','color', color{i*2});
            plt.dashY(0,[0,ymax]);
        end
    end
    plt.update('2noise_hyperpriors_6model');
end