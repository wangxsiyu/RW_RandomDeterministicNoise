JAGS_setup;
outputdir = '../bayesoutput_revision/hierarchical';
%% load data
data = W.load('../data/all_revision/bayesdata');
%%
modelnames = {'model_2noise_2cond_nonhierarchical','model_2noise_2cond'};
suffix = {'_2cond_nonhierarchical','_2cond'};
for mi = 1:length(modelnames)
    modelname = modelnames{mi};
    %% fit models to data
    d = data;
    d.modelname = sprintf('2noisemodel%s', suffix{mi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fit' suffix{mi}]);
    wj.run;
    %% load fitted data
    st0 = W.load(fullfile(outputdir, ['HBI_fit' suffix{mi} '_stat']));
    st0 = st0.stats.mean;
    sp = W.load(fullfile(outputdir, ['HBI_fit' suffix{mi} '_samples']));
    stmap = getMAP(sp);
    save(fullfile(outputdir, ['HBI_fit' suffix{mi} '_MAP']), 'stmap');
    %% simulate data from fitted model
    st = st0;
    simu = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub, ...
        st.bias_sub, st.NoiseRan_sub, st.NoiseDet_sub);
    %% simulate data from shuffled model
    nsub = size(st.Infobonus_sub, 2);
    id1 = randperm(nsub);
    id2 = randperm(nsub);
    st_shuffled = st;
    st_shuffled.NoiseRan_sub = st.NoiseRan_sub(:,:,id1);
    st_shuffled.NoiseDet_sub = st.NoiseDet_sub(:,:,id2);
    simu_shuffled = EEsimulate_bayes_2noise_2cond(data, st_shuffled.Infobonus_sub, ...
        st_shuffled.bias_sub, st_shuffled.NoiseRan_sub, st_shuffled.NoiseDet_sub);
    save(fullfile(outputdir, ['simugames' suffix{mi}]), 'simu', 'simu_shuffled', 'st_shuffled');
    %% fit simulated data 
    wj.isoverwrite = 1;
    d = simu;
    d.modelname = sprintf('2noisemodel%s', suffix{mi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fit_simu' suffix{mi}]);
    wj.run;
    %% fit shuffled data
    d = simu_shuffled;
    d.modelname = sprintf('2noisemodel%s', suffix{mi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fit_shuffled' suffix{mi}]);
    wj.run;


    %% using MAP
    %% simulate data from fitted model
    st = stmap;
    simu = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub, ...
        st.bias_sub, st.NoiseRan_sub, st.NoiseDet_sub);
    %% simulate data from shuffled model
    nsub = size(st.Infobonus_sub, 2);
    id1 = randperm(nsub);
    id2 = randperm(nsub);
    simu_shuffled = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub, ...
        st.bias_sub, st.NoiseRan_sub(:,:,id1), st.NoiseDet_sub(:,:,id2));
    save(fullfile(outputdir, ['simugamesMAP' suffix{mi}]), 'simu', 'simu_shuffled')
    %% fit simulated data 
    d = simu;
    d.modelname = sprintf('2noisemodel%s', suffix{mi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fitMAP_simu' suffix{mi}]);
    wj.run;
    %% fit shuffled data
    d = simu_shuffled;
    d.modelname = sprintf('2noisemodel%s', suffix{mi});
    wj.setup_data_dir(d, outputdir);
    wjinfo = EEbayes_analysis(d, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['fitMAP_shuffled' suffix{mi}]);
    wj.run;
end
%% load data
files = fullfile('../bayesoutput_revision/hierarchical',{'HBI_fit_2cond_stat','HBI_fit_2cond_nonhierarchical_stat',...
    'HBI_fit_simu_2cond_stat', 'HBI_fit_simu_2cond_nonhierarchical_stat', ...
    'HBI_fit_shuffled_2cond_stat', 'HBI_fit_shuffled_2cond_nonhierarchical_stat', ...
    'simugames_2cond', 'simugames_2cond_nonhierarchical'});
st = W.load(files);

filesMAP = fullfile('../bayesoutput_revision/hierarchical',{'HBI_fit_2cond_MAP','HBI_fit_2cond_nonhierarchical_MAP',...
    'HBI_fitMAP_simu_2cond_stat', 'HBI_fitMAP_simu_2cond_nonhierarchical_stat', ...
    'HBI_fitMAP_shuffled_2cond_stat', 'HBI_fitMAP_shuffled_2cond_nonhierarchical_stat', ...
    'simugamesMAP_2cond', 'simugamesMAP_2cond_nonhierarchical'});
stmap = W.load(filesMAP);
%% parameter recovery 
plt = W_plt;
plot_parameter_recovery(plt, st{1}.stats.mean, st{3}.stats.mean);
plot_parameter_recovery(plt, st{2}.stats.mean, st{4}.stats.mean);
plot_det_vs_ran(plt, st{1}.stats.mean, st{5}.stats.mean);
plot_det_vs_ran(plt, st{2}.stats.mean, st{6}.stats.mean);
%% parameter recovery MAP
sps = W.load(fullfile('../bayesoutput_revision/hierarchical',{'HBI_fitMAP_simu_2cond_samples', 'HBI_fitMAP_simu_2cond_nonhierarchical_samples'}));
sps = W.load(fullfile('../bayesoutput_revision/hierarchical',{'HBI_fit_simu_2cond_samples', 'HBI_fit_simu_2cond_nonhierarchical_samples'}));
sp1 = getMAP(sps{1});
sp2 = getMAP(sps{2});

plot_parameter_recovery(plt, stmap{1}, sp1);
plot_parameter_recovery(plt, stmap{2}, sp2);
plot_det_vs_ran(plt, stmap{1}, sp1);

%%
%% posterior checks
simu = EEsimulate_bayes_2noise_2condDIST(data, sps{1}.Infobonus_sub, sps{1}.bias_sub, ...
    sps{1}.NoiseRan_sub, sps{1}.NoiseDet_sub);
    simu = EEsimulate_bayes_2noise_2cond(data, st.Infobonus_sub, ...
        st.bias_sub, st.NoiseRan_sub, st.NoiseDet_sub);
    simu2 = EEsimulate_bayes_2noise_2cond(data, st2.Infobonus_sub, ...
        st2.bias_sub, st2.NoiseRan_sub, st2.NoiseDet_sub);
[gg,gp] = getgpsimu(simu);
[gg2,gp] = getgpsimu(simu2);

plot_posteriorchecks(plt, gg, gg2)


[gpsimu,gp] = getgpsimu(st{7}.simu);
plot_posteriorchecks(plt, gp, gpsimu)
[gpsimu2,gp] = getgpsimu(st{8}.simu);
plot_posteriorchecks(plt, gp, gpsimu2)


[gpsimu3] = getgpsimu(stmap{7}.simu);
plot_posteriorchecks(plt, gp, gpsimu3)
[gpsimu4] = getgpsimu(stmap{8}.simu);
plot_posteriorchecks(plt, gp, gpsimu4)
%%
tsp = W.load('../bayesoutput_revision/all_revision/HBI_DetRanNoiseR1_samples');
ttt = W.load('../bayesoutput_revision/all_revision/HBI_DetRanNoiseR1_stat');
ttt = ttt.stats.mean;
tt = getMAPsimple(tsp);
plot_parameter_recovery(plt, ttt, tt);

simu = EEsimulate_bayes_2noise_simple(data, tt.Infobonus_sub, ...
    tt.bias_sub, tt.NoiseRan_sub, tt.NoiseDet_sub);
[gptt] = getgpsimu(simu);
plot_posteriorchecks(plt, gp, gptt)



simut = EEsimulate_bayes_2noise_simple(data, ttt.Infobonus_sub, ...
    ttt.bias_sub, ttt.NoiseRan_sub, ttt.NoiseDet_sub);
[gpttt] = getgpsimu(simut);
plot_posteriorchecks(plt, gp, gpttt)


%% check hyperprior
sps = W.load(fullfile('../bayesoutput_revision/hierarchical',{'HBI_fit_2cond_stat', 'HBI_fit_2cond_samples'}));
st = sps{1}.stats.mean;
smp = getMAP(sps{2});
sps = W.load(fullfile('../bayesoutput_revision/hierarchical',{'HBI_fit_simu_2cond_stat', 'HBI_fit_simu_2cond_samples'}));
st2 = sps{1}.stats.mean;
smp2 = getMAP(sps{2});
%%
plt.figure, 

hold on;
hist(squeeze(st.NoiseDet_sub(2,2,:)), 20)
[x,y] = W.JAGS_density(reshape(sp.NoiseDet(:,:,2,2),1,[]), 0:.1:20);
plt.plot(y, x * 10, [], 'line');
plt.dashY(mean(squeeze(st.NoiseDet_sub(2,2,:))))

plot_parameter_recovery(plt, st, st2)
% plot_parameter_recovery(plt, st, smp2)

%%
sps = W.load(fullfile('../bayesoutput_revision/hierarchical',{'HBI_fit_2cond_samples', 'HBI_fit_simu_2cond_samples'}));

sp = sps{1};
recovered = sps{2};
plt = W_plt;
plt.figure(4,3, 'is_title', 1);
names = ["NoiseRan", "NoiseDet"];
xbins = -10:0.02:50;
color = {{'AZred','AZred'},{'AZblue','AZblue'}};
plt.setfig([1 4 2 5 3 6], 'xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15, 0:4:50,-3:3:15});
plt.setfig([1 4 2 5 3 6], 'xlim', {[-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1], [-3 8 + 1 *4]});
plt.setfig_all('ytick', [],'ylim', [0 0.8], 'legend', {'fitted posterior', 'true posterior'});
plt.setfig(1:6,'legloc',{'NE','NW','NE','NE','NW','NE'})
plt.setfig([1:3],'xlabel','random noise', 'ylabel', 'histogram/posterior', ...
    'title', {'H = 1', 'H = 6', '\Delta noise'});
plt.setfig([4:6],'xlabel','deterministic noise', 'ylabel', 'histogram/posterior', ...
    'title', {'', '', ''});
for ci = 1:2
    for i = 1:2
        for h = 1:2
            plt.ax(i+ (ci-1)*2,h);
            [tl, tm] = W.JAGS_density(recovered.(names{i})(:,:,h, ci), xbins);
            plt.plot(tm, tl,[],'bar', 'color', strcat(color{i}{h},'50'));
            plt.plot(tm, tl,[],'line', 'color', strcat(color{i}{h},'50'), 'addtolegend', false);
            [tl,tm] = W.JAGS_density(sp.(names(i))(:,:,h, ci), xbins);
            %         tl = tl./max(tl);
            plt.plot(tm, tl,[],'line', 'color', color{i}{h});
        end

        plt.ax(i+ (ci-1)*2,3);
        [tl, tm] = W.JAGS_density(recovered.(strcat('d',names(i)))(:,:,ci), xbins);
        %     tl = tl./max(tl);
        plt.plot(tm, tl,[],'bar', 'color', 'gray');
        plt.plot(tm, tl,[],'line', 'color', 'gray', 'addtolegend', false);
        [tl,tm] = W.JAGS_density(sp.(strcat('d',names(i)))(:,:,ci), xbins);
        %     tl = tl./max(tl);
        plt.plot(tm, tl,[],'line', 'color', 'black');
    end
end
plt.update('parameterrecovery_hyperprior_v2');
%%
plt = W_plt;
plt.figure(1,2, 'is_title', 1);
for h = 1:2
    plt.ax(h);
    [tl, tm] = W.JAGS_density(sp.bias_mu_n(:,:,h), -5:.1:5);
    plt.plot(tm, tl,[],'line', 'color', 'black', 'addtolegend', false);
    plt.dashY(0)
    plt.setfig_ax('xlabel', 'bias', 'ylabel', 'density')
end
plt.setfig('title', {'H = 1', 'H = 6'})
plt.update('parameterrecovery_hyperprior_v2');