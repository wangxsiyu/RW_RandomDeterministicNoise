function Figure_gridsimu_pureRanDet(plt, sp, rans)
    plt.setfig('ylabel', {'Random noise only', '','Deterministic noise only',''}, ...
        'xlabel', {'true random noise','true random noise','true deterministic noise','true deterministic noise'});
    plt.setfig_all('xtick',[1:11], 'legloc', 'NW', ...
        'legend', {'model','truth'});
    plt.ax(1);
    plt.setfig_ax('title',{'fit random noise'});
    ttt = violin([sp{1}(:,1)'],'medc',[],'plotlegend','','facecolor', plt.str2color('AZred'));
    plt.fig.object_list{1}(end+1) = ttt(1);
    hold on;
    plt.plot(1:11,rans, [], 'line', 'linestyle', '*', 'color', plt.str2color('AZsand'));
    plt.setfig_ax('xticklabel', rans);
    plt.ax(2);
    plt.setfig_ax('title',{'fit deterministic noise'});
    ttt = violin([sp{2}(:,1)'],'medc',[],'plotlegend','','facecolor', plt.str2color('AZblue'));
    plt.fig.object_list{2}(end+1) = ttt(1);
    hold on;
    plt.plot(1:11,zeros(1,11), [],'line', 'linestyle', '*', 'color', plt.str2color('AZsand'));
    plt.setfig_ax('xticklabel', rans);
    
    plt.ax(3);
    plt.setfig_ax('title',{'fit random noise'});
    ttt = violin([sp{1}(1,:)],'medc',[],'plotlegend','','facecolor', plt.str2color('AZred'));
    plt.fig.object_list{3}(end+1) = ttt(1);
    hold on;
    plt.plot(1:11,zeros(1,11), [],'line', 'linestyle', '*', 'color', plt.str2color('AZsand'));
    plt.setfig_ax('xticklabel', 0:10);
    plt.ax(4);
    plt.setfig_ax('title',{'fit deterministic noise'});
    ttt = violin([sp{2}(1,:)],'medc',[],'plotlegend','','facecolor', plt.str2color('AZblue'));
    plt.fig.object_list{4}(end+1) = ttt(1);
    hold on;
    plt.plot(1:11,0:10, [],'line', 'linestyle', '*', 'color', plt.str2color('AZsand'));
    plt.setfig_ax('xticklabel', 0:10);
    plt.update('parameterrecovery_grid_pureRanDet');
end