%% bayesian plots
plt = W_plt('savedir', '../figures_revision', 'savepfx', 'RDBayes', 'isshow', true, ...
    'issave', true, 'extension',{'svg', 'jpg'});
outputdir = '../bayesoutput_revision/all_revision';
%% figure - posterior 
suffix = {'_2cond','_2cond_dIvar'};
param = {};
for gi = 1:length(suffix)
    param{gi} = load(fullfile(outputdir, ['HBI_DetRanNoiseR1' suffix{gi} '_samples.mat'])).samples;
end
%% posterior
sz = [0.02 0.02;
    0.06 0.02];
for gii = 1:length(suffix)
    plt.set_pltsetting('savesfx', suffix{gii});
    old = plt.param_plt.fontsize_title;
    plt.param_plt.fontsize_title = 15;
    plt.param_plt.pixel_h = 150;
    plt.figure(4,2,'is_title', 'all');
    gi = W.mod0(gii, 2);
    plt.setfig('xlim', {[-1 10+10*gi],[-3 8+ gi *4], [-1 10+10*gi], [-3 8 + gi *4], [-1 10+10*gi], [-3 8 + gi *4], [-1 10+10*gi], [-3 8 + gi *4]}, ...
        'ylim', []);
    EEplot_2noise_hyperpriors_2cond(plt, param{gii}, sz(gi,:));
    plt.param_plt.fontsize_title = old;
end
% %% reduced models
% sp = {};
% sp{1} = paramsub{1};
% sp{2} = load(fullfile(outputdir, ['HBI_DetRanNoise_dRonly_samples.mat'])).samples;
% %
% EEplot_2noise_reduced(plt, sp);
%% deterministic noise ratio
for si = 1:length(suffix)
    sp = param{si}; %load(fullfile(outputdir, ['HBI_DetRanNoise_samples.mat'])).samples;
    %%
    det = []; ran = [];
    vardet = [];
    vard = {};
    for ci = 1:2
        for i = 1:2
            ii = (ci*2-2) + i;
            det(ii,:) = reshape(sp.NoiseDet(:,:,i, ci),1,[]);
            ran(ii,:) = reshape(sp.NoiseRan(:,:,i, ci),1,[]);
            vardet(ii,:) = det(ii,:).^2./(det(ii,:).^2 + ran(ii,:).^2);
            W.print('explained variance: %.2f', mean(vardet(ii,:), 'all')*100)
            W.print('explained variance 5%%: %.2f, %.2f', quantile(reshape(vardet(ii,:),1,[]),[0.025 0.975])*100)
        end
        ddet = reshape(sp.dNoiseDet(:,:, ci),1,[]);
        dran = reshape(sp.dNoiseRan(:,:, ci),1,[]);
        vard{ci} = (ddet.^2./(ddet.^2+dran.^2));
    end

    W.print('explained variance: %.2f', mean(vardet(:), 'all')*100)
    W.print('explained variance 5%%: %.2f, %.2f', quantile(reshape(vardet(:),1,[]),[0.025 0.975])*100)

    %% ratio of deterministic vs random noise
    % %% ratio plot (h = 6/h = 1, for ran and det, A and b)
    % plt.figure(4,1,'istitle',0,'rect',[0 0 0.5 0.9],...
    %     'margin',[0.1 0.11 0.02 0.02]);
    % stepsize = 0.04;
    % xbins = [-30:stepsize:30];
    % fns = {'NoiseRan', 'NoiseDet','InfoBonus_mu_n','bias_mu_n'};
    % plt.setfig('legend', {'Random noise', 'Deterministic noise','Information bonus','spatial bias'}, ...
    %     'xlabel', {'','','','ratio of increase (H = 6/H = 1)'}, 'ylabel', {'\sigma_{Ran}','\sigma_{Det}','A','b'},'title','','ytick', '', ...
    %     'xlim', [-10,10]);
    % tt = [];
    % cols = {{'AZred','AZred50'}, {'AZblue','AZblue50'},'AZcactus','AZsand'};
    % for mi = 1:4
    %     plt.ax(mi);
    %     fn = fns{mi};
    %     td = sp.(fn);
    %     if mi >= 3
    %         [tl, tm] = W.JAGS_density((td(:,:,2)./td(:,:,1)), xbins);
    %         plt.plot(tm, tl, [], 'line', 'color', cols{mi});
    %     else
    %         for ci = 1:2
    %             [tl, tm] = W.JAGS_density(td(:,:,2, ci)./td(:,:,1, ci), xbins);
    %             plt.plot(tm, tl, [], 'line', 'color', cols{mi});
    %         end
    %     end
    % end
    % plt.update;
    %% ratio plot (h = 6/h = 1, for ran and det)
    plt.param_plt.pixel_h = 300;
    plt.figure(1,1);
    stepsize = 0.01;
    xbins = [-20:stepsize:20];
    fns = {'NoiseRan', 'NoiseDet'};
    plt.setfig('xlabel', 'noise(H = 6)/noise(H = 1)', 'ylabel', 'posterior density', ...
        'title','','ytick', '', ...
        'xlim', [0,6]);
    plt.setfig_all('legend',{'Random noise', 'Deterministic noise'})
    
    cols = {'AZred', 'AZblue'; 'AZred50', 'AZblue50'};
    for ci = 1:2
        for mi = 1:2
            fn = fns{mi};
            td = sp.(fn);
            [tl, tm] = W.JAGS_density(td(:,:,2, ci)./td(:,:,1, ci), xbins);
            plt.plot(tm, tl, [], 'line', 'color', cols{ci, mi});
        end
    end
    plt.update('ratio',' ');
end