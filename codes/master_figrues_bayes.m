%% bayesian plots
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
%% Load data simugrid
griddir = '../bayesoutput/simugrid/';
sp = FigureLoad_gridsimu(griddir);
%% Figure simugrid
Figure_gridsimu_all(plt, sp)
