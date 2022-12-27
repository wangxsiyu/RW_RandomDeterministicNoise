function game = EEimport_game(data, EEversion)
    % game = EEimport_game(data, EEversion)
    %       Import Horizon Task data
    % by Siyu (sywangr@email.arizona.edu)
    % 05/18/2020
    EEversions = {'timestamp_v1', 'timestamp_v2'};
    if (~exist('EEversion') || ~any(strcmp(EEversion, EEversions)))
        str = sprintf(['Please indicate which version of the Horizon Task the data', ...
            ' to be analyzed is. Here are all the supported versions:\n', ...
            '...timestamp_v1: this is an older version of the horizon task, where RT is saved as timeBanditOn, timePresskey and timeRewardOn\n', ...
            '...timestamp_v2: this is a newer version, where RT is saved in the ''time'' structure']);
        error(str);
    end
    if (isempty(data) || ~isfield(data,'key')) % empty data
        warning('no response data');
        game = [];
        return;
    end
    N = sum(cellfun(@(x)~isempty(x),{data.key})); 
    data = data(1:N);
    game.gameNumber = (1:N)';
    game.n_game = N;
    Mcell = arrayfun(@(x)x.mean',data,'UniformOutput',false);
    game.trueMean = vertcat(Mcell{:});
    % key 1(left), 2(right)
    Keycell = arrayfun(@(x)W.extend(x.key,10), data,'UniformOutput',false);
    game.choice = vertcat(Keycell{:});
    for ri = 1:2
        Rewardcell = arrayfun(@(x)W.extend(x.rewards(ri,:),10),data,'UniformOutput',false);
        rewards{ri} = vertcat(Rewardcell{:});
    end
    game.reward = rewards{1}.*(game.choice == 1) + rewards{2}.*(game.choice == 2);
    switch EEversion
        case 'timestamp_v1'
            Tcell = arrayfun(@(x)W.extend(x.timeBanditOn,10),data,'UniformOutput',false);
            game.timeBanditOn = vertcat(Tcell{:});
            Tcell = arrayfun(@(x)W.extend(x.timePressKey,10),data,'UniformOutput',false);
            game.timeKeyPress = vertcat(Tcell{:});
            Tcell = arrayfun(@(x)W.extend(x.timeRewardOn,10),data,'UniformOutput',false);
            game.timeRewardOn = vertcat(Tcell{:});
        case 'timestamp_v2'
            Tcell = arrayfun(@(x)W.extend([x.time.trial.timeBanditOn],10),data,'UniformOutput',false);
            game.timeBanditOn = vertcat(Tcell{:});
            Tcell = arrayfun(@(x)W.extend([x.time.trial.timePressKey],10),data,'UniformOutput',false);
            game.timeKeyPress = vertcat(Tcell{:});
            Tcell = arrayfun(@(x)W.extend([x.time.trial.timeRewardOn],10),data,'UniformOutput',false);
            game.timeRewardOn = vertcat(Tcell{:});
    end
end