%% setup
ver = 'all';
verout = 'all_50chains';
% verout = ver;
% ver = 'paironly';
outputdir = fullfile('../bayesoutput', verout);
figdir = fullfile('../figures', verout);
plt = W_plt;
plt.setup_W_plt('fig_dir', figdir, 'fig_suffix', '','fig_projectname', 'RanDetNoise');
vv = ''; vv2 = '';
%% parameter recovery
%% figures - parameter recovery
for i = 1:1
    simunum = num2str(i);
    plt.setup_W_plt('fig_dir', fullfile(figdir,'parameter_recovery'), ...
        'fig_suffix', simunum,'fig_projectname', ['RanDetNoise' vv], ...
        'isshow', false);
    p1 = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_stat.mat'])).stats.mean;
    p2 = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu' simunum '_stat.mat'])).stats.mean;
    mx = {[-25 25],[-25 25],[-3 3],[-3 3],[-1 20],[-1 30],[-1 5],[-1 15]};
    mxtick = {[-20:10:20],[-20:10:20],[-2:2:2],[-2:2:2],[0:5:30],[0:5:30],[0:5:30],[0:5:30]};
    plt.setfig(8, 'xtick', mxtick, ...
        'ytick', mxtick);
    plt.param_fig.islocked = 1;
    EEplot_2noise_parameter_recovery(plt, p1, p2);
end
%% figures - hyperprior recovery
for i = 1:1
    simunum = num2str(i);
    plt.setup_W_plt('fig_dir', fullfile(figdir,'parameter_recovery'),...
        'fig_suffix', [simunum],'fig_projectname', ['RanDetNoise' vv],...
        'isshow', false);
    sp = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_samples.mat'])).samples;
    sp2 = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu' simunum '_samples.mat'])).samples;
    plt = EEplot_2noise_parameter_recovery_hyperprior(plt, sp, sp2);
end
%% figures - hyperprior recovery (50 simulations)
for i = 1:1
    simunum = num2str(i);
    plt.setup_W_plt('fig_dir', fullfile(figdir,'parameter_recovery'),...
        'fig_suffix', [simunum],'fig_projectname', ['RanDetNoise' vv],...
        'isshow', true);
    sp = load(fullfile(outputdir, ['HBI_DetRanNoise_samples.mat'])).samples;
    sp2 = load(fullfile(outputdir, ['HBI_DetRanNoise_fitmodel_A_samples.mat'])).samples;
    plt = EEplot_2noise_parameter_recovery_hyperprior(plt, sp, sp2);
end
%% overall parameter recovery
fns = {'Infobonus_sub', 'bias_sub', 'NoiseRan_sub', 'NoiseDet_sub'};
temp = {};
for fi = 1:length(fns)
    temp{1}.(fns{fi}) = [];
    temp{2}.(fns{fi}) = [];
end
for i = 1:10
    simunum = num2str(i);
    te = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu' simunum '_stat.mat'])).stats.mean;
    for fi = 1:length(fns)
        for hi = 1:2
            temp{hi}.(fns{fi}) = vertcat(temp{hi}.(fns{fi}), te.(fns{fi})(hi,:));
        end
    end
end
p2 = [];
for fi = 1:length(fns)
    p2.(fns{fi}) = [mean(temp{1}.(fns{fi})); mean(temp{2}.(fns{fi}))];
end
plt.setup_W_plt('fig_dir', fullfile(figdir), ...
    'fig_suffix', 'paramrecovery','fig_projectname', ['RanDetNoise' vv], ...
    'isshow', true);
p1 = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_stat.mat'])).stats.mean;
mx = {[-25 25],[-25 25],[-3 3],[-3 3],[-1 20],[-1 30],[-1 5],[-1 15]};
mxtick = {[-20:10:20],[-20:10:20],[-2:2:2],[-2:2:2],[0:5:30],[0:5:30],[0:5:30],[0:5:30]};
plt.setfig(8, 'xtick', mxtick, ...
    'ytick', mxtick);
plt.param_fig.islocked = 1;
EEplot_2noise_parameter_recovery(plt, p1, p2);
%% overall parameter recovery - hyper prior
t0 = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu' num2str(1) '_samples.mat'])).samples;
fns = {'NoiseRan', 'dNoiseRan', 'NoiseDet', 'dNoiseDet'};
for i = 2:10
    disp(i);
    simunum = num2str(i);
    te = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu' simunum '_samples.mat'])).samples;
    for fi = 1:length(fns)
%         t0.(fns{fi}) = (t0.(fns{fi}) * (i-1) + te.(fns{fi}))/i;
        t0.(fns{fi}) = cat(2, t0.(fns{fi}), te.(fns{fi}));
    end
