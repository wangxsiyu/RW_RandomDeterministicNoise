JAGS_setup;
%% simulate model recovery of simulaions of 6 behaviors
% get simu
data = load(fullfile('../data/all_revision/bayesdata.mat')).(['bayesdata']);
for repi = 1:10
    name = {'','B','C','D','E','F'};
    simu = {};
    tfile = fullfile(W.mkdir('../bayesoutput_revision/simu6model'), sprintf('bayes_6model_simu_rep%d.mat', repi));
    data1 = importdata(tfile);
    for mi = 1:6
        for mmi = 1:6
            filename = [sprintf('DetRanNoise_fitmodel%s_rep%d_', name{mmi}, repi) char(64 + mi)];
            if ~exist(fullfile('../bayesoutput_revision/simu6model', ['HBI_' filename '_stat.mat']), 'file')
                d = data1{mi};
                JAGS_setup;

                d.modelname = ['2noisemodel' name{mmi} '_2cond'];
                wj.setup_data_dir(d, '../bayesoutput_revision/simu6model');
                wjinfo = EEbayes_analysis(d, nchains);
                wj.setup(wjinfo.modelfile, wjinfo.params, struct, filename);
                wj.run;
            else
                disp(sprintf('file exists: %s', filename));
            end
        end
    end
end
