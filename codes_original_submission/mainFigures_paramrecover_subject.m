outputdir = '../bayesoutput/all/';
st = load(fullfile(outputdir, ['HBI_DetRanNoise_stat.mat'])).stats.mean;
%% compute coverage
simudir = '../bayesoutput/simurepeat';
stsimu = cell(1,200);
for repi = 1:200
    tstat = load(fullfile(simudir, sprintf('HBI_DetRanNoise_simu_%d_stat.mat', repi)));
    stsimu{repi} = tstat.stats.mean;
end
stsimu = cellfun(@(x)x, stsimu);
%%
stsimuav = W.struct_median(stsimu);
%%
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
mx = {[-25 25],[-25 25],[-3 3],[-3 3],[-1 20],[-1 30],[-1 5],[-1 15]};
mxtick = {[-20:10:20],[-40:20:40],[-2:2:4],[-2:2:4],[0:10:50],[0:10:50],[0:5:30],[0:5:30]};
plt.figure(4,2,'is_title', 1);
plt.setfig('xtick', mxtick, ...
    'ytick', mxtick);
EEplot_2noise_parameter_recovery(plt, st, stsimuav);
%%
plt.set_pltsetting('savesfx', 'examplesession')
plt.figure(4,2,'is_title', 1);
plt.setfig('xtick', mxtick, ...
    'ytick', mxtick);
EEplot_2noise_parameter_recovery(plt, st, stsimu(1));
%%
plt.set_pltsetting('savesfx', 'examplesession_randet')
plt.figure(2,2,'is_title', 1);
mx = {[-1 20],[-1 30],[-1 5],[-1 15]};
mxtick = {[0:10:50],[0:10:50],[0:5:30],[0:5:30]};
plt.setfig('xtick', mxtick, ...
    'ytick', mxtick);
EEplot_2noise_parameter_recovery(plt, st, stsimu(1),2);
%%
% stall = repmat(st,1, 200);
% %%
% plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
%     'issave', true);
% mx = {[-25 25],[-25 25],[-3 3],[-3 3],[-1 20],[-1 30],[-1 5],[-1 15]};
% mxtick = {[-20:10:20],[-20:10:20],[-2:2:2],[-2:2:2],[0:5:30],[0:5:30],[0:5:30],[0:5:30]};
% plt.figure(4,2,'is_title', 1);
% plt.setfig(8, 'xtick', mxtick, ...
%     'ytick', mxtick);
% EEplot_2noise_parameter_recovery(plt, stall, stsimu);