end
plt.setup_W_plt('fig_dir', figdir,...
    'fig_suffix', ['parameterrecovery'],'fig_projectname', ['RanDetNoise' vv],...
    'isshow', false);
sp = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_samples.mat'])).samples;
plt = EEplot_2noise_parameter_recovery_hyperprior(plt, sp, t0);
%% parameter recovery - random/deterministic only
sp = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu_ranonly_' num2str(1) '_samples.mat'])).samples;
sp2 = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu_detonly_' num2str(1) '_samples.mat'])).samples;
fns = {'NoiseRan', 'dNoiseRan', 'NoiseDet', 'dNoiseDet'};
% for i = 2:10
%     disp(i);
%     simunum = num2str(i);
%     tesp = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu_ranonly_' simunum '_samples.mat'])).samples;
%     tesp2 = load(fullfile(outputdir, ['HBI_DetRanNoise' vv '_simu_detonly_' simunum '_samples.mat'])).samples;
%     for fi = 1:length(fns)
%         sp.(fns{fi}) = cat(2, sp.(fns{fi}), tesp.(fns{fi}));
%         sp2.(fns{fi}) = cat(2, sp2.(fns{fi}), tesp2.(fns{fi}));
%     end
% end
plt.setup_W_plt('fig_dir', fullfile(figdir,''),...
    'fig_suffix', '', 'fig_projectname', ['RanDetNoise_PureRanDet' vv], ...
    'isshow', true);
plt = EEplot_2noise_PureRanDet(plt, sp, sp2);
%% parameter recovery - random/deterministic only (50 simulations)
sp = load(fullfile(outputdir, ['HBI_DetRanNoise_fitmodel_E_samples.mat'])).samples;
sp2 = load(fullfile(outputdir, ['HBI_DetRanNoise_fitmodel_F_samples.mat'])).samples;
plt.setup_W_plt('fig_dir', fullfile(figdir,''),...
    'fig_suffix', '', 'fig_projectname', ['RanDetNoise_PureRanDet' vv], ...
    'isshow', true);
plt = EEplot_2noise_PureRanDet(plt, sp, sp2);
%% parameter recovery - grid
griddir = fullfile(outputdir, 'simugrid');
randet = {[],[]};
for i = 0:10
    for j = 0:10
        simui = num2str(i);
        simuj = num2str(j);
        st = load(fullfile(griddir, ['HBI_DetRanNoise_' vv 'simugrid_ran' simui 'det' simuj '_stat.mat'])).stats;
        randet{1}(i+1,j+1) = mean(st.mean.NoiseRan);
        randet{2}(i+1,j+1) = mean(st.mean.NoiseDet);
    end
end
%% 
randetsp = {{},{}};
for i = 0:10
    for j = 0:10
        disp(sprintf('%d,%d', i,j));
        simui = num2str(i);
        simuj = num2str(j);
        sp = load(fullfile(griddir, ['HBI_DetRanNoise_' vv 'simugrid_ran' simui 'det' simuj '_samples.mat'])).samples;
        randetsp{1}{i+1,j+1} = mean(sp.NoiseRan, 3);
        randetsp{2}{i+1,j+1} = mean(sp.NoiseDet, 3);
    end
end
%%
rdsp = {};
rdsp{1} = W.cellfun(@(x)reshape(x, [],1), randetsp{1});
rdsp{2} = W.cellfun(@(x)reshape(x, [],1), randetsp{2});
%%
plt.setup_W_plt('fig_dir', fullfile(figdir,''),...
    'fig_suffix', '', 'fig_projectname', ['RanDetNoise_PureRanDet' vv], ...
    'isshow', true);
plt.figure(2,2);
plt.setfig('ylabel', {'Random only', '','Deterministic only',''}, ...
    'ylim', [0 13],'xtick',[1:11], 'xticklabel', 0:10, 'legloc', 'NorthWest', ...
    'xlabel', {'true random noise','true random noise','true deterministic noise','true deterministic noise'}, ...
    'legend', {'model','truth'});
plt.new;
plt.setfig_ax('title',{'fit random noise'});
ttt = violin([rdsp{1}(:,1)'],'medc',[],'plotlegend','','facecolor', plt.param_preset.colors.AZred);
plt.fig.leglist{1}(end+1) = ttt(1);
hold on;
plt.lineplot(0:10, [],1:11,'*');
plt.new;
plt.setfig_ax('title',{'fit deterministic noise'});
ttt = violin([rdsp{2}(:,1)'],'medc',[],'plotlegend','','facecolor', plt.param_preset.colors.AZblue);
plt.fig.leglist{2}(end+1) = ttt(1);
hold on;
plt.lineplot(zeros(1,11), [],1:11,'*');

plt.new;
plt.setfig_ax('title',{'fit random noise'});
ttt = violin([rdsp{1}(1,:)],'medc',[],'plotlegend','','facecolor', plt.param_preset.colors.AZred);
plt.fig.leglist{3}(end+1) = ttt(1);
hold on;
plt.lineplot(zeros(1,11), [],1:11,'*');
plt.new;
plt.setfig_ax('title',{'fit deterministic noise'});
ttt = violin([rdsp{2}(1,:)],'medc',[],'plotlegend','','facecolor', plt.param_preset.colors.AZblue);
plt.fig.leglist{4}(end+1) = ttt(1);
hold on;
plt.lineplot(0:10, [],1:11,'*');
plt.update;
plt.save('parameterrecovery_pureRanDet');
%% all levels
plt.setup_W_plt('fig_dir', fullfile(figdir,''),...
    'fig_suffix', '', 'fig_projectname', ['RanDetNoise_PureRanDet' vv], ...
    'isshow', true);
plt.figure(11,2,'rect', [0 0 0.6 0.9], 'margin',[0.1 0.07 0.05 0.02], 'gap', [0.01 0.1]);
plt.setfig('xtick',[1:11], 'xticklabel', 0:10);
for i = 1:2
    for j = 1:11
        plt.ax(j, i);
        plt.setfig_ax('ylim', [j-3 j+1], 'ytick', j-1);
        if j == 6
            plt.setfig_ax('ylabel', W.iif(i == 1, {'fit random noise'}, 'fit deterministic noise'));
        end
        if j == 11
            plt.setfig_ax('xlabel', W.iif(i == 1, 'concurrent deterministic noise','concurrent random noise'));
        end
        if j == 1
            plt.setfig_ax('title', W.iif(i == 1, 'Random noise','Deterministic noise'));
        end
        if i == 1
            ddd = [rdsp{i}(j,:)];
        else
            ddd = [rdsp{i}(:,j)'];
        end
        tcol = W.iif(i ==1, plt.param_preset.colors.AZred, plt.param_preset.colors.AZblue);
        ttt = violin(ddd, 'medc',[],'plotlegend','','facecolor', tcol);
        hold on;
        plt.setfig_ax('color', 'AZsand');
        plt.lineplot(ones(1,13)* (j-1), [],0:12,'-');
    end
end
plt.update;
plt.save('parameterrecovery_gridRanDet');
%%
% plt.figure(1,2,'istitle');
% cols = {'AZsand', 'AZred10','AZred20','AZred30','AZred40','AZred50',...
%     'AZred60','AZred70','AZred80','AZred90','AZred'}
% plt.setfig('title', {'Random only', 'Deterministic only'}, ...
%     'color', {cols, cols},'xlabel', 'ground truth', 'ylabel', 'fitted');
% plt.new;
% plt.lineplot(randet{1}',[],0:10,'.')
% plt.lineplot([0 10], [],[0 10],'--');
% plt.new;
% plt.lineplot(randet{2},[],0:10,'.')
% plt.lineplot([0 10], [],[0 10],'--');
% plt.update;


% plt.figure(1,2);
% plt.setfig('title', {'Random only', 'Deterministic only'}, ...
%     'color', {{'AZred', 'AZblue'},{'AZred', 'AZblue'}},'xlabel', 'ground truth', 'ylabel', 'fitted');
% plt.new;
% plt.setfig_ax('legend',{'Random', 'Deterministic'});
% plt.lineplot([randet{1}(:,1)';randet{2}(:,1)']);
% plt.new;
% plt.setfig_ax('legend',{'Random', 'Deterministic'});
% plt.lineplot([randet{1}(1,:);randet{2}(1,:)]);
% plt.update;


% randet = [];
% detran = [];
% for i = 1:10
%     simunum = num2str(i);
%     sp = load(fullfile(outputdir, ['HBI_DetRanNoise_' vv 'simu01_ranonly_' simunum '_stat.mat'])).stats;
%     randet(1,i) = mean(sp.mean.NoiseRan);
%     randet(2,i) = mean(sp.mean.NoiseDet);
%     sp = load(fullfile(outputdir, ['HBI_DetRanNoise_' vv 'simu01_detonly_' simunum '_stat.mat'])).stats;
%     detran(1,i) = mean(sp.mean.NoiseRan);
%     detran(2,i) = mean(sp.mean.NoiseDet);
% end