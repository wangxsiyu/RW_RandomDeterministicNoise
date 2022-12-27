classdef W_analysis_basic < handle
    properties
    end
    methods(Static)
        %% basic
        function [av, se, n] = avse(a, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if ismedian
                av = median(a, 1, 'omitnan');
                n = sum(~isnan(a),1);
                se = av * NaN;
            else
                av = mean(a,1,'omitnan');
                n = sum(~isnan(a),1);
                se = std(a,[],1,'omitnan')./sqrt(n);
            end
        end
        %% get weights
        function out = weighted_sum(a, w)
            id = ~isnan(a) & ~isnan(w);
            a = a(id);
            w = w(id);
            w = w./sum(w);
            out = sum(a .* w);
        end
        %% simple funcs
        function H = entropy_bernoulli(p)
            if p == 0 || p == 1
                H = 0;
            else
                H = (-p*log(p)-(1-p)*log(1-p))/log(2);
            end
        end
        function Hs = entropys_bernoulli(ps)
            Hs = arrayfun(@(x)W.entropy_bernoulli(x), ps);
        end
    end
end