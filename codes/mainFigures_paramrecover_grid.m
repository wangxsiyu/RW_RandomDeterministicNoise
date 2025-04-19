%% bayesian plots
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
%% Load data simugrid
griddir = '../bayesoutput/simugrid_infobias/';
sp = FigureLoad_gridsimu(griddir, 0:10);
sp2 = FigureLoad_gridsimu(griddir, [0:2:20]);
%% Figure simugrid
Figure_gridsimu_all(plt, sp, 0:10)
%% Pure Ran/Det
plt.figure(2,2,'is_title','all');
plt.setfig_all('ylim', [0 13]);
Figure_gridsimu_pureRanDet(plt, sp, 0:10)
%%
plt.set_pltsetting('savesfx', 'R20');
Figure_gridsimu_all(plt, sp2, 0:2:20)
%%
plt.figure(2,2,'is_title','all');
plt.setfig('ylim', {[0 25],[0 25],[0 13],[0 13]});
Figure_gridsimu_pureRanDet(plt, sp2, 0:2:20)
%%
%% Estimate over/under-estimation ratio
[gt_det, gt_ran] = meshgrid(0:10, 0:10);
gt = {gt_ran, gt_det};
overest = repmat({NaN(11,11)},1,2);
underest = overest;
for i = 1:2
    for x = 0:10
        for y = 0:10
            t_gt = gt{i}(x+1, y+1); % ground truth
            t_sp = sp2{i}{x+1, y+1};
            t_qt = quantile(t_sp,[0.025,0.975]); % quantile
            underest{i}(x+1, y+1) = max((t_gt - t_qt(1)), 0);
            overest{i}(x+1, y+1) = max((t_qt(2) - t_gt), 0);
        end
    end
end

% plt.figure(1,2);
% plt.ax(1);
% av1 = mean(underest{1},2)';
% a2 = max(underest{1},[],2)';
% a1 = min(underest{1},[],2)';
% av2 = mean(overest{1},2)';
% b2 = max(overest{1},[],2)';
% b1 = min(overest{1},[],2)';
% plt.plot(0:10, [av1;av2], )