function game = EEpreprocess_game_basic(game)
    game = W.tab_autofieldcombine(game);
%     game = game(diff(game.trueMean')' < 30,:);
    fn_game = fields(game);
    c = game.choice;
    r = game.reward;
    % get condition
    game.cond_horizon = sum(~isnan(c), 2);
    % reaction time - NEED MORE WORK, technically RT = timeKeyPress -
    %       previous timeRewardOn
    if ~any(strcmp(fn_game, 'RT')) && any(strcmp(fn_game, 'timeBanditOn')) && any(strcmp(fn_game, 'timeKeyPress'))
        game.RT = game.timeKeyPress - game.timeBanditOn;
    end
    % mean reward
    var1 = {'rewardL', 'rewardR'};
    var2 = {'cumChoiceL', 'cumChoiceR'};
    var3 = {'avRewardL', 'avRewardR'};
    for i = 1:2 %bandit number
        reward_side{i} = r.*(c == i);
        reward_side{i}(isnan(c)) = NaN;
        game.(var1{i}) = reward_side{i};
        %%gained reward
        cumR{i} = cumsum(reward_side{i},2);
        cumC{i} = cumsum(c == i,2) + 0*c;
        game.(var2{i}) = cumC{i};
        %%mean reward
        avR{i} = cumR{i}./cumC{i};
        game.(var3{i}) = avR{i};
    end
    % diff of reward
    game.dR = avR{2} - avR{1};
    game.dcumC = cumC{2} - cumC{1};
    game.dI = -sign(game.dcumC(:,4)); % more informative
    %%choice low mean
    lm = onetwoX(-sign(game.dR));
    game.side_lm = lm;
    c_lm = 1 - abs(lm(:,1:end-1) - c(:,2:end));
    game.c_lm = [NaN(size(c_lm,1),1) c_lm];
    %%choice high info
    hi = onetwoX(-sign(game.dcumC));
    game.side_hi = hi;
    c_hi = 1 - abs(hi(:,1:end-1) - c(:,2:end));
    game.c_hi = [NaN(size(c_hi,1),1) c_hi];
    %%choice repeat(repeat previous one)
    c_rp = 1 - abs(c(:,2:end) - c(:, 1:end-1));
    game.c_rp = [NaN(size(c_rp,1),1), c_rp];
    %%accuracy
    game.side_correct = onetwoX(sign(diff(game.trueMean')'));
    game.c_correct = 1 - abs(c - game.side_correct);
    %%pattern analysis
    tp_choice = game.choice(:,1:4)-1;
    game.choicepattern_side = tp_choice * [8 4 2 1]';
    % 1 - LLLR
    % 2 - LLRL
    % 3 - LLRR
    % 4 - LRLR
    % 5 - LRLR
    % 6 - LRRL
    % 7 - LRRR
    % 8 - RLLL
    % 9 - RLLR
    % 10 - RLRL
    % 11 - RLRR
    % 12 - RRLL
    % 13 - RRLR
    % 14 - RRRL
    tp_choice(tp_choice(:,1) == 0,:) = 1 - tp_choice(tp_choice(:,1) == 0,:);
    game.choicepattern = tp_choice * [0 4 2 1]';
    % 0 - RLLL
    % 1 - RLLR
    % 2 - RLRL
    % 3 - RLRR
    % 4 - RRLL
    % 5 - RRLR
    % 6 - RRRL
end
function a = onetwoX(a)
    a(a == 0) = NaN;
    a = round((a + 3)/2);
end
