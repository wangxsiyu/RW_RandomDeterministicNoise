function Figure_gridsimu_all(plt, rdsp)
%% all levels
W.library('tools_violin');
plt.figure(11,2);
for i = 1:2
    for j = 1:11
        plt.ax(j,i);
        plt.setfig_ax('ylim', [j-3 j+1], 'ytick', j-1,...
            'xtick',[1:11], 'xticklabel', 0:10);
        if j == 6
            plt.setfig_ax('ylabel', W.iif(i == 1, {'fit random noise'}, 'fit deterministic noise'));
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
        plt.setfig_ax('color', 'AZsand');
        plt.lineplot(ones(1,13)* (j-1), [],0:12,'-');
    end
end
plt.update('parameterrecovery_gridsimu_all');
end