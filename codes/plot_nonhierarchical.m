function plt = plot_nonhierarchical(plt, st1, st2, option, ax, tlt)
    % if option == 1
    %     plt.figure(2,2, 'is_title', 'all');
    %     for hi = 1:2
    %         plt.ax(1, hi);
    %         ylab = {'recovered'};
    %             tx = squeeze(st1.NoiseRan_sub(hi,:));
    %             ty = squeeze(st2.NoiseRan_sub(hi,:));
    %             str = plt.scatter(tx, ty, 'diag');
    %         plt.setfig_ax('xlabel', 'simulated', 'ylabel', ylab, 'title', sprintf('Ran, H = %d, %.2f', hi, mean(tx < ty)), 'legend', str)
    % 
    %         plt.ax(2, hi);
    %             tx = squeeze(st1.NoiseDet_sub(hi,:));
    %             ty = squeeze(st2.NoiseDet_sub(hi,:));
    %             str = plt.scatter(tx, ty, 'diag');
    %         plt.setfig_ax('xlabel', 'simulated', 'ylabel', 'recovered', 'title', sprintf('Det, H = %d, %.2f', hi, mean(tx < ty)), 'legend', str)
    %     end
    % elseif option == 2
    %     plt.figure(2,4, 'is_title', 'all');
    %     cond = {'[1 3]', '[2 2]'};
    %     for ci = 1:2
    %         for hi = 1:2
    %             plt.ax(ci, hi);
    %             ylab = W.iif(hi == 1, {cond{ci}, 'recovered'}, {'recovered'});
    %             tx = squeeze(st1.NoiseRan_sub(ci, hi,:));
    %             ty = squeeze(st2.NoiseRan_sub(ci, hi,:));
    %             str = plt.scatter(tx, ty, 'diag');
    %             plt.setfig_ax('xlabel', 'simulated', 'ylabel', ylab, 'title', sprintf('Ran, H = %d, %.2f', hi, mean(tx < ty)), 'legend', str)
    % 
    %             plt.ax(ci, hi + 2);
    %             tx = squeeze(st1.NoiseDet_sub(ci, hi,:));
    %             ty = squeeze(st2.NoiseDet_sub(ci, hi,:));
    %             str = plt.scatter(tx, ty, 'diag');
    %             plt.setfig_ax('xlabel', 'simulated', 'ylabel', 'recovered', 'title', sprintf('Det, H = %d, %.2f', hi, mean(tx < ty)), 'legend', str)
    %         end
    %     end
    % else
        plt.ax(ax(1));

        % plt.figure(1,1, 'is_title', 'all');
        ylab = {'Random', 'recovered'};
        tx = reshape(st1.NoiseRan_sub, 1, []);
        ty = reshape(st2.NoiseRan_sub, 1, []);
        str = plt.scatter(tx, ty, 'diag');
        plt.setfig_ax('xlabel', 'simulated', 'ylabel', ylab, 'title', tlt)
        plt.ax(ax(2));
        ylab = {'Deterministic','recovered'};
        tx = reshape(st1.NoiseDet_sub, 1, []);
        ty = reshape(st2.NoiseDet_sub, 1, []);
        str = plt.scatter(tx, ty, 'diag');
        plt.setfig_ax('xlabel', 'simulated', 'ylabel', ylab, 'title', tlt)

    % end
end