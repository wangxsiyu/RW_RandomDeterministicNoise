function out = EEpreprocess_game_sub_repeatedgame(games)
    games = W.tab_autofieldcombine(games);
    games.choice4 = games.choice(:, 1:4);
    games.reward4 = games.reward(:, 1:4);
    games.c5 = games.choice(:,5);
    out = W.analyze_repeatedgame(games, {'choice4','reward4'}, 'c5');
end