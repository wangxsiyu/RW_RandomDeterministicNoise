function info = EEbayes_analysis(bayes_data, nchains)
    paths = strsplit(path, ';');
    pid = find(contains(string(paths), 'HBI_models'));
    mdpath = paths{pid};
    if ~exist('nchains', 'var')
        nchains = 4;
    end
    md = bayes_data.modelname;
    switch md
%         case 'simplemodel'
%             modelfile = fullfile(mddir, 'HBayesModel_simple.txt');
%             params = {'kNoise_p','lamdaNoise_p','Noise',...
%                 'A_n','dA_p','b_n','db_p','dNs',...
%                 'As','bs'};  
        case 'testretest'
            params = {'NoiseRan_mu_n', 'NoiseRan_sigma_p', ...
                'InfoBonus_mu_n','InfoBonus_sigma_p','bias_mu_n','bias_sigma_p', ...
                'NoiseRan_sub', 'Infobonus_sub','bias_sub',...
                'r_A', 'r_b', 'r_sigma',  ...
                'p'};
            init0 = get_bayesinit(params, nchains, 'simple2');
            modelfile = ['model_testretest.txt'];
        case {'2noisemodel_nobias'}
            params = {'NoiseDet_k_p','NoiseDet_lambda_p','NoiseDet',...
                'NoiseRan_k_p', 'NoiseRan_lambda_p','NoiseRan', ...
                'InfoBonus_mu_n','InfoBonus_sigma_p', ...
                'NoiseRan_sub','NoiseDet_sub', 'Infobonus_sub',...
                'dInfoBonus','dNoiseRan','dNoiseDet','dNoiseRan_sub','dNoiseDet_sub',...
                'P'};
            init0 = get_bayesinit(params, nchains, 'simple');
            modelfile = ['model_2noise' md(12:end) '.txt'];
        case {'2noisemodel_dRonly','2noisemodel_0model'}
            params = {'NoiseDet_k_p','NoiseDet_lambda_p','NoiseDet',...
                'NoiseRan_k_p', 'NoiseRan_lambda_p','NoiseRan', ...
                'NoiseRan_sub','NoiseDet_sub', ...
                'dNoiseRan','dNoiseDet','dNoiseRan_sub','dNoiseDet_sub',...
                'P'};
            init0 = get_bayesinit(params, nchains, 'simple');
            modelfile = ['model_2noise' md(12:end) '.txt'];
        case {'2noisemodel','2noisemodelB','2noisemodelC','2noisemodelD',...
                '2noisemodel_dIonly'}
            params = {'NoiseDet_k_p','NoiseDet_lambda_p','NoiseDet',...
                'NoiseRan_k_p', 'NoiseRan_lambda_p','NoiseRan', ...
                'InfoBonus_mu_n','InfoBonus_sigma_p','bias_mu_n','bias_sigma_p', ...
                'NoiseRan_sub','NoiseDet_sub', 'Infobonus_sub','bias_sub',...
                'dInfoBonus','dbias','dNoiseRan','dNoiseDet','dNoiseRan_sub','dNoiseDet_sub',...
                'P'};
            init0 = get_bayesinit(params, nchains, 'simple');
            modelfile = ['model_2noise' md(12:end) '.txt'];
        case {'2noisemodelE'}
            params = {'NoiseRan_k_p', 'NoiseRan_lambda_p','NoiseRan', ...
                'InfoBonus_mu_n','InfoBonus_sigma_p','bias_mu_n','bias_sigma_p', ...
                'NoiseRan_sub','Infobonus_sub','bias_sub',...
                'dInfoBonus','dbias','dNoiseRan','dNoiseRan_sub',...
                'P'};
            init0 = get_bayesinit(params, nchains, 'simple');
            modelfile = ['model_2noiseE.txt'];
        case {'2noisemodelF'}
            params = {'NoiseDet_k_p','NoiseDet_lambda_p','NoiseDet',...
                'InfoBonus_mu_n','InfoBonus_sigma_p','bias_mu_n','bias_sigma_p', ...
                'NoiseDet_sub', 'Infobonus_sub','bias_sub',...
                'dInfoBonus','dbias','dNoiseDet','dNoiseDet_sub',...
                'P'};
            init0 = get_bayesinit(params, nchains, 'simple');
            modelfile = ['model_2noiseF.txt'];
            
    end
    info.init0 = init0;
    info.params = params;
    info.modelfile = fullfile(mdpath, modelfile);
end
function init0 = get_bayesinit(params, nchains, option)
    switch option
        case 'simple' % works for variables that are horizon dependent.
            S = [];
            for j = 1:length(params)
                str = params{j};
                if ~isempty(strfind(str,'_p'))
                    S.(str) = ones([1 1]);
                elseif ~isempty(strfind(str,'_n'))
                    S.(str) = zeros([1 1]);
                end
            end
            init0 = S;
            
        case 'simple2'
            for i=1:nchains
                S = [];
                str = params{j};
                if ~isempty(strfind(str,'_p'))
                    S.(str) = ones([2 2]);
                elseif ~isempty(strfind(str,'_n'))
                    S.(str) = zeros([2 2]);
                end
                init0 = S;
            end
    end
end