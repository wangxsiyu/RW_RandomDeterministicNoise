JAGS_setup;
%%
data = importdata('../data/all_revision/bayesdata.mat');
data.modelname = ['2noisemodel'];
for numi = 1:10
    W.print('rep: %d', numi);
    wj.setup_data_dir(data, '../bayesoutput_revision/R1_simurepeat');
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['R1_fit_' num2str(numi)]);
    wj.run;
    
    paramsub = load(fullfile('../bayesoutput_revision/R1_simurepeat', [HBItest 'HBI_R1_fit_' num2str(numi) '_stat.mat'])).stats.mean;

    simugame = EEsimulate_bayes_2noise_simple(data, paramsub.Infobonus_sub, ...
        paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
    W.save(sprintf('../bayesoutput_revision/R1_simurepeat/R1_simugame_%d.mat', numi), ...
        'simugame', simugame);
    % fit
    wj.setup_data_dir(simugame, '../bayesoutput_revision/R1_simurepeat');
    wjinfo = EEbayes_analysis(simugame, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['R1_fit_simu_' num2str(numi)]);
    wj.run;
end
%%
data = importdata('../data/all_revision/bayesdata.mat');
data.modelname = ['2noisemodel_2cond'];
for numi = 11:50
    W.print('rep: %d', numi);
    wj.setup_data_dir(data, '../bayesoutput_revision/R1_simurepeat_2cond');
    wjinfo = EEbayes_analysis(data, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['R1_fit_' num2str(numi)]);
    wj.run;
    
    paramsub = load(fullfile('../bayesoutput_revision/R1_simurepeat_2cond', [HBItest 'HBI_R1_fit_' num2str(numi) '_stat.mat'])).stats.mean;

    simugame = EEsimulate_bayes_2noise_2cond(data, paramsub.Infobonus_sub, ...
        paramsub.bias_sub, paramsub.NoiseRan_sub, paramsub.NoiseDet_sub);
    W.save(sprintf('../bayesoutput_revision/R1_simurepeat_2cond/R1_simugame_%d.mat', numi), ...
        'simugame', simugame);
    % fit
    wj.setup_data_dir(simugame, '../bayesoutput_revision/R1_simurepeat_2cond');
    wjinfo = EEbayes_analysis(simugame, nchains);
    wj.setup(wjinfo.modelfile, wjinfo.params, struct, ['R1_fit_simu_' num2str(numi)]);
    wj.run;
end
%% show parameter recovery for 1cond
files = W.ls('..\bayesoutput_revision\R1_simurepeat\*_stat.mat');
st0 = W.load(files(1:10));
st1 = W.load(files(11:20));
st0 = W.cellfun(@(x)x.stats.mean, st0, false);
st1 = W.cellfun(@(x)x.stats.mean, st1, false);
filep = W.ls('..\bayesoutput_revision\R1_simurepeat\*_samples.mat');
sp0 = W.load(filep(1:10));
sp1 = W.load(filep(11:20));
st1map = W.cellfun(@(x)getMAP(x), sp1, false);

st1av = W.struct_avse(cellfun(@(x)x,st1));
st1avmap = W.struct_avse(cellfun(@(x)x,st1map));
plt = W_plt;
plot_parameter_recovery(plt, st0{1}, st1av,1)
plot_parameter_recovery(plt, st0{1}, st1avmap,1)

%% show parameter recovery for 2cond
files = W.ls('..\bayesoutput_revision\R1_simurepeat_2cond\*_stat.mat');
st0raw = W.load(files(1:10));
st1raw = W.load(files(11:20));
st0 = W.cellfun(@(x)x.stats.mean, st0raw, false);
st1 = W.cellfun(@(x)x.stats.mean, st1raw, false);
filep = W.ls('..\bayesoutput_revision\R1_simurepeat_2cond\*_samples.mat');
sp0 = W.load(filep(1:10));
sp1 = W.load(filep(11:20));
st1map = W.cellfun(@(x)getMAP(x), sp1, false);

st1av = W.struct_avse(cellfun(@(x)x,st1));
st1avmap = W.struct_avse(cellfun(@(x)x,st1map));

plt = W_plt;
plot_parameter_recovery(plt, st0{1}, st1av,2)
plot_parameter_recovery(plt, st0{1}, st1avmap,2)
%% hyperprior recovery for 1cond
sp = sp0{1};
recovered = struct;
varsofinterest = {'NoiseRan', 'NoiseDet', 'dNoiseRan', 'dNoiseDet', ...
    'bias_mu_n','dbias','InfoBonus_mu_n', 'dInfoBonus'};
for repi = 1:10
    W.print('rep %d', repi);
    tsp = sp1{repi};
    tsp = rmfield(tsp, setdiff(fieldnames(tsp), varsofinterest));
    recovered = W.struct_cat_bydim(recovered, tsp, 2);
end


plt = W_plt;
plt.figure(2,3, 'is_title', 1);
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
    for i = 1:2
        for h = 1:2
            plt.ax(i,h);
            [tl, tm] = W.JAGS_density(recovered.(names{i})(:,:,h), xbins);
            plt.plot(tm, tl,[],'bar', 'color', strcat(color{i}{h},'50'));
            plt.plot(tm, tl,[],'line', 'color', strcat(color{i}{h},'50'), 'addtolegend', false);
            [tl,tm] = W.JAGS_density(sp.(names(i))(:,:,h), xbins);
            %         tl = tl./max(tl);
            plt.plot(tm, tl,[],'line', 'color', color{i}{h});
        end

        plt.ax(i,3);
        [tl, tm] = W.JAGS_density(recovered.(strcat('d',names(i))), xbins);
        %     tl = tl./max(tl);
        plt.plot(tm, tl,[],'bar', 'color', 'gray');
        plt.plot(tm, tl,[],'line', 'color', 'gray', 'addtolegend', false);
        [tl,tm] = W.JAGS_density(sp.(strcat('d',names(i))), xbins);
        %     tl = tl./max(tl);
        plt.plot(tm, tl,[],'line', 'color', 'black');
    end
plt.update('parameterrecovery_hyperprior_v2');
%% hyperprior recovery for 2cond
sp = sp0{1};
recovered = struct;
varsofinterest = {'NoiseRan', 'NoiseDet', 'dNoiseRan', 'dNoiseDet', ...
    'bias_mu_n','dbias','InfoBonus_mu_n', 'dInfoBonus'};
for repi = 1:10
    W.print('rep %d', repi);
    tsp = sp1{repi};
    tsp = rmfield(tsp, setdiff(fieldnames(tsp), varsofinterest));
    recovered = W.struct_cat_bydim(recovered, tsp, 2);
end


plt = W_plt;
plt.figure(4,3, 'is_title', 1);
names = ["NoiseRan", "NoiseDet"];
xbins = -10:0.02:50;
color = {{'AZred','AZred'},{'AZblue','AZblue'}};
plt.setfig([1 4 2 5 3 6], 'xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15, 0:4:50,-3:3:15});
plt.setfig([1 4 2 5 3 6], 'xlim', {[-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1], [-3 8 + 1 *4]});

plt.setfig([1 4 2 5 3 6] + 6, 'xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15, 0:4:50,-3:3:15});
plt.setfig([1 4 2 5 3 6] + 6, 'xlim', {[-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1], [-3 8 + 1 *4]});

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
%% coverage recovery for 2cond

sp = sp0{1};

coverage = struct;
recovered = struct;
for repi = 1:10
    tstat = st1raw{repi};
    recovered.dNoiseRan(repi,:) = tstat.stats.mean.dNoiseRan;
    recovered.dNoiseDet(repi,:) = tstat.stats.mean.dNoiseDet;
    % coverage.dNoiseRan(repi,:) = W.is_between(mean(sp.dNoiseRan,'all'), [tstat.stats.ci_low.dNoiseRan tstat.stats.ci_high.dNoiseRan]);
    % coverage.dNoiseDet(repi,:) = W.is_between(mean(sp.dNoiseDet,'all'), [tstat.stats.ci_low.dNoiseDet tstat.stats.ci_high.dNoiseDet]);
    % for ci = 1:2
    %     for i = 1:2
    %         coverage.NoiseRan(repi, i,ci) = W.is_between(mean(sp.NoiseRan(:,:,i,ci),'all'), [tstat.stats.ci_low.NoiseRan(i) tstat.stats.ci_high.NoiseRan(i)]);
    %         coverage.NoiseDet(repi, i,ci) = W.is_between(mean(sp.NoiseDet(:,:,i,ci),'all'), [tstat.stats.ci_low.NoiseDet(i) tstat.stats.ci_high.NoiseDet(i)]);
    %     end
    % end
    recovered.NoiseRan(repi,:,:) = tstat.stats.mean.NoiseRan;
    recovered.NoiseDet(repi,:,:) = tstat.stats.mean.NoiseDet;
end



plt.figure(4,3, 'is_title', 1);
names = ["NoiseRan", "NoiseDet"];
xbins = -10:0.02:50;
color = {{'AZred','AZred'},{'AZblue','AZblue'}};
plt.setfig([1 4 2 5 3 6], 'xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15, 0:4:50,-3:3:15});
plt.setfig([1 4 2 5 3 6], 'xlim', {[-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1], [-3 8 + 1 *4]});
plt.setfig([1 4 2 5 3 6]+6, 'xtick',{0:4:50,-3:3:15,0:4:50,-3:3:15, 0:4:50,-3:3:15});
plt.setfig([1 4 2 5 3 6]+6, 'xlim', {[-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1],[-3 8+ 1 *4], [-1 10+10*1], [-3 8 + 1 *4]});
plt.setfig_all('ylim', [0 1.2], 'legend', {'fitted posterior mean', 'true posterior'});
plt.setfig(1:6, 'legloc',{'NE','NW','NE','NE','NW','NE'})
plt.setfig(1:3,'xlabel','random noise', 'ylabel', 'histogram/posterior', ...
    'title', {'H = 1', 'H = 6', '\Delta noise'});
plt.setfig([4:6],'xlabel','deterministic noise', 'ylabel', 'histogram/posterior', ...
    'title', {'', '', ''});
for ci = 1:2
for i = 1:2
    for h = 1:2
            plt.ax(i+ (ci-1)*2,h);
        [tl, tm] = hist(recovered.(names(i))(:,h, ci));
        tl = tl./max(tl);
        plt.plot(tm, tl,[],'bar', 'color', strcat(color{i}{h},'50'));
        tsp = sp.(names(i))(:,:,h, ci);
        [tl,tm] = W.JAGS_density(tsp, xbins);
        tl = tl./max(tl);
        plt.plot(tm, tl,[],'line', 'color', color{i}{h});
        plt.dashY(mean(tsp,'all'), [0 1.2], 'color', color{i}{h});
    end
    
        plt.ax(i+ (ci-1)*2,3);
    [tl, tm] = hist(recovered.(strcat('d',names(i)))(:,ci));
    tl = tl./max(tl);
    plt.plot(tm, tl,[],'bar', 'color', 'gray');
    tsp = sp.(strcat('d',names(i)))(:,:,ci);
    [tl,tm] = W.JAGS_density(tsp, xbins);
    tl = tl./max(tl);
    plt.plot(tm, tl,[],'line', 'color', 'black');
    plt.dashY(mean(tsp,'all'), [0 1.2],'color', 'black');
end
end
plt.update('parameterrecovery_hyperprior');


