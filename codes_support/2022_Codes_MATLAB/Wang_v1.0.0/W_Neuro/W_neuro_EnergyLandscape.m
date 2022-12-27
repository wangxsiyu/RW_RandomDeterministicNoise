classdef W_neuro_EnergyLandscape < handle
    properties
    end
    methods(Static)
        function [EL, x_at, tm_EL, conds, grad] = neuro_EnergyLandscape(x1D, condID, xbins, npool, nstep, time_at)
            if ~exist('npool', 'var')
                npool = 1;
            end
            if ~exist('nstep', 'var')
                nstep = 1;
            end
            conds = W.unique(condID, 0);
            for ci = 1:length(conds)
                idx = condID == conds(ci);
                for bi = 1:(size(x1D,2)-npool+1-nstep)
                    ty = x1D(idx,(bi+nstep):(bi+npool-1+nstep));
                    tx = x1D(idx, bi :(bi+npool-1));
                    tdx = ty - tx;
                    x = reshape(tx,[],1);
                    dx = reshape(tdx,[],1);
                    [EL{ci}(bi,:), x_at(bi,:), grad{ci}(bi,:)] = W.calc_EnergyLandscape(x, dx, xbins);
                    tm_EL(bi) = mean([time_at(bi:(bi+npool-1)), ...
                        time_at((bi:(bi+npool-1)) + nstep)]);
                end
            end
            x_at = mean(x_at, 'omitnan');
        end
        function [EL, x_middle, grad, nn] = calc_EnergyLandscape(x, dx, xbins, reference0)
            qq = [];
            if ~exist('reference0', 'var')
                reference0 = 0;
            end
            if ~exist('xbins', 'var')
                xbins = linspace(-max(abs(x)),max(abs(x)), 100);
            end
            x_middle = W.bin_middle(xbins);
            [grad, ~, nn] = W.bin_avY_byX(dx, x, xbins);
            idxnan = isnan(grad);
            grad(idxnan) = 0; % set grad at no-data bins to be 0 (can change to interpolate)
            EL = cumsum(grad);
            idx0 = arrayfun(@(x)dsearchn(x_middle', x), reference0);
            EL0 = mean(EL(idx0));
            EL = EL - EL0;
            EL = -EL;
        end
    end
end
