
%%
plt = W_plt('savedir', '../figures_revision', 'savepfx', 'RDBayes_dIvar', 'isshow', true, ...
    'issave', true, 'extension',{'svg', 'jpg'});
tsp = W.load('../bayesoutput_revision/all_revision/HBI_DetRanNoiseR1_dIvar_samples');
tst = W.load('../bayesoutput_revision/all_revision/HBI_DetRanNoiseR1_dIvar_stat');

%%
plt.set_pltsetting('savesfx', suffix{gii});
old = plt.param_plt.fontsize_title;
plt.param_plt.fontsize_title = 15;
% plt.param_plt.pixel_h = 150;
plt.figure(2,2,'is_title', 'all');
gi = 1;
plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4], [-1 10+10*gi], [-3 8 + gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
    'ylim', []);
EEplot_2noise_hyperpriors(plt, tsp, [0.02 0.02]);
plt.param_plt.fontsize_title = old;

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