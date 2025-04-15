%% test convergence
JAGS_setup;
nchains = 4; % How Many Chains?
nburnin = 0; % How Many Burn-in Samples?
nsamples = 5000; % How Many Recorded Samples?
wj.setup_params(nchains, nburnin, nsamples);
d = load(fullfile(fullfile('../data',ver), 'bayesdata.mat')).(['bayesdata']);
d.modelname = '2noisemodel_2cond';
wj.setup_data_dir(d, outputdir);
wjinfo = EEbayes_analysis(d, nchains);
wj.setup(wjinfo.modelfile, wjinfo.params, struct, 'DetRanNoiseR1_convergence');
wj.run;
%% main bayes (base classes)
% set of models
% 1cond vs 2cond
% dI vs dIvar
suffix = {'', '_2cond', '_2cond_dIvar', '_2cond_dIvar_both', '_2cond_dRonly', '_2cond_nobias', ...
    'B_2cond','C_2cond','D_2cond','E_2cond','F_2cond'};
for fi = 1:length(suffix)
    JAGS_setup;
    d = load(fullfile(fullfile('../data',ver), 'bayesdata.mat')).(['bayesdata']);
    d.modelname = sprintf('2noisemodel%s', suffix{fi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['DetRanNoiseR1' suffix{fi}]);
    wj.run;
end
%% check convergence
% load('..\bayesoutput_revision\all_revision\HBI_DetRanNoiseR1_convergence_samples.mat');
%% 
% plt = W_plt('savedir', '../figures', 'savepfx', 'RanDetNoise', 'isshow', true, ...
%     'issave', false, 'extension',{'svg', 'jpg'});
% plt.figure(6,10);
% % id = 100:10000;
% id = 1:5000;
% for i = 1:10
%     plt.ax(1, i);
%     plt.plot([], samples.InfoBonus_mu_n(i,:,1), [], 'line');
%     plt.plot([], samples.InfoBonus_mu_n(i,:,2), [], 'line');
%     plt.dashY(2000)
%     plt.ax(2, i);
%     plt.plot([], samples.bias_mu_n(i,:,1), [], 'line');
%     plt.plot([], samples.bias_mu_n(i,:,2), [], 'line');
%     plt.dashY(2000)
%     plt.ax(3, i);
%     plt.plot([], samples.NoiseRan(i,id,1,1), [], 'line');
%     plt.plot([], samples.NoiseRan(i,id,2,1), [], 'line');
%     plt.dashY(2000)
%     plt.ax(4, i);
%     plt.plot([], samples.NoiseRan(i,id,1,2), [], 'line');
%     plt.plot([], samples.NoiseRan(i,id,2,2), [], 'line');
%     plt.dashY(2000)
%     plt.ax(5, i);
%     plt.plot([], samples.NoiseDet(i,id,1,1), [], 'line');
%     plt.plot([], samples.NoiseDet(i,id,2,1), [], 'line');
%     plt.dashY(2000)
%     plt.ax(6, i);
%     plt.plot([], samples.NoiseDet(i,id,1,2), [], 'line');
%     plt.plot([], samples.NoiseDet(i,id,2,2), [], 'line');
%     plt.dashY(2000)
% end
% plt.update([], repmat(' ',1, 100));
% %% compute data likelihood
% c = d.choice;
% result = {};
% for fi = 1:length(suffix)
%     W.print('loading %d/%d', fi, length(suffix));
%     load(fullfile('..\bayesoutput_revision\all_revision', sprintf('HBI_%s_samples.mat', ['DetRanNoiseR1' suffix{fi} ])));
%     result{fi} = compute_dQ(samples, c);
% end
% %% posterior checks