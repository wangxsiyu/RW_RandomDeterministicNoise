function EEplot_2noise_parameter_recovery(plt, p1, p2, nplot)
    if ~exist('nplot', 'var') || isempty(nplot)
        nplot = 4;
    end
    fns = {'Infobonus_sub', 'bias_sub', 'NoiseRan_sub', 'NoiseDet_sub'};
    if nplot == 4
        plt.setfig('ylabel', {'Fit A','Fit A','Fit b','Fit b', ...
            'Fit \sigma^{ran}', 'Fit \sigma^{ran}', 'Fit \sigma^{det}', 'Fit \sigma^{det}'}, ...
            'xlabel', {'Simulated A','Simulated A','Simulated b','Simulated b', ...
            'Simulated \sigma^{ran}', 'Simulated \sigma^{ran}', 'Simulated \sigma^{det}', 'Simulated \sigma^{det}'}, ...
            'title', {'H = 1', 'H = 6', '','','','','',''});
        nplot = 1:4;
    elseif nplot == 2
        plt.setfig(1:4, 'ylabel', {'Fit \sigma^{ran}', 'Fit \sigma^{ran}', 'Fit \sigma^{det}', 'Fit \sigma^{det}'}, ...
            'xlabel', {'Simulated \sigma^{ran}', 'Simulated \sigma^{ran}', 'Simulated \sigma^{det}', 'Simulated \sigma^{det}'}, ...
            'title', {'H = 1', 'H = 6','',''});
        nplot = 3:4;
    end
    plt.setfig_all('legloc', 'NW');
    for i = 1:length(nplot)
        fn = fns{nplot(i)};
        for hi = 1:2
            plt.ax(i, hi);
            d1 = W.arrayfun(@(x)x.(fn)(hi,:), p1, false);
            d2 = W.arrayfun(@(x)x.(fn)(hi,:), p2, false);
            d1 = [d1{:}];
            d2 = [d2{:}];
            str = plt.scatter(d1', d2', 'diag'); %{i*2-2+hi}
            plt.setfig_ax('legend', str);
%             lsline
        end
    end
%     plt.setfig('legend', strcat({'A', 'A','b','b',...
%         '\sigma_{ran}','\sigma_{ran}','\sigma_{det}','\sigma_{det}'}, ...
%         {', ',', ',', ',', ',', ',', ',', ',', '}, str));
    plt.update('parameterrecovery_subject');
end
