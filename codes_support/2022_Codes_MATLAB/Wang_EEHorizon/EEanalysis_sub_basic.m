function out = EEanalysis_sub_basic(game)
    horizons = [5 10];
    c5 = game.choice(:,5);
    c5_lm = game.c_lm(:,5);
    c5_hi = game.c_hi(:,5);
    c5_rp = game.c_rp(:,5);
    c5_ac = game.c_correct(:,5);

    dR4 = game.dR(:,4);

    dR4I = dR4 .* game.dI;
    dR4I(dR4I == 0) = NaN;
    % choice curves
    bin = [-30:5:30]' + [-5 5];
    out.bin = bin;

    for hi = 1:length(horizons)
        idx_h = game.cond_horizon == horizons(hi);
        % basic directed/random, repeat
        VAR16_n_game = sum(idx_h);
        idx_22 = game.dI == 0;
        idx_13 = game.dI ~= 0;

        out.hiishm(hi) = mean(game.dR(idx_h & idx_13,4).*game.dI(idx_h & idx_13) >0);

        out.p_hi13(hi) = mean(c5_hi(idx_h & idx_13));
        out.p_hi13_reduced(hi) = out.p_hi13(hi) - out.hiishm(hi);
        out.p_lm13(hi) = nanmean(c5_lm(idx_h & idx_13));
        out.p_lm22(hi) = nanmean(c5_lm(idx_h & idx_22));

        out.p_hi13_od1(hi) = mean(c5_hi(idx_h & idx_13 & game.repeat_order == 1));
        out.p_lm22_od1(hi) = nanmean(c5_lm(idx_h & idx_22 & game.repeat_order == 1));
        out.p_hi13_od2(hi) = mean(c5_hi(idx_h & idx_13 & game.repeat_order == 2));
        out.p_lm22_od2(hi) = nanmean(c5_lm(idx_h & idx_22 & game.repeat_order == 2));

        ratio = game.gameNumber/max(game.gameNumber);
        isr = ismember(game.repeat_order, [1 2]);
        out.p_hi13_h1(hi) = mean(c5_hi(idx_h & idx_13 & ratio <= .5 & isr));
        out.p_lm22_h1(hi) = nanmean(c5_lm(idx_h & idx_22 & ratio <= .5& isr));
        out.p_hi13_h2(hi) = mean(c5_hi(idx_h & idx_13 & ratio > .5 & isr));
        out.p_lm22_h2(hi) = nanmean(c5_lm(idx_h & idx_22 & ratio > .5 & isr));

        out.p_lm(hi) = nanmean(c5_lm(idx_h));
        out.p_rp13(hi) = nanmean(c5_rp(idx_h & idx_13));
        out.p_rp22(hi) = nanmean(c5_rp(idx_h & idx_22));
        out.p_rp(hi) = nanmean(c5_rp(idx_h));
        VAR16_all_p_hi = nanmean(game.c_hi(idx_h, :),1);
        VAR16_all_p_lm = nanmean(game.c_lm(idx_h, :),1);
        VAR16_all_p_ac = nanmean(game.c_correct(idx_h, :),1);
        VAR16_all_p_rp = nanmean(game.c_rp(idx_h, :),1);
        VAR16_all_RT = nanmean(game.RT(idx_h,:),1);
        % repeat trial analysis
        if any(strcmp(fieldnames(game),'c_repeatagree2_c5'))
            out.p_inconsistent13(hi) = W.extend(nanmean(game.c_repeatagree2_c5(idx_h & idx_13) == 0,1),1);
            out.p_inconsistent22(hi) = W.extend(nanmean(game.c_repeatagree2_c5(idx_h & idx_22) == 0,1),1);
            out.p_inconsistent(hi) = W.extend(nanmean(game.c_repeatagree2_c5(idx_h) == 0,1),1);
            % theory
            out.p_inconsistent13_randomtheory(hi) = 2 * out.p_lm13(hi) * (1-out.p_lm13(hi));
            out.p_inconsistent22_randomtheory(hi) = 2 * out.p_lm22(hi) * (1-out.p_lm22(hi));
            out.p_inconsistent_randomtheory(hi) = 2 * out.p_lm(hi) * (1-out.p_lm(hi));
            % number of pairs
            out.n_repeatedpairs = sum(game.repeat_totaltimes == 2);
        end
        % pattern analysis
        for pi = 1:7
            idx_p = game.choicepattern == pi-1;
            VAR16_Pattern_p_hi(pi) = nanmean(c5_hi(idx_h & idx_p));
            VAR16_Pattern_p_lm(pi) = nanmean(c5_lm(idx_h & idx_p));
            VAR16_Pattern_p_rp(pi) = nanmean(c5_rp(idx_h & idx_p));
            VAR16_Pattern_RT(pi) = nanmean(game.RT(idx_h & idx_p,5));
        end
        % choice curve
        [VAR16_choicecurve_ac, ~, VAR16_n_choicecurve_ac] = W.bin_avY_byX(c5_ac(idx_h), dR4(idx_h), bin);
        [VAR16_choicecurve_R, ~, VAR16_n_choicecurve_R] = W.bin_avY_byX(c5(idx_h)  == 2, dR4(idx_h), bin);
        [VAR16_choicecurve_hi, ~, VAR16_n_choicecurve_hi] = W.bin_avY_byX(c5_hi(idx_h), dR4I(idx_h), bin);
        [VAR16_choicecurve_lm, ~, VAR16_n_choicecurve_lm] = W.bin_avY_byX(c5_lm(idx_h), dR4(idx_h), bin);
        [VAR16_choicecurve_RT, ~, VAR16_n_choicecurve_RT] = W.bin_avY_byX(game.RT(idx_h,5), dR4(idx_h), bin);

        if any(strcmp(fieldnames(game),'c_repeatagree2_c5'))
