JAGS_setup;
%% simulate model recovery of simulaions of 6 behaviors
% get simu
data = load(fullfile('../data/all/bayes_2noise.mat')).(['bayes_data']);
for repi = 1:50
    name = {'','B_','C_','D_','E_','F_'};
    simu = {};
    tfile = fullfile(W.mkdir('../bayesoutput/simu6model'), sprintf('bayes_6model_simu_rep%d.mat', repi));
    if ~exist(tfile, 'file')
        for mi = 1:6
            tparam = load(fullfile(outputdir, ['HBI_DetRanNoise_' name{mi} 'stat.mat'])).stats.mean;
            if ~isfield(tparam, 'NoiseRan_sub')
                tparam.NoiseRan_sub = zeros(size(tparam.NoiseDet_sub));
            end
            if ~isfield(tparam, 'NoiseDet_sub')
                tparam.NoiseDet_sub = zeros(size(tparam.NoiseRan_sub));
            end
            simu{mi} = EEsimulate_bayes_2noise(data, tparam.Infobonus_sub', ...
                tparam.bias_sub', tparam.NoiseRan_sub', tparam.NoiseDet_sub');
        end
        save(tfile,'simu');
    end
    %%
    data1 = importdata(tfile);
    for mi = 1:6
        for mmi = 1:6
            filename = [sprintf('DetRanNoise_fitmodel%s_rep%d_', name{mmi}, repi) char(64 + mi)];
            if ~exist(fullfile('../bayesoutput/simu6model', ['HBI_' filename '_stat.mat']), 'file')
                d = data1{mi};
                if mmi >= 2
                    d.modelname = ['2noisemodel' char(64+mmi)];
                end
                wj.setup_data_dir(d, '../bayesoutput/simu6model');
                wjinfo = EEbayes_analysis(d, nchains);
                wj.setup(wjinfo.modelfile, wjinfo.params, struct, filename);
                wj.run;
            else
                disp(sprintf('file exists: %s', filename));
            end
        end
    end
end
