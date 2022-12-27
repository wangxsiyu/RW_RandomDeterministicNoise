classdef W_neuro_1D_dynamics < handle
    properties
    end
    methods(Static)
        function [params, time_md] = fit_1Ddynamics(modelname, x1D, time_at, npool, nstep, varargin)
            func = eval(sprintf('@W.fit_%s', modelname));
            ntime = size(x1D, 2);
            vars = W.cellfun(@(x)repmat(x, npool, 1), varargin, false);
            params = struct;
            for bi = 1:(ntime-npool+1-nstep)
                W.print('time bin %d', bi);
                tx = x1D(:, bi:(bi+npool-1));
                ty = x1D(:,(bi+nstep):(bi+npool-1+nstep));
                x = reshape(tx,[],1);
                y = reshape(ty,[],1);
                tparam = func(x, y, vars{:});
                params = W.struct_append(params, tparam);
                time_md(bi) = mean([time_at(bi:(bi+npool-1)), ...
                    time_at((bi:(bi+npool-1)) + nstep)]);
            end
        end
        function [params] = fit_dynamics_scaled_evidence(x, y, ev, a_cond, x0_cond)
            na = length(W.unique(a_cond,0));
            nx0 = length(W.unique(x0_cond,0));
            func = @(t)W.loss_model('dynamics_scaled_evidence', y, ...
                t(1:na), t((1:nx0)+na), t(na + nx0 + 1), x, ev, a_cond, x0_cond);
            X0 = [rand(1,na) zeros(1,nx0) 0];
            LB = [zeros(1,na) -ones(1,nx0)*Inf -Inf];
            UB = [ones(1,na) ones(1,nx0)*Inf Inf];
            xfit = fmincon(func, X0, [],[],[],[], LB, UB);
            params.a = xfit(1:na);
            params.x0 = xfit((1:nx0)+na);
            params.coef_ev = xfit(na + nx0 + 1);
        end
        function [params] = fit_dynamics_fit_evidence(x, y, a_cond, x0_cond, ev_cond)
            na = length(W.unique(a_cond,0));
            nx0 = length(W.unique(x0_cond,0));
            nev = length(W.unique(ev_cond,0));
            func = @(t)W.loss_model('dynamics_fit_evidence', y, ...
                t(1:na), t((1:nx0)+na), t((1:nev) + nx0 + na), x, a_cond, x0_cond, ev_cond);
            X0 = [rand(1,na) zeros(1,nx0) zeros(1,nev)];
            LB = [zeros(1,na) -ones(1,nx0)*Inf -ones(1, nev)*Inf];
            UB = [ones(1,na) ones(1,nx0)*Inf ones(1,nev)*Inf];
            xfit = fmincon(func, X0, [],[],[],[], LB, UB);
            params.a = xfit(1:na);
            params.x0 = xfit((1:nx0)+na);
            params.b_ev = xfit((1:nev) + nx0 + na);
        end
        function [params] = fit_dynamics_linear(x, y, a_cond, b_cond)
            na = length(W.unique(a_cond,0));
            nb = length(W.unique(b_cond,0));
            func = @(t)W.loss_model('dynamics_linear', y, ...
                t(1:na), t((1:nb)+na), x, a_cond, b_cond);
            X0 = [rand(1,na) zeros(1,nb)];
            LB = [zeros(1,na) -ones(1,nb)*Inf];
            UB = [ones(1,na) ones(1,nb)*Inf];
            xfit = fmincon(func, X0, [],[],[],[], LB, UB);
            params.a = xfit(1:na);
            params.b = xfit((1:nb)+na);
        end
        function LL = loss_model(modelname, y, varargin)
            func = eval(sprintf('@W.model_%s', modelname));
            ypred = func(varargin{:});
            LL = sum((y - ypred).^2, [], 'omitnan');
        end
        function out = model_dynamics_scaled_evidence(a, x0, coef_ev, x, ev, a_cond, x0_cond)
            ta = dummyvar(a_cond) * a';
            tx0 = dummyvar(x0_cond) * x0';
            out = x .* (1 - ta) + (ta .* tx0) + ev * coef_ev;
        end
        function out = model_dynamics_fit_evidence(a, x0, b_ev, x, a_cond, x0_cond, ev_cond)
            ta = dummyvar(a_cond) * a';
            tx0 = dummyvar(x0_cond) * x0';
            tev = dummyvar(ev_cond) * b_ev';
            out = x .* (1 - ta) + (ta .* tx0) + tev;
        end
        function out = model_dynamics_linear(a, b, x, a_cond, b_cond)
            ta = dummyvar(a_cond) * a';
            tb = dummyvar(b_cond) * b';
            out = x .* (1 - ta) + tb;
        end
    end
end