function [gp] = getgpsimu(gamenow, idxsub, simu)
    if exist('simu', 'var') && ~isempty(simu)
        for si = 1:length(idxsub)
            gamenow.choice_5(idxsub{si}) = simu.choice(si,1:simu.nTrial(si))' + 1;
        end    
    end
    opt_preprocess = 'EEpreprocess_game_basic';
    opt_game_sub = {'EEpreprocess_game_sub_repeatedgame'};
    opt_analysis = {'EEanalysis_sub_basic'};
    [sub] = W.analysis_pipeline(gamenow, [], opt_preprocess, opt_game_sub, opt_analysis, [], idxsub);
    gp = W.analysis_1group(sub, [], ...
            {{'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'},...
             {'p_inconsistent13'},{'p_inconsistent22'}});
end

% function [gpsimu,gp] = getgpsimu(simu)
%     game0 = readtable('../data/all/data_all.csv', 'Delimiter', ',');
%     idx = load('../data/all/idxsub_exclude');
%     idxsub = idx.idxsub(idx.id);
%     tid = idx.idxsub(idx.id);
%     game0 = game0(vertcat(tid{:}),:);
%     gamenow = game0;
% 
%     opt_sub = {'subjectID', 'date', 'time'};
%     opt_preprocess = 'EEpreprocess_game_basic';
%     opt_game_sub = {'EEpreprocess_game_sub_repeatedgame'};
%     opt_analysis = {'EEanalysis_sub_basic'};
%     [sub, ~, idxsub] = W.analysis_pipeline(game0, opt_sub, opt_preprocess, opt_game_sub, opt_analysis, []);
%     gp = W.analysis_1group(sub, [], ...
%             {{'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'},...
%              {'p_inconsistent13'},{'p_inconsistent22'}});
%     for si = 1:length(idxsub)
%         gamenow.choice_5(idxsub{si}) = simu.choice(si,1:simu.nTrial(si))' + 1;
%     end
%     [tsimu_sub] = W.analysis_pipeline(gamenow, opt_sub, opt_preprocess, ...
%         opt_game_sub, opt_analysis, [], idxsub);
%     gpsimu = W.analysis_1group(tsimu_sub, [], ...
%         {{'p_inconsistent13','p_inconsistent13_randomtheory_byR'},{'p_inconsistent22','p_inconsistent22_randomtheory_byR'},...
%         {'p_inconsistent13'},{'p_inconsistent22'}});
%     % sgp = struct;
%     % sgp.modelA = W.analysis_1group(vertcat(ttgp, ttgp), false);
% end