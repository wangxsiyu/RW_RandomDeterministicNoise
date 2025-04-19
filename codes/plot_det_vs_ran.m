function plt = plot_det_vs_ran(plt, st1, st2)
    plt.figure(2,2, 'is_title', 'all', 'gapW_custom', [2 0 0]);
    % cond = {'[1 3]', '[2 2]'};

    % ylab = {'H = 1', 'H = 6'};
    % for i = 1:2
    %     d0 = reshape(st1.NoiseDet_sub(i,:),1, []);
    %     r0 = reshape(st1.NoiseRan_sub(i,:),1, []);
    %     d1 = reshape(st2.NoiseDet_sub(i,:),1, []);
    %     r1 = reshape(st2.NoiseRan_sub(i,:),1, []);
    % 
    % 
    %     plt.ax(1+(i-1)*2,1);
    %     str = plt.scatter(r0, r1, 'diag');
    %     plt.setfig_ax('xlabel', 'Simulated Random', 'ylabel', {ylab{i},'Recovered Random'}, 'title', str);
    %     plt.ax(1+(i-1)*2, 2);
    %     str = plt.scatter(r0, d1, 'corr');
    %     plt.setfig_ax('xlabel', 'Simulated Random', 'ylabel', 'Recovered Deterministic', 'title', str);
    %     plt.ax(2+(i-1)*2,1);
    %     str = plt.scatter(d0, r1, 'corr');
    %     plt.setfig_ax('xlabel', 'Simulated Deterministic', 'ylabel', {ylab{i},'Recovered Random'}, 'title', str);
    %     plt.ax(2+(i-1)*2,2);
    %     str = plt.scatter(d0, d1, 'diag');
    %     plt.setfig_ax('xlabel', 'Simulated Deterministic', 'ylabel', 'Recovered Deterministic', 'title', str);
    %     % plt.ax(1+(i-1)*2,3);
    %     % str = plt.scatter(r0, d0, 'corr');
    %     % plt.setfig_ax('xlabel', 'Simulated Random', 'ylabel', 'Simulated Deterministic', 'title', str);
    %     % plt.ax(2+(i-1)*2,3);
    %     % str = plt.scatter(r1, d1, 'corr');
    %     % plt.setfig_ax('xlabel', 'Recovered Random', 'ylabel', 'Recovered Deterministic', 'title', str);
    % end


        d0 = reshape(st1.NoiseDet_sub(:),1, []);
        r0 = reshape(st1.NoiseRan_sub(:),1, []);
        d1 = reshape(st2.NoiseDet_sub(:),1, []);
        r1 = reshape(st2.NoiseRan_sub(:),1, []);

        i = 1;
        plt.ax(1+(i-1)*2,1);
        str = plt.scatter(r0, r1, 'diag');
        plt.setfig_ax('xlabel', 'Simulated Random', 'ylabel', {'Recovered Random'}, 'title', str);
        plt.ax(1+(i-1)*2, 2);
        str = plt.scatter(r0, d1, 'corr');
        plt.setfig_ax('xlabel', 'Simulated Random', 'ylabel', 'Recovered Deterministic', 'title', str);
        plt.ax(2+(i-1)*2,1);
        str = plt.scatter(d0, r1, 'corr');
        plt.setfig_ax('xlabel', 'Simulated Deterministic', 'ylabel', {'Recovered Random'}, 'title', str);
        plt.ax(2+(i-1)*2,2);
        str = plt.scatter(d0, d1, 'diag');
        plt.setfig_ax('xlabel', 'Simulated Deterministic', 'ylabel', 'Recovered Deterministic', 'title', str);
        % plt.ax(1+(i-1)*2,3);
        % str = plt.scatter(r0, d0, 'corr');
        % plt.setfig_ax('xlabel', 'Simulated Random', 'ylabel', 'Simulated Deterministic', 'title', str);
        % plt.ax(2+(i-1)*2,3);
        % str = plt.scatter(r1, d1, 'corr');
        % plt.setfig_ax('xlabel', 'Recovered Random', 'ylabel', 'Recovered Deterministic', 'title', str);

    
    plt.update('shuffled_recovery');
end
    % for ci = 1:2
    %     for hi = 1:2
    %         plt.ax(ci, hi);
    %         ylab = W.iif(hi == 1, {cond{ci}, 'Deterministic'}, {'Deterministic'});
    %         str = plt.scatter(squeeze(st1.NoiseRan_sub(ci, hi,:)), squeeze(st1.NoiseDet_sub(ci, hi,:)), 'corr');
    %         plt.setfig_ax('xlabel', 'Random', 'ylabel', ylab, 'title', sprintf('data, H = %d', hi), 'legend', str)
    % 
    %         plt.ax(ci, hi + 2);
    %         str = plt.scatter(squeeze(st2.NoiseRan_sub(ci, hi,:)), squeeze(st2.NoiseDet_sub(ci, hi,:)), 'corr');
    %         plt.setfig_ax('xlabel', 'Random', 'ylabel', 'Deterministic', 'title', sprintf('shuffled, H = %d', hi), 'legend', str)
    %     end
    % end