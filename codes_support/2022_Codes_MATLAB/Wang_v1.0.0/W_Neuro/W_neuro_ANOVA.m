classdef W_neuro_ANOVA < handle
    properties
    end
    methods(Static)
        function [output] = neuro_ANOVA(data, savename, factornames, factorfieldnames, model, window_support, alpha, loginterval)
            if ~exist('alpha', 'var') || isempty(alpha)
                alpha = 0.05;
            end
            if ~exist('loginterval', 'var') || isempty(loginterval)
                loginterval = 50;
            end
            if ~exist('factorfieldnames', 'var') || isempty(factorfieldnames)
                factorfieldnames = factornames;
            end
            if ~exist('model', 'var') || isempty(model)
                model = eye(length(factornames));
            end
            if ~exist('window_support', 'var') || isempty(window_support)
                window_support = [-Inf, Inf];
            end
            factorfieldnames = W.str2cell(factorfieldnames);
            %% for compatibility with both sessions/single session
            if isfield(data, 'nsession')
                nsession = data.nsession;
            else
                nsession = 1;
            end
            games = W.encell(data.games);
            spikes = data.spikes;
            if nsession == 1 
                spikes = {spikes};
            end
            %%
            anova = struct;
            anova.perc_sig = cell(1, nsession);
            anova.is_sig = cell(1, nsession);
            raw_panova = cell(1, nsession);
            idx_support = find(data.time_at - data.time_window/2 >= window_support(1) & ...
                data.time_at + data.time_window/2 <= window_support(2));
            anova.idx_support = idx_support;
            for si = 1:nsession
                %% load data
                W.print('session %d',si);
                %% compute anova
                factors = W.cellfun(@(x)games{si}.(x), factorfieldnames);
                factors = horzcat(factors{:});
                [raw_panova{si}, anova.anovafactornames] = W.movingwindowANOVA(spikes{si}, factors, factornames, model, loginterval);
                %% summary
                [anova.is_sig{si}, anova.percbin_sig{si}, anova.perc_sig{si}] = W.summary_movingwindowANOVA(raw_panova{si}, [], alpha, idx_support);
%                 spikes{si} = spikes{si}(is_sig);
            end
            raw_panova = W.decell(raw_panova);
%             data.spikes = W.decell(spikes);
            if exist('savename', 'var') && W.is_stringorchar(savename)
                W.save(savename, 'anova', anova, 'raw_panova', raw_panova);
            end
            output = W.struct('anova', anova, 'raw_panova', raw_panova);
        end
        function [p, anovafactornames] = movingwindowANOVA(spikes, factors, factornames, model, loginterval)
            if ~exist('loginterval', 'var')
                loginterval = Inf;
            end
            ncell = length(spikes);
            p = cell(1, ncell);
            for i = 1:ncell
                if mod(i,loginterval) == 0 || i == ncell
                    W.print('anova, at cell# %d/%d', i, ncell);
                end
                x = spikes{i};
                ntime = size(x,2);
                p{i} = NaN(size(model,1), ntime);
                for ti = 1:ntime
                    [p{i}(:,ti), anovafactornames] = anovan(x(:, ti), factors, 'model', model,...
                        'varnames', factornames, 'display','off');
                end
            end
            anovafactornames = string(anovafactornames(2:end-2,1));
        end
        function [is_sig, percbin_sig, perc_sig] = summary_movingwindowANOVA(panova, alpha, alpha_percbin, idx_support)
            % support indicies (only neurons significant above chance
            % during these time points are used)
            if ~exist('alpha', 'var') || isempty(alpha)
                alpha = 0.05;
            end
            sig_anova = W.cellfun(@(x)x < alpha, panova);
            if exist('idx_support', 'var') && ~isempty(idx_support)
                percbin_sig = W.cellfun(@(x)mean(x(:,idx_support),2), sig_anova, false);
                percbin_sig = horzcat(percbin_sig{:});
                % at least alpha percent significant in the time window
                % selected across all factors
            else
                percbin_sig = W.cellfun(@(x)mean(x,2), sig_anova, false);
                percbin_sig = horzcat(percbin_sig{:});
            end
            percbin_sig = mean(percbin_sig);
            is_sig = percbin_sig > alpha_percbin;
            perc_sig = W.cell_mean(sig_anova(is_sig));
        end
    end
end