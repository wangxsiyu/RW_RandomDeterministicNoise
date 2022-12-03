JAGS_setup;
%% full-grid parameter recovery (with only random noise and only deterministic noise)
% simulate behavior
data = load('../data/all/bayes_2noise.mat').bayes_data;
data.modelname = '2noisemodel';
nsub = data.nSubject;
nh = data.nHorizon;
for numi = 0:10
    for numj = 0:10
        W.print('%d,%d', numi, numj);
        % zero det noise
        simugame = EEsimulate_bayes_2noise(data, zeros(nsub, nh), ...
            zeros(nsub, nh), ones(nsub, nh) * numi, ones(nsub, nh) * numj);
        % fit
        wj.setup_data_dir(simugame, '../bayesoutput/simugrid');
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' sprintf('simugrid_ran%d_det%d',numi,numj)]);
        wj.run;
        W.save(sprintf('../bayesoutput/simugrid/simugame_ran%d_det%d.mat', numi, numj), ...
            'simugame', simugame);
    end
end
%% same as above but use actual information and bias
paramsub = load(fullfile(outputdir, ['HBI_DetRanNoise_stat.mat'])).stats.mean;
data = load('../data/all/bayes_2noise.mat').bayes_data;
data.modelname = '2noisemodel';
nsub = data.nSubject;
nh = data.nHorizon;
for numi = 0:10
    for numj = 0:10
        W.print('%d,%d', numi, numj);
        % zero det noise
        simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
            paramsub.bias_sub', ones(nsub, nh) * numi, ones(nsub, nh) * numj);
         % fit
        wj.setup_data_dir(simugame, '../bayesoutput/simugrid_infobias');
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' sprintf('simugrid_ran%d_det%d',numi,numj)]);
        wj.run;
        W.save(sprintf('../bayesoutput/simugrid_infobias/simugame_ran%d_det%d.mat', numi, numj), ...
            'simugame', simugame);
    end
end
%% 
% % load fitted params
% if ~isfield(paramsub, 'bias_sub')
%     paramsub.bias_sub = zeros(nh, nsub);
% end