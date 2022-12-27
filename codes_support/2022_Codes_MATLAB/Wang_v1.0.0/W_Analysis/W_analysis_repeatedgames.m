classdef W_analysis_repeatedgames < handle
    methods(Static)
        function out = analyze_repeatedgame(games, fn, fn_choice)
            if ~iscell(fn)
                fn = {fn};
            end
            d = [];
            for fi = 1:length(fn)
                td = games.(fn{fi});
                d = [d td];
            end
            [out.repeat_id, out.repeat_order, out.repeat_totaltimes] = W.repeatedgames_getrepeatedID(d);
            if ~iscell(fn_choice)
                fn_choice = {fn_choice};
            end
            for fi = 1:length(fn_choice)
                tn = fn_choice{fi};
                out.(['c_repeatagree2_' tn]) = W.repeatedgames_getrepeatedagree(out.repeat_id, games.(tn));
                out.(['c_repeatagree3plus_' tn]) = W.repeatedgames_getrepeatedagree3plus(out.repeat_id, games.(tn));
            end
        end
        function [gID, gIDorder, tot] = repeatedgames_getrepeatedID(d)
            n_trial = size(d,1);
            gID = zeros(n_trial, 1);
            IDi = 0;
            gIDorder = zeros(n_trial, 1);
            tot = NaN(n_trial, 1);
            for gi = 1:n_trial
                if gID(gi) == 0
                    IDi = IDi + 1;
                    gID(gi) = -IDi;
                    gIDorder(gi) = 1;
                    torder = 1;
                    tot(gi,:) = torder;
                    for gj = 1:n_trial
                        if (gID(gj) == 0) && W.repeatedgames_comparetrial(d,gi,gj)
                            torder =  torder + 1;
                            gID(gi) = abs(gID(gi));
                            gID(gj) = gID(gi);
                            gIDorder(gj) = torder;
                            tot(gi,:) = torder;
                            tot(gj,:) = torder;
                        end
                    end
                end
            end
        end
        function same = repeatedgames_comparetrial(d, gi, gj)
            ri = [d(gi,:)];
            rj = [d(gj,:)];
            if all(ri == rj)
                same = true;
            else
                same = false;
            end
        end
        function agree = repeatedgames_getrepeatedagree(ID, key)
            agree = NaN(length(ID), 1);
            for i = 1:length(ID)
                if ID(i) < 0
                    agree(i) = NaN;
                else
                    idx = find(ID == ID(i));
                    cs = arrayfun(@(x)key(x), idx);
                    if length(idx) == 2
                        agree(i) = (length(unique(cs)) == 1) + 0;
                    else
                        agree(i) = NaN;
                    end
                end
            end
        end
        function agree = repeatedgames_getrepeatedagree3plus(ID, key)
            agree = NaN(length(ID), 1);
            for i = 1:length(ID)
                if ID(i) < 0
                    agree(i) = NaN;
                else
                    idx = find(ID == ID(i));
                    cs = arrayfun(@(x)key(x), idx);
                    if length(idx) <= 2
                        agree(i) = NaN;
                    else
                        [tcount] = sum(mode(cs) == cs);
                        agree(i) = tcount/length(cs) + 0;
                        % represent the percentage of times participant choose
                        % consistent choices in these repeated games.
                    end
                end
            end
        end
    end
end