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
    end
    out.MLE_dnoise = out.MLE_noise(2) - out.MLE_noise(1);
    out.MLE_dinfobonus = out.MLE_infobonus(2) - out.MLE_infobonus(1);
    out.isshow_infobonus = out.MLE_dinfobonus > 0;
    out.isshow_noise = out.MLE_dnoise > 0;
    out.MLE_dbias = out.MLE_bias(2) - out.MLE_bias(1);
end
