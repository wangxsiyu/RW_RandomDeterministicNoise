JAGS_setup;
% wj.workingdir = 'C:\Users\Siyu_Wang\Documents\TEMP\JAGS2';
%% full-grid parameter recovery (with only random noise and only deterministic noise)
% % simulate behavior
% data = load('../data/all/bayes_2noise.mat').bayes_data;
% data.modelname = '2noisemodel';
% nsub = data.nSubject;
% nh = data.nHorizon;
% for numi = 0:10
%     for numj = 0:10
%         W.print('%d,%d', numi, numj);
%         % zero det noise
%         simugame = EEsimulate_bayes_2noise(data, zeros(nsub, nh), ...
%             zeros(nsub, nh), ones(nsub, nh) * numi, ones(nsub, nh) * numj);
%         % fit
%         wj.setup_data_dir(simugame, '../bayesoutput/simugrid');
%         wjinfo = EEbayes_analysis(simugame, nchains);
%         wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' sprintf('simugrid_ran%d_det%d',numi,numj)]);
%         wj.run;
%         W.save(sprintf('../bayesoutput/simugrid/simugame_ran%d_det%d.mat', numi, numj), ...
%             'simugame', simugame);
%     end
% end
%% same as above but use actual information and bias
paramsub = load(fullfile(outputdir, ['HBI_DetRanNoise_stat.mat'])).stats.mean;
data = load('../data/all/bayes_2noise.mat').bayes_data;
data.modelname = '2noisemodel';
nsub = data.nSubject;
nh = data.nHorizon;
rans = [1:10,12:2:20];
% rans = rans(end:-1:1);
dets = [0:10];
% dets = dets(end:-1:1);
for i = 1:length(rans)
    numi = rans(i);
    for j = 1:length(dets)
        numj = dets(j);
        savename = sprintf('../bayesoutput2/simugrid_infobias/simugame_ran%d_det%d.mat', numi, numj);
        W.print('%d,%d', numi, numj);
        if exist(savename, 'file')
            W.print('skip');
            continue;
        end
        % zero det noise
        simugame = EEsimulate_bayes_2noise(data, paramsub.Infobonus_sub', ...
            paramsub.bias_sub', ones(nsub, nh) * numi, ones(nsub, nh) * numj);
         % fit
        wj.setup_data_dir(simugame, '../bayesoutput2/simugrid_infobias');
        wjinfo = EEbayes_analysis(simugame, nchains);
        wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoise_' sprintf('simugrid_ran%d_det%d',numi,numj)]);
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