function EEplot_2noise_parameter_recovery(plt, p1, p2)
    fns = {'Infobonus_sub', 'bias_sub', 'NoiseRan_sub', 'NoiseDet_sub'};
    plt.setfig('ylabel', {'Fit A','Fit A','Fit b','Fit b', ...
        'Fit \sigma^{ran}', 'Fit \sigma^{ran}', 'Fit \sigma^{det}', 'Fit \sigma^{det}'}, ...
        'xlabel', {'Simulated A','Simulated A','Simulated b','Simulated b', ...
        'Simulated \sigma^{ran}', 'Simulated \sigma^{ran}', 'Simulated \sigma^{det}', 'Simulated \sigma^{det}'}, ...
        'title', {'H = 1', 'H = 6', '','','','','',''});
    plt.setfig_all('legloc', 'NW');
    for i = 1:4
        fn = fns{i};
        for hi = 1:2
            plt.ax(i, hi);
            d1 = W.arrayfun(@(x)x.(fn)(hi,:), p1, false);
            d2 = W.arrayfun(@(x)x.(fn)(hi,:), p2, false);
            d1 = [d1{:}];
            d2 = [d2{:}];
            str{i*2-2+hi} = plt.scatter(d1', d2', 'diag');
%             lsline
        end
    end
    plt.setfig('legend', str);
%     plt.setfig('legend', strcat({'A', 'A','b','b',...
%         '\sigma_{ran}','\sigma_{ran}','\sigma_{det}','\sigma_{det}'}, ...
%         {', ',', ',', ',', ',', ',', ',', ',', '}, str));
    plt.update('parameterrecovery_subject');
end
