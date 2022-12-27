function bayesdata = EEbayes_reformat(data, idxsub, modelname, maxtrial)
    if ~exist('maxtrial', 'var')
        maxtrial = Inf;
    end
    data = W.tab_autofieldcombine(data);
    bayesdata.modelname = modelname;
    switch modelname
        case '2noisemodel'
            bayesdata.nHorizon = 2;
            bayesdata.nSubject = length(idxsub);
            nT = cellfun(@(x)length(x), idxsub);
            LEN = min(max(nT),maxtrial);
            bayesdata.nForcedTrials = 4;
            for si = 1:bayesdata.nSubject
                gd = data(idxsub{si},:);
                nT = min(size(gd,1), LEN);
                bayesdata.nTrial(si,1) = nT;
                bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN); % 1 is short, 2 is long
                bayesdata.dI(si,:) = W.extend(gd.dI',LEN); % -1, 0, 1
                bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN); % 1 is right, 0 is left
                bayesdata.dR(si,:) = W.extend(gd.dR(:,4)',LEN);
                [~, ~, ranking] = unique(gd.repeat_id);
                bayesdata.nrepeatID(si,1) = max(ranking);
                bayesdata.repeatID(si,:) = W.extend(ranking',LEN);
            end
        case '2noisemodel_paironly'
            bayesdata.nHorizon = 2;
            bayesdata.nSubject = length(idxsub);
            nT = cellfun(@(x)length(x), idxsub);
            LEN = min(max(nT),maxtrial);
            bayesdata.nForcedTrials = 4;
            for si = 1:bayesdata.nSubject
                gd = data(idxsub{si},:);
                gd = gd(gd.repeat_id > 0,:);
                nT = min(size(gd,1), LEN);
                bayesdata.nTrial(si,1) = nT;
                bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN); % 1 is short, 2 is long
                bayesdata.dI(si,:) = W.extend(gd.dI',LEN); % -1, 0, 1
                bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN); % 1 is right, 0 is left
                bayesdata.dR(si,:) = W.extend(gd.dR(:,4)',LEN);
                [~, ~, ranking] = unique(gd.repeat_id);
                bayesdata.nrepeatID(si,1) = max(ranking);
                bayesdata.repeatID(si,:) = W.extend(ranking',LEN);
            end
        case '2noisemodel_dRonly'
            bayesdata.nHorizon = 2;
            bayesdata.nSubject = length(idxsub);
            nT = cellfun(@(x)length(x), idxsub);
            LEN = min(max(nT),maxtrial);
            bayesdata.nForcedTrials = 4;
            for si = 1:bayesdata.nSubject
                gd = data(idxsub{si},:);
                nT = min(size(gd,1), LEN);
                bayesdata.nTrial(si,1) = nT;
                bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN); % 1 is short, 2 is long
                bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN); % 1 is right, 0 is left
                bayesdata.dR(si,:) = W.extend(gd.dR(:,4)',LEN);
                [~, ~, ranking] = unique(gd.repeat_id);
                bayesdata.nrepeatID(si,1) = max(ranking);
                bayesdata.repeatID(si,:) = W.extend(ranking',LEN);
            end
        case '2noisemodel_dIonly'
            bayesdata.nHorizon = 2;
            bayesdata.nSubject = length(idxsub);
            nT = cellfun(@(x)length(x), idxsub);
            LEN = min(max(nT),maxtrial);
            bayesdata.nForcedTrials = 4;
            for si = 1:bayesdata.nSubject
                gd = data(idxsub{si},:);
                nT = min(size(gd,1), LEN);
                bayesdata.nTrial(si,1) = nT;
                bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN); % 1 is short, 2 is long
                bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN); % 1 is right, 0 is left
                bayesdata.dI(si,:) = W.extend(gd.dI',LEN); % -1, 0, 1
                [~, ~, ranking] = unique(gd.repeat_id);
                bayesdata.nrepeatID(si,1) = max(ranking);
                bayesdata.repeatID(si,:) = W.extend(ranking',LEN);
            end
        case '2noisemodel_0model'
            bayesdata.nHorizon = 2;
            bayesdata.nSubject = length(idxsub);
            nT = cellfun(@(x)length(x), idxsub);
            LEN = min(max(nT),maxtrial);
            bayesdata.nForcedTrials = 4;
            for si = 1:bayesdata.nSubject
                gd = data(idxsub{si},:);
                nT = min(size(gd,1), LEN);
                bayesdata.nTrial(si,1) = nT;
                bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN); % 1 is short, 2 is long
                bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN); % 1 is right, 0 is left
                [~, ~, ranking] = unique(gd.repeat_id);
                bayesdata.nrepeatID(si,1) = max(ranking);
                bayesdata.repeatID(si,:) = W.extend(ranking',LEN);
            end
            

        case 'testretest'
            bayesdata.nHorizon = 2;
            bayesdata.nSubject = length(idxsub);
            nT = cellfun(@(x)length(x), idxsub);
            LEN = min(max(nT),maxtrial);
            bayesdata.nForcedTrials = 4;
            for si = 1:bayesdata.nSubject
                gd = data(idxsub{si},:);
                nT = min(size(gd,1), LEN);
                bayesdata.nTrial(si,1) = nT;
                bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN); % 1 is short, 2 is long
                bayesdata.dI(si,:) = W.extend(gd.dI',LEN); % -1, 0, 1
                bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN); % 1 is right, 0 is left
                bayesdata.dR(si,:) = W.extend(gd.dR(:,4)',LEN);
                bayesdata.order(si,1) = unique(gd.session);
                retestID(si,1) = unique(gd.subjectID);
            end
            [~, ~, ranking] = unique(retestID);
            bayesdata.repeatID(:,1) = ranking;
            bayesdata.nrepeatID(:,1) = max(ranking);
            bayesdata.nTestretest = 2;
            
        otherwise
            cprintf('Red', 'Modelname %s not recognized', modelname);
    end
end






% 
% if strcmp('2noise',isfake)
%                     fileresult =  fullfile(obj.siyupathresultbayes, [obj.savename '_' modelname obj.savesuffix '_bayesresult.mat']);
%                     if exist(fileresult)
%                         bayesresult = importdata(fileresult);
%                         As = bayesresult.stats.mean.As(:,bayesdata.nSubject);
%                         bs = bayesresult.stats.mean.bs(:,bayesdata.nSubject);
%                         nints = bayesresult.stats.mean.dNs(:,bayesdata.nSubject);
%                         nexts = bayesresult.stats.mean.Eps(:,bayesdata.nSubject);
%                         gd = obj.shufflerepeatedgames(gd, As, bs, nints, nexts);
%                         bayessuffix = ['_fake_' datestr(now,30)];
%                     else
%                         warning('no bayes result found, can''t shuffle data');
%                     end
%                 end



%         case 'learningmodel'
%             bayesdata.nHorizon = 2;
%             bayesdata.nSubject = length(data);
%             nT = arrayfun(@(x)x.game.n_game, data);
%             LEN = min(max(nT),maxtrial);
%             bayesdata.nForcedTrials = 4;
%             bayesdata.nCond = length(obj.idxn);
%             for ci = 1:bayesdata.nCond
%                 for si = obj.idxn{ci}'
%                     gd = data(si).game;
%                     nT = gd.n_game;
%                     bayesdata.Cond(si,1) = ci;
%                     bayesdata.nTrial(si,1) = nT;
%                     bayesdata.horizon(si,:) = obj.getcolumn(ceil(gd.cond_horizon'/5), LEN);
%                     bayesdata.dInfo(si,:) = obj.getcolumn(gd.cond_info',LEN);
%                     bayesdata.c5(si,:) = obj.getcolumn((gd.key(:,5)' == 1) + 0,LEN);
%                     for ti = 1:bayesdata.nForcedTrials
%                         bayesdata.cforced(si,:,ti) =  obj.getcolumn((gd.key(:,ti)' == 1) + 0,LEN);
%                         bayesdata.r(si,:,ti) =  obj.getcolumn(gd.R_chosen(:,ti)',LEN);
%                     end
%                 end
%             end
%         case 'learningmodel_nodiffusion_horizononly'
%             for ci = 1:length(obj.idxn)
%                 tbayesdata = [];
%                 tbayesdata.nHorizon = 2;
%                 tbayesdata.nSubject = length(data(obj.idxn{ci}));
%                 nT = arrayfun(@(x)x.game.n_game, data(obj.idxn{ci}));
%                 LEN = min(max(nT),maxtrial);
%                 tbayesdata.nForcedTrials = 4;
%                 scount = 0;
%                 for si = obj.idxn{ci}'
%                     scount = scount + 1;
%                     gd = data(si).game;
%                     nT = min(gd.n_game, LEN);
%                     tbayesdata.nTrial(scount,1) = nT;
%                     tbayesdata.horizon(scount,:) = obj.getcolumn(ceil(gd.cond_horizon'/5), LEN);
%                     tbayesdata.dInfo(scount,:) = obj.getcolumn(gd.cond_info',LEN);
%                     tbayesdata.c5(scount,:) = obj.getcolumn((gd.key(:,5)' == 1) + 0,LEN);
%                     for ti = 1:tbayesdata.nForcedTrials
%                         tbayesdata.cforced(scount,:,ti) =  obj.getcolumn((gd.key(:,ti)' == 1) + 0,LEN);
%                         tbayesdata.r(scount,:,ti) =  obj.getcolumn(gd.R_chosen(:,ti)',LEN);
%                     end
%                 end
%                 condname{ci} = obj.idxnlabel{ci};
%                 bayesdata{ci} = tbayesdata;
%                 
%             end
%         case 'learningmodel_horizononly'
%             for ci = 1:length(obj.idxn)
%                 tbayesdata = [];
%                 tbayesdata.nHorizon = 2;
%                 tbayesdata.nSubject = length(data(obj.idxn{ci}));
%                 nT = arrayfun(@(x)x.game.n_game, data(obj.idxn{ci}));
%                 LEN = min(max(nT),maxtrial);
%                 tbayesdata.nForcedTrials = 4;
%                 scount = 0;
%                 for si = obj.idxn{ci}'
%                     scount = scount + 1;
%                     gd = data(si).game;
%                     nT = min(gd.n_game, LEN);
%                     tbayesdata.nTrial(scount,1) = nT;
%                     tbayesdata.horizon(scount,:) = obj.getcolumn(ceil(gd.cond_horizon'/5), LEN);
%                     tbayesdata.dInfo(scount,:) = obj.getcolumn(gd.cond_info',LEN);
%                     tbayesdata.c5(scount,:) = obj.getcolumn((gd.key(:,5)' == 1) + 0,LEN);
%                     for ti = 1:tbayesdata.nForcedTrials
%                         tbayesdata.cforced(scount,:,ti) =  obj.getcolumn((gd.key(:,ti)' == 1) + 0,LEN);
%                         tbayesdata.r(scount,:,ti) =  obj.getcolumn(gd.R_chosen(:,ti)',LEN);
%                     end
%                 end
%                 condname{ci} = obj.idxnlabel{ci};
%                 bayesdata{ci} = tbayesdata;
%                 
%             end
%         case 'learningmodel_minimum'
%             for ci = 1:length(obj.idxn)
%                 for horizoni = 1:2
%                     tbayesdata = [];
%                     tbayesdata.nHorizon = 2;
%                     tbayesdata.nSubject = length(data);
%                     nT = arrayfun(@(x)sum(ceil(x.game.cond_horizon/5) == horizoni), data);
%                     LEN = min(max(nT),maxtrial);
%                     tbayesdata.nForcedTrials = 4;
%                     scount = 0;
%                     for si = obj.idxn{ci}'
%                         scount = scount + 1;
%                         gd = data(si).game;
%                         idxh = ceil(gd.cond_horizon/5) == horizoni;
%                         nT = sum(idxh);
%                         tbayesdata.nTrial(scount,1) = nT;
%                         %                             tbayesdata.horizon(si,:) = obj.getcolumn(ceil(gd.cond_horizon'/5), LEN);
%                         tbayesdata.dInfo(scount,:) = obj.getcolumn(gd.cond_info(idxh)',LEN);
%                         tbayesdata.c5(scount,:) = obj.getcolumn((gd.key(idxh,5)' == 1) + 0,LEN);
%                         for ti = 1:tbayesdata.nForcedTrials
%                             tbayesdata.cforced(scount,:,ti) =  obj.getcolumn((gd.key(idxh,ti)' == 1) + 0,LEN);
%                             tbayesdata.r(scount,:,ti) =  obj.getcolumn(gd.R_chosen(idxh,ti)',LEN);
%                         end
%                     end
%                     condname{(ci-1)*2 + horizoni} = sprintf('cond = %s, horizon = %d', obj.idxnlabel{ci}, horizoni*5);
%                     bayesdata{(ci-1)*2 + horizoni} = tbayesdata;
%                 end
%             end
%         case 'simplemodel'
%             bayesdata.nHorizon = 2;
%             bayesdata.nSubject = length(idxsub);
%             nT = cellfun(@(x)length(x), idxsub);
%             LEN = min(max(nT),maxtrial);
%             for si = 1:length(idxsub)
%                 gd = data(idxsub{si},:);
%                 nT = min(size(gd,1), LEN);
%                 bayesdata.nTrial(si,1) = nT;
%                 bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN);
%                 bayesdata.dI(si,:) = W.extend(gd.dI',LEN);
%                 bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN);
%                 bayesdata.dR(si,:) = W.extend(gd.dR(:,4)',LEN);
%             end
%         case 'simplemodel'
%             bayesdata.nHorizon = 2;
%             bayesdata.nSubject = length(idxsub);
%             nT = cellfun(@(x)length(x), idxsub);
%             LEN = min(max(nT),maxtrial);
%             for si = 1:length(idxsub)
%                 gd = data(idxsub{si},:);
%                 nT = min(size(gd,1), LEN);
%                 bayesdata.nTrial(si,1) = nT;
%                 bayesdata.horizon(si,:) = W.extend(ceil(gd.cond_horizon'/5), LEN);
%                 bayesdata.dI(si,:) = W.extend(gd.dI',LEN);
%                 bayesdata.choice(si,:) = W.extend((gd.choice(:,5)' == 2) + 0, LEN);
%                 bayesdata.dR(si,:) = W.extend(gd.dR(:,4)',LEN);
%             end