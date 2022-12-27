classdef W_tools_JAGS < handle
    properties
    end
    methods(Static)
        function [ty, tx] = JAGS_density(samples, bin)
            samples = reshape(samples, 1, []);
            [ty, tx] = hist(samples, bin);
            ty = ty./length(samples)./mean(diff(bin));
        end
        function [out, tm] = JAGS_density_bydim(var, bin, conddim)
            if ~exist('conddim', 'var') || isempty(conddim)
                [out, tm] = W.JAGS_density(var, bin);
            else
                sz = size(var);
                out = cell(sz(conddim));
                od = [conddim, setdiff(1:length(sz), conddim)];
                var = permute(var, od);
                conddim = 1:length(conddim);
                sz = sz(od);
                indices = ones(1, length(conddim));
                while all(indices <= sz(1:length(conddim)))
                    tv = var;
                    i = 1;
                    while i <= length(conddim)
                        tv = reshape(tv(i,:), sz(i+1:end));
                        i = i + 1;
                    end
                    outid = W.arrayfun(@(x)x, indices, false);
                    outid = sub2ind(size(out), outid{:});
                    [out{outid}, tm] = W.JAGS_density(tv, bin);
                    % move indices to the next
                    j = length(indices);
                    indices(j) = indices(j) + 1;
                    while j > 1
                        if indices(j) > sz(j)
                            indices(j) = 1;
                            indices(j-1) = indices(j-1) + 1;
                        end
                        j = j - 1;
                    end
                end
            end
        end
    end
end