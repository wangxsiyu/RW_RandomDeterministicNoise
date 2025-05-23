addpath(genpath('../codes_support'))
JAGS_setup_revision;
% wj.workingdir = 'C:\Users\Siyu_Wang\Documents\TEMP\JAGS2';
%% full-grid parameter recovery (with only random noise and only deterministic noise)
data = load('../data/all_revision/bayes_2noise_2cond.mat').bayes_data_2cond;
data.modelname = '2noisemodel_2cond';
nsub = data.nSubject;
nh = data.nHorizon;
rans = [1:10,12:2:20];
% rans = rans(end:-1:1);
nC = 2;
dets = [0:10];
% dets = dets(end:-1:1);
for i = 1:length(rans)
    numi = rans(i);
    for j = 1:length(dets)
        numj = dets(j);
        savename = sprintf('../bayesoutput_revision/simugrid/simugame_ran%d_det%d.mat', numi, numj);
        W.print('%d,%d', numi, numj);
        if exist(savename, 'file')
            W.print('skip');
            continue;
        end
        % zero det noise
        simugame = EEsimulate_bayes_2noise_2cond(data, zeros(nh, nsub), ...
            zeros(nh, nC, nsub), ones(nh, nC, nsub) * numi, ones(nh, nC, nsub) * numj);
         % fit
        wj.setup_data_dir(simugame, '../bayesoutput_revision/simugrid_infobias');
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_2cond_' sprintf('simugrid_ran%d_det%d',numi,numj)]);
        wj.run;
        W.save(savename, ...
            'simugame', simugame);
    end
end
%% same as above but use actual information and bias
paramsub = load(fullfile(outputdir, ['HBI_DetRanNoise_2cond_stat.mat'])).stats.mean;
data = load('../data/all_revision/bayes_2noise_2cond.mat').bayes_data_2cond;
data.modelname = '2noisemodel_2cond';
nsub = data.nSubject;
nh = data.nHorizon;
rans = [1:10,12:2:20];
% rans = rans(end:-1:1);
nC = 2;
dets = [0:10];
% dets = dets(end:-1:1);
for i = 1:length(rans)
    numi = rans(i);
    for j = 1:length(dets)
        numj = dets(j);
        savename = sprintf('../bayesoutput_revision/simugrid_infobias/simugame_ran%d_det%d.mat', numi, numj);
        W.print('%d,%d', numi, numj);
        if exist(savename, 'file')
            W.print('skip');
            continue;
        end
        % zero det noise
        simugame = EEsimulate_bayes_2noise_2cond(data, paramsub.Infobonus_sub, ...
            paramsub.bias_sub, ones(nh, nC, nsub) * numi, ones(nh, nC, nsub) * numj);
         % fit
        wj.setup_data_dir(simugame, '../bayesoutput_revision/simugrid_infobias');
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_2cond_' sprintf('simugrid_ran%d_det%d',numi,numj)]);
        wj.run;
        W.save(savename, ...
            'simugame', simugame);
    end
end
%% 
% % load fitted params
% if ~isfield(paramsub, 'bias_sub')
%     paramsub.bias_sub = zeros(nh, nsub);
% end