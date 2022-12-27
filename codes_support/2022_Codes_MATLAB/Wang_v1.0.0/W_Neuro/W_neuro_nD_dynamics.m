classdef W_neuro_nD_dynamics < handle
    properties
    end
    methods(Static)
        function [params, time_md] = fit_nDdynamics(modelname, xnD, time_at, npool, nstep, varargin)
            func = eval(sprintf('@W.fit_nD_%s', modelname));
            ntime = length(xnD);
            vars = W.cellfun(@(x)repmat(x, npool, 1), varargin, false);
            params = struct;
            for bi = 1:(ntime-npool+1-nstep)
                W.print('time bin %d', bi);
                x = vertcat(xnD{bi:(bi+npool-1)});
                y = vertcat(xnD{(bi+nstep):(bi+npool-1+nstep)});
                tparam = func(x, y, vars{:});
                params = W.struct_append(params, tparam);
                time_md(bi) = mean(time_at(bi:(bi+npool-1)));
            end
        end
        function [params] = fit_nD_dynamics_linear(x, y, a_cond, x0_cond)
            a_conds = W.unique(a_cond,0);
            na = length(a_conds);
            dummy_x0 = dummyvar(x0_cond);
            a = cell(1, na);
            b = cell(1, na);
            for ci = 1:na
                tid = a_cond == a_conds(ci);
                ty = y(tid,:);
                tx = [x(tid,:) dummy_x0(tid,:)];
                beta = mvregress(tx, ty);
                d = size(beta,2);
                a{ci} = eye(d) - beta(1:d, 1:d);
                b{ci} = beta(end-1:end,:);
            end
            params.a = a;
            params.b = b;
        end
    end
end