%             [VAR16_choicecurve_lm13, ~, VAR16_n_choicecurve_lm13] = W.bin_avY_byX(c5_lm(idx_h & idx_13), dR4(idx_h & idx_13), bin);
%             VAR16_choicecurve_lm13_randomtheory = 2 * VAR16_choicecurve_lm13 .* (1-VAR16_choicecurve_lm13);
%             out.p_inconsistent13_randomtheory_byR(hi) = W.weighted_sum(VAR16_choicecurve_lm13_randomtheory, VAR16_n_choicecurve_lm13);
            
%             bin2 = [-30:10:30]' + [-10 10];
%             [tlm131, ~, tnlm131] = W.bin_avY_byX(c5_lm(idx_h & game.dI<0), dR4(idx_h & game.dI<0), bin2);
%             [tlm132, ~, tnlm132] = W.bin_avY_byX(c5_lm(idx_h & game.dI>0), dR4(idx_h & game.dI>0), bin2);
%             VAR16_choicecurve_lm13I = [tlm131 tlm132];
%             VAR16_n_choicecurve_lm13I = [tnlm131 tnlm132];
%             VAR16_choicecurve_lm13_randomtheory_byI = 2 * VAR16_choicecurve_lm13I .* (1-VAR16_choicecurve_lm13I);
%             out.p_inconsistent13_randomtheory_byRI(hi) = W.weighted_sum(VAR16_choicecurve_lm13_randomtheory_byI, VAR16_n_choicecurve_lm13I);

            tc5_lm = [c5_lm(idx_h & game.dI<0); c5_lm(idx_h & game.dI>0)];
            tdR4 = [dR4(idx_h & game.dI<0); -dR4(idx_h & game.dI>0)];
            [VAR16_choicecurve_lm13, ~, VAR16_n_choicecurve_lm13] = W.bin_avY_byX(tc5_lm, tdR4, bin);
            VAR16_choicecurve_lm13_randomtheory = 2 * VAR16_choicecurve_lm13 .* (1-VAR16_choicecurve_lm13);
            out.p_inconsistent13_randomtheory_byR(hi) = W.weighted_sum(VAR16_choicecurve_lm13_randomtheory, VAR16_n_choicecurve_lm13);

            [VAR16_choicecurve_lm22, ~, VAR16_n_choicecurve_lm22] = W.bin_avY_byX(c5_lm(idx_h & idx_22), dR4(idx_h & idx_22), bin);
            VAR16_choicecurve_lm22_randomtheory = 2 * VAR16_choicecurve_lm22 .* (1-VAR16_choicecurve_lm22);
            out.p_inconsistent22_randomtheory_byR(hi) = W.weighted_sum(VAR16_choicecurve_lm22_randomtheory, VAR16_n_choicecurve_lm22);
        end

        % variables with different names for long/short horizons
        Vars = who;
        Vars = Vars(cellfun(@(x)length(strfind(x, 'VAR16')), Vars) == 1);
        Vars = Vars(cellfun(@(x)strfind(x, 'VAR16'), Vars) == 1);
        for vi = 1:length(Vars)
            tVar = Vars{vi};
            out.([tVar(7:end) '_h' num2str(hi*5-4)]) = eval(tVar);
        end
    end
    out.df_p_hi13 = out.p_hi13(2) - out.p_hi13(1);
    out.df_p_lm22 = out.p_lm22(2) - out.p_lm22(1);
    out.df_p_hi13_reduced = out.p_hi13_reduced(2) - out.p_hi13_reduced(1);
    out.isshow_p_hi13 = out.df_p_hi13 >0;
    out.isshow_p_lm22 = out.df_p_lm22 >0;
    out.isshow_p_hi13_reduced = out.df_p_hi13_reduced >0;
    out.p_di = out.p_hi13(:,2) - out.p_hi13(:,1);
    out.p_ra = out.p_lm22(:,2) - out.p_lm22(:,1);


    out.p_ac = nanmean(game.c_correct(:,10));
    n_c10_correct = nansum(game.c_correct(:,10));

    % ac chance, needs check
    nmax = 200;
    pas = abs(pascal(nmax + 1,1));
    w = repmat(1./sum(pas, 2), 1, nmax + 1);
    p = w.*pas;
    cump = cumsum(p,2);
    out.pvalue_ac = 1-cump(out.n_game_h6+1, max(n_c10_correct,1));
end
