classdef analysis_bayesian < handle
    properties
        data
        xfit
        nchains
        nburnin
        nsamples
        thin
        modelname
        params
        init0
        modelpath
        savepath
        poolobj
        stats
        samples
    end
    methods
        function obj = analysis_bayesian(data, modelpath, savepath)
            obj.poolobj = [];
            obj.savepath = savepath;
            obj.modelpath = modelpath;
            obj.data = data;
            obj.setup_chain;
        end
        function setup_chain(obj)
            obj.nchains = 4; % How Many Chains?
            obj.nburnin = 2000; % How Many Burn-in Samples?
            obj.nsamples = 4000; % How Many Recorded Samples?
            obj.thin = 1;
        end
        function analysis(obj, modelname, params, savename)
            obj.openpool;
            data = obj.data;
            obj.init0 = obj.get_bayesinit(params, obj.nchains, [data.nh, data.nS]);
            modelfile = fullfile(obj.modelpath, [modelname '.txt']);
            disp(['Fitting now:' modelfile]);
            [samples, stats, structArray, tictoc] = obj.fit_matjags(modelfile, data, obj.init0, obj.nchains, obj.nburnin, obj.nsamples, params);
            save(fullfile(obj.savepath, ['result_',savename]),'stats','tictoc','modelname');
            obj.closepool;
            obj.stats = stats;
            obj.samples = samples;
        end
        function init0 = get_bayesinit(obj, params, nchains, msize)
            if nargin < 3
                msize = [1, 1];
            end
            for i=1:nchains
                S = [];
                for j = 1:length(params)
                    str = params{j};
                    if ~isempty(strfind(str,'_p'))
                        S.(str) = ones(msize);
                    elseif ~isempty(strfind(str,'_n'))
                        S.(str) = zeros(msize);
                    end
                end
                init0(i) = S;
            end
        end
        function openpool(obj)
            if isempty(obj.poolobj)
                poolobj = gcp('nocreate'); % If no pool, do not create new one.
                if isempty(poolobj)
                    poolsize = 0;
                else
                    poolsize = poolobj.NumWorkers;
                end
                if poolsize == 0
                    parpool;
                end
                obj.poolobj = poolobj;
            end
        end
        function [samples, stats, structArray, tictoc] = fit_matjags(obj, filename, datastruct, init0, nchains, nburnin, nsamples, params)
            doparallel = 1; % use parallelization
            fprintf( 'Running JAGS...\n' );
            tic
            [samples, stats, structArray] = matjags( ...
                datastruct, ...                     % Observed data
                filename, ...    % File that contains model definition
                init0, ...                          % Initial values for latent variables
                'doparallel' , doparallel, ...      % Parallelization flag
                'nchains', nchains,...              % Number of MCMC chains
                'nburnin', nburnin,...              % Number of burnin steps
                'nsamples', nsamples, ...           % Number of samples to extract
                'thin', 1, ...                      % Thinning parameter
                'monitorparams', params, ...     % List of latent variables to monitor
                'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
                'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
                'cleanup' , 1 );                    % clean up of temporary files?
            tictoc = toc
        end
        function closepool(obj)
            if ~isempty(obj.poolobj)
                delete(obj.poolobj);
            end
        end
    end
end