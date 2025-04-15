function out = EEanalysis_sub_MLEbasic(game)
    X0.additionalX = [0];
    LB.additionalX = [-100];
    UB.additionalX = [100];
    for hi = 1:2
        idxh = game.cond_horizon == hi*5;
        c5 = game.choice(idxh,5);
        dR = game.dR(idxh,4);
        dI = game.dI(idxh);
        xfit = W_analysis_MLE.MLEfit_choicecurve((c5 == 2) + 0, dR, dI, 1, [0 0], X0, LB, UB, 1);
        out.MLE_noise(hi) = xfit.noise;
        out.MLE_infobonus(hi) = xfit.additionalX;
        out.MLE_bias(hi) = xfit.bias;


        xfit = fit_choicecurve_bycond((c5 == 2) + 0, dR, dI);
        out.MLE2_noise13(hi) = xfit.noise13;
        out.MLE2_noise22(hi) = xfit.noise22;
        out.MLE2_infobonus(hi) = xfit.infobonus;
        out.MLE2_bias(hi) = xfit.bias;
    end
    out.MLE_dnoise = out.MLE_noise(2) - out.MLE_noise(1);
    out.MLE_dinfobonus = out.MLE_infobonus(2) - out.MLE_infobonus(1);
    out.isshow_infobonus = out.MLE_dinfobonus > 0;
    out.isshow_noise = out.MLE_dnoise > 0;
    out.MLE_dbias = out.MLE_bias(2) - out.MLE_bias(1);
end

function [xfit, negLLbest] = fit_choicecurve_bycond(choice, dR, dI)
    options = optimoptions('fmincon', 'Display', 'notify');
    problems.options = options;
    X0 = [1,1, 0, 0];
    LB = [0,0, -100, -100];
    UB = [100,100, 100, 100];
    negLLbest = Inf;
    xfit = [];
    nX0 = 1;
    for repi = 1:nX0
        % needs to implement multiple initial point
        problems.x0 = X0;
        problems.LB = LB;
        problems.UB = UB;
        problems.solver = 'fmincon';
        problems.objective = @(x)-logLL_choicecurve(choice, dR, dI, x(1),x(2),x(3),x(4));
        [xfit_raw, negLL] = fmincon(problems);
        if negLL < negLLbest
            negLLbest = negLL;
            xfit.noise13 = xfit_raw(1);
            xfit.noise22 = xfit_raw(2);
            xfit.infobonus = xfit_raw(3);
            xfit.bias = xfit_raw(4);
        end
    end
end
function [LL] = logLL_choicecurve(choice, dR, dI, noise13, noise22, infobonus, bias)
    noise = (dI == 0) * noise22 + (dI ~= 0) * noise13;
    q = dR + infobonus * dI + bias;
    p = 1./(1 + exp(-q./noise));
    p(choice == 0) = 1 - p(choice == 0);
    logp = log(p);
    logp = logp(~isnan(logp));
    if any(abs(logp) == Inf)
        logp = logp(abs(logp) < Inf); % this may lead to issues, need to look into this later
        %                 W.warning('undefined at initial point, remove -Inf');
    end
    LL = sum(logp);
end