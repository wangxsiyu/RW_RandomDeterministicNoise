JAGS_setup;
%% same as above but use actual information and bias
paramsub = load(fullfile(outputdir, ['HBI_DetRanNoise_paironly_stat.mat'])).stats.mean;
data = load('../data/all/bayes_2noise_paironly.mat').bayes_data_paironly;
data.modelname = '2noisemodel';
nsub = data.nSubject;
nh = data.nHorizon;
rans = [1:10, zeros(1,10), 0];
dets = [zeros(1,10), 1:10, 0];
for i = 1:length(rans)
    numi = rans(i);
    numj = dets(i);
    savename = sprintf('../bayesoutput/simugrid_infobias_paironly/simugame_ran%d_det%d.mat', numi, numj);
    W.print('%d,%d', numi, numj);
    if exist(savename, 'file')
        W.print('skip');
        continue;
    end
    % zero det noise
    simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
        paramsub.bias_sub', ones(nsub, nh) * numi, ones(nsub, nh) * numj);
    % fit
    wj.setup_data_dir(simugame, '../bayesoutput/simugrid_infobias_paironly');
    wjinfo = EEbayes_analysis(simugame, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' sprintf('simugrid_ran%d_det%d',numi,numj)]);
    wj.run;
    W.save(savename, ...
        'simugame', simugame);
end
%% 
%% bayesian plots
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true);
%% Load data simugrid
griddir = '../bayesoutput/simugrid_infobias_paironly/';
sp = FigureLoad_gridsimu(griddir, 0:10);
%% Pure Ran/Det
W.library('tools_violin')
plt.set_pltsetting('savesfx','paironly')
plt.figure(2,2,'is_title','all');
plt.setfig_all('ylim', [0 13]);
Figure_gridsimu_pureRanDet(plt, sp, 0:10)
