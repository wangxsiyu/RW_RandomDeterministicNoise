classdef W_JAGS_EE2noise < handle
    properties
       poolobj
       bayes_params
       workingdir
       outputdir
       outfile
       modelfile
       params
       init0
       data
       str_test
    end
    methods
        function obj = W_JAGS()
            obj.setup_params(4, 1000, 1000);
            obj.setup_data_dir([], './');
            if ismac
                obj.workingdir = '~/Documents/Jags';
            elseif ispc
                obj.workingdir = 'C:\Temp';
            end
            if ~exist(obj.workingdir, 'dir')
                mkdir(obj.workingdir);
            end
            obj.openpool;
        end
        function run(obj)
            nchains = obj.bayes_params.nchains;
            init0 = repmat(obj.init0, 1, nchains);
            outfile = fullfile(obj.outputdir, strcat(obj.str_test,obj.outfile));
            if exist(strcat(outfile,'_stat.mat')) == 2
                disp(sprintf('file exist, skipped:%s', strcat(outfile,'_stat.mat')));
            else
                obj.openpool;
                [samples, stats, tictoc] = obj.fit_matjags(obj.modelfile, obj.data, init0, obj.bayes_params, obj.params);
                save(strcat(outfile,'_stat.mat'),'stats','tictoc');
                save(strcat(outfile,'_samples.mat'),'samples','-v7.3');
            end
        end
        function [samples, stats, tictoc] = fit_matjags(obj, modelfile, datastruct, init0, bayes_params, params)
            doparallel = 1; % use parallelization
            fprintf( 'Running JAGS...\n' );
            tic
            [samples, stats] = matjags( ...
                datastruct, ...                     % Observed data
                char(modelfile), ...    % File that contains model definition
                init0, ...                          % Initial values for latent variables
                'doparallel' , doparallel, ...      % Parallelization flag
                'nchains', bayes_params.nchains,...              % Number of MCMC chains
                'nburnin', bayes_params.nburnin,...              % Number of burnin steps
                'nsamples', bayes_params.nsamples, ...           % Number of samples to extract
                'thin', 1, ...                      % Thinning parameter
                'monitorparams', params, ...     % List of latent variables to monitor
                'savejagsoutput' , 0 , ...          % Save command line output produced by JAGS?
                'verbosity' ,1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
                'cleanup' , 1 ,...
                'workingdir' , obj.workingdir);                    % clean up of temporary files?
            tictoc = toc
        end
        function setup(obj, modelfile, params, init0, outfile)
            if ~exist('outfile') || isempty(outfile)
                [~, outfile] = fileparts(modelfile);
            end
            obj.modelfile = W_basic.file_enext(modelfile, 'txt');
            obj.params = params;
            obj.init0 = init0;
            obj.outfile = W_basic.file_deext(outfile);
        end
        function setup_params(obj, nchains, nburnin, nsamples)
            if nargin < 4
                warning('JAGS: testing mode on');
                obj.str_test = "test_HBI_";
                bayes_params = [];
                bayes_params.nchains = 2; % How Many Chains?
                bayes_params.nburnin = 1; % How Many Burn-in Samples?
                bayes_params.nsamples = 1; % How Many Recorded Samples?
            else
                obj.str_test = "HBI_";
                bayes_params = [];
                bayes_params.nchains = nchains; % How Many Chains?
                bayes_params.nburnin = nburnin; % How Many Burn-in Samples?
                bayes_params.nsamples = nsamples; % How Many Recorded Samples?
            end
            obj.bayes_params = bayes_params;
        end
        function setup_data_dir(obj, data, outputdir)
            obj.data = data;
            outputdir = W_basic.file_deext(outputdir);
            if outputdir == ""
                outputdir = './';
            end
            if ~exist(outputdir, 'dir')
                mkdir(outputdir);
            end
            obj.outputdir = outputdir;
        end
        function openpool(obj)
            nchains = obj.bayes_params.nchains;
            poolobj = gcp('nocreate'); % If no pool, do not create new one.
            if isempty(poolobj)
                poolsize = 0;
            else
                poolsize = poolobj.NumWorkers;
            end
            if poolsize == 0
                if exist('nchains')
                    parpool(nchains, 'IdleTimeout', Inf);
                else
                    parpool('IdleTimeout', Inf);
                end
            end
            obj.poolobj = poolobj;
        end
        function closepool(obj)
            delete(obj.poolobj);
        end
    end
end