outputdir = '../bayesoutput/all/';
sp = load(fullfile(outputdir, ['HBI_DetRanNoise_samples.mat'])).samples;
%% load recovered
varsofinterest = {'NoiseRan', 'NoiseDet', 'dNoiseRan', 'dNoiseDet', ...
    'bias_mu_n','dbias','InfoBonus_mu_n', 'dInfoBonus'};
simudir = '../bayesoutput/simurepeat';
recovered = struct;
for repi = 1:200
    W.print('rep %d', repi);
    tsp = importdata(fullfile(simudir, sprintf('HBI_DetRanNoise_simu_%d_samples.mat', repi)));
    tsp = rmfield(tsp, setdiff(fieldnames(tsp), varsofinterest));
    recovered = W.struct_cat_bydim(recovered, tsp, 2);
end
W.save('./Temp/param_recovery.mat','recovered', recovered);
%%
load('./Temp/param_recovery.mat')
%% hyper prior recovery
plt = W_plt('savedir', '../figures', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true, 'extension',{'svg', 'jpg'});
plt.figure(2,3, 'is_title', 1);
names = ["NoiseRan", "NoiseDet"];
xbins = -10:0.02:50;
color = {{'AZred','AZred'},{'AZblue','AZblue'}};
plt.setfig([1 4 2 5 3 6], 'xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15, 0:4:50,-3:3:15});
plt.setfig([1 4 2 5 3 6], 'xlim', {[-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1], [-3 8 + 1 *4]});
plt.setfig_all('ytick', [],'ylim', [0 0.8], 'legend', {'fitted posterior', 'true posterior'});
plt.setfig('legloc',{'NE','NW','NE','NE','NW','NE'})
plt.setfig([1:3],'xlabel','random noise', 'ylabel', 'histogram/posterior', ...
    'title', {'H = 1', 'H = 6', '\Delta noise'});
plt.setfig([4:6],'xlabel','deterministic noise', 'ylabel', 'histogram/posterior', ...
    'title', {'', '', ''});
for i = 1:2
    for h = 1:2
        plt.ax(i*3-3+h);
        [tl, tm] = W.JAGS_density(recovered.(names{i})(:,:,h), xbins);
        plt.plot(tm, tl,[],'bar', 'color', strcat(color{i}{h},'50'));
        plt.plot(tm, tl,[],'line', 'color', strcat(color{i}{h},'50'), 'addtolegend', false);
        [tl,tm] = W.JAGS_density(sp.(names(i))(:,:,h), xbins);
%         tl = tl./max(tl);
        plt.plot(tm, tl,[],'line', 'color', color{i}{h});
    end
    
    plt.ax(i*3);
    [tl, tm] = W.JAGS_density(recovered.(strcat('d',names(i))), xbins);
%     tl = tl./max(tl);
    plt.plot(tm, tl,[],'bar', 'color', 'gray');
        plt.plot(tm, tl,[],'line', 'color', 'gray', 'addtolegend', false);
    [tl,tm] = W.JAGS_density(sp.(strcat('d',names(i))), xbins);
%     tl = tl./max(tl);
    plt.plot(tm, tl,[],'line', 'color', 'black');
end
plt.update('parameterrecovery_hyperprior_v2');
% %% check overall random noise level
% totn = sp.NoiseDet + sp.NoiseRan;
% totn2 = recovered.NoiseDet + recovered.NoiseRan;
% plt.figure(1,2);
% color = {{'AZred','AZred'},{'AZblue','AZblue'}};
% xbins = -10:0.02:50;
% for hi = 1:2
%     plt.ax(hi);
%     [tl, tm] = W.JAGS_density(totn2(:,:,hi), xbins);
%     plt.plot(tm, tl,[],'bar', 'color', strcat(color{i}{h},'50'));
%     plt.plot(tm, tl,[],'line', 'color', strcat(color{i}{h},'50'), 'addtolegend', false);
%     [tl,tm] = W.JAGS_density(totn(:,:,hi), xbins);
%     plt.plot(tm, tl,[],'line', 'color', color{i}{h});
% end
% plt.update;
%%
median(recovered.NoiseDet(:,:,:), 'all')/median(sp.NoiseDet(:,:,:), 'all')
(median(sp.NoiseDet(:,:,:), 'all') - median(recovered.NoiseDet(:,:,:), 'all'))/median(sp.NoiseDet(:,:,:), 'all')
median(recovered.NoiseRan(:,:,:), 'all')/median(sp.NoiseRan(:,:,:), 'all')
median(recovered.dNoiseDet(:,:,:), 'all')/median(sp.dNoiseDet(:,:,:), 'all')
%%

%     simunum = num2str(i);
%     plt.setup_W_plt('fig_dir', fullfile(figdir,'parameter_recovery'),...
%         'fig_suffix', [simunum],'fig_projectname', ['RanDetNoise' vv],...
%         'isshow', true);
%     sp2 = load(fullfile(outputdir, ['HBI_DetRanNoise_fitmodel_A_samples.mat'])).samples;
%     plt = EEplot_2noise_parameter_recovery_hyperprior(plt, sp, sp2);