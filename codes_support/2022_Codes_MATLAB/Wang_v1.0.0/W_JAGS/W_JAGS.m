classdef W_JAGS < handle
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
       isoverwrite
       isdoparallel
    end
    methods
        function obj = W_JAGS()
            obj.isoverwrite = false;
            obj.setup_params(2, 1, 1);
            obj.setup_data_dir([], './');
            obj.isdoparallel = 1;
            if ismac
                obj.workingdir = W.mkdir('~/Documents/Jags');
            elseif ispc
                obj.workingdir = W.mkdir('C:\Users\Siyu_Wang\Documents\TEMP\JAGS');
            end
        end
        function run(obj)
            nchains = obj.bayes_params.nchains;
            init0 = repmat(obj.init0, 1, nchains);
            outfile = fullfile(obj.outputdir, strcat(obj.str_test,obj.outfile));
            if exist(strcat(outfile,'_stat.mat'), 'file') && ~obj.isoverwrite
                W.print('file exist, skipped:%s', strcat(outfile,'_stat.mat'));
            else
                if obj.isdoparallel
                    obj.openpool;
                end
                [samples, stats, tictoc] = obj.fit_matjags(obj.modelfile, obj.data, init0, obj.bayes_params, obj.params);
                save(strcat(outfile,'_stat.mat'),'stats','tictoc');
                save(strcat(outfile,'_samples.mat'),'samples','-v7.3');
            end
        end
        function [samples, stats, tictoc] = fit_matjags(obj, modelfile, datastruct, init0, bayes_params, params)
            doparallel = obj.isdoparallel; % use parallelization
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
            if ~exist('outfile', 'var') || isempty(outfile)
                [~, outfile] = fileparts(modelfile);
            end
            obj.modelfile = W.enext(modelfile, 'txt');
            obj.params = params;
            obj.init0 = init0;
            obj.outfile = W.deext(outfile);
        end
        function setup_params(obj, nchains, nburnin, nsamples)
            if nargin < 4
                W.warning('JAGS: testing mode on');
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
            outputdir = W.deext(outputdir);
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
            poolobj = W.parpool(nchains);
            obj.poolobj = poolobj;
        end
        function closepool(obj)
            W.parclose;
        end
    end
end