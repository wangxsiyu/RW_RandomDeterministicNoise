classdef W_neuro_PCA < handle
    properties
    end
    methods(Static)
        function out = convert_NcellMK2KcellMN(x)
            N = length(x);
            [M, K] = size(x{1});
            % N cell{M x K} -> K cell{M x N}
            out = cell(1, K);
            for ki = 1:K
                out{ki} = NaN(M, N);
                for ni = 1:N
                    out{ki}(:,ni) = x{ni}(:, ki);
                end
            end
        end
        function [pc, r2] = neuro_PCA(st, cond2av, idx_time)
            st = W.convert_NcellMK2KcellMN(st);
            if ~exist('idx_time', 'var') || isempty(idx_time)
                idx_time = 1:length(st);
            end
            %% compute mean activity by condition
            avst = W.cellfun(@(x)W.analysis_av_bygroup(x, cond2av), ...
                st(idx_time), false);
            %% compute averages by cue
            pcx = vertcat(avst{:});
            %% pca
            [coeff,score,~,~, r2, mu] = pca(pcx);
            %% get pcs
            pc = W.cellfun(@(x)(x - mean(pcx,'omitnan')) * coeff, st);
        end
    end
end