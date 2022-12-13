function Figure_gridsimu_all(plt, rdsp)
%% all levels
W.library('tools_violin');
plt.figure(11,2, 'pixel_gap_h',13, 'pixel_h', 30, ...
    'is_xlabel', 1, 'param_scale', 2, ...
    'pixel_gap_w', 5, 'pixel_margin', [5 5 30 15]);
for i = 1:2
    for j = 1:11
        plt.ax(j,i);
        plt.setfig_ax('ylim', [j-3 j+1], 'ytick', j-1, 'xtick',[1:11]);
        if (j == 11)
            plt.setfig_ax('xticklabel', 0:10);
        else
            plt.setfig_ax('xticklabel',[]);
        end
        if j == 6
            plt.setfig_ax('ylabel', W.iif(i == 1, {'Posteriors of random noise'}, 'Posteriors of deterministic noise'));
        end
        if j == 11
            plt.setfig_ax('xlabel', W.iif(i == 1, 'simulated deterministic noise','simulated random noise'));
        end
        if j == 1
            plt.setfig_ax('title', W.iif(i == 1, 'Random noise','Deterministic noise'));
        end
        if i == 1
            ddd = [rdsp{i}(j,:)];
        else
            ddd = [rdsp{i}(:,j)'];
        end
        tcol = W.iif(i ==1, 'AZred', 'AZblue');
        tcol = plt.str2color(tcol);
        violin(ddd, 'medc',[],'plotlegend','','facecolor', tcol);
        hold on;
        plt.dashX(j-1)
    end
end
plt.update('parameterrecovery_gridsimu_all', 'AB                                                     ');
end