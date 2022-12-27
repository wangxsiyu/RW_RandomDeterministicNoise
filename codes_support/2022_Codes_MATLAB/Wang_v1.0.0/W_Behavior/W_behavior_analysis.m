classdef W_behavior_analysis < handle
    properties
    end
    methods(Static)
        function [sub] = analysis_sub(games, idxsub, funclist, varargin)
            if ~exist('funclist', 'var')
                error('please specify function to run');
                sub = [];
                return;
            end
            if ~exist('idxsub', 'var') || isempty(idxsub)
                idxsub = {1:size(games,1)};
            end
            funclist = W.encell(funclist);
            games = W.tab_autofieldcombine(games);
            n_sub = length(idxsub);
            [sub] = W.tab_unique(games, idxsub);
            for oi = 1:length(funclist)
                tfunc = funclist{oi};
                if W.is_stringorchar(tfunc) || isstring(tfunc)
                    W.print('analysis %s...', tfunc);
                    tfunc = str2func(tfunc);
                else
                    W.print('analysis function...');
                end
                clear tsub
                for si = 1:n_sub
                    W.print('    ...processing subject %d/%d', si, n_sub);
                    tsub(si) = tfunc(games(idxsub{si},:), varargin{:});
                end
                sub = W.tab_horzcat(sub, struct2table(tsub, 'AsArray', true));
            end
%             sub = W.tab_squeeze(sub); % squeeze needs to be added
        end
        function [sub, preprocessedData, idxsub] = analysis_pipeline(filename, ...
                opt_sub, opt_preprocess, opt_game_sublevel, opt_analysis_sub, savedir, idxsub0)
            if W.is_stringorchar(filename)
                W.print('ANALYZING file - %s', filename);
                rawdata = W.readtable(filename, 'Delimiter', ",");
            else
                W.print('ANALYZING loaded data');
                rawdata = filename;
            end
            if ~exist('opt_preprocess', 'var') || isempty(opt_preprocess)
                preprocessedData = rawdata;
            else
                if ischar(opt_preprocess)
                    opt_preprocess = str2func(opt_preprocess);
                end
                preprocessedData = opt_preprocess(rawdata);
            end
            if exist('opt_game_sublevel', 'var') && ~isempty(opt_game_sublevel)
                if exist('idxsub0', 'var') && ~isempty(idxsub0)
                    idxsub = idxsub0;
                else
                    idxsub = W.selectsubject(preprocessedData, opt_sub);
                end
                preprocessedData = W.preprocess_subxgame(preprocessedData, idxsub, opt_game_sublevel);
            end
            if exist('idxsub0', 'var') && ~isempty(idxsub0)
                idxsub = idxsub0;
            else
                idxsub = W.selectsubject(preprocessedData, opt_sub);
            end
            sub = W.analysis_sub(preprocessedData, idxsub, opt_analysis_sub);
            if exist('savedir', 'var') && ~isempty(savedir)
                savedir = W.mkdir(savedir);
                tfilename = W.basenames(W.file_deprefix(filename));
                tfilename = W.deext(tfilename);
                tfilename = W.enext(tfilename, 'csv');
                tfilename1 = W.file_prefix(tfilename, 'SUB');
                writetable(sub, fullfile(savedir, tfilename1));
                tfilename2 = W.file_prefix(tfilename, 'processedData');
                writetable(preprocessedData, fullfile(savedir, tfilename2));
                save(fullfile(savedir, W.file_prefix(W.deext(tfilename), 'idxsub')), 'idxsub');
            end
        end
        function games = preprocess_subxgame(games, rowid, funclist)
            funclist = W.encell(funclist);
            n_sub = length(rowid);
            n_trials = cellfun(@(x)repmat(length(x),length(x),1), rowid, 'UniformOutput', false);
            games.n_trials = vertcat(n_trials{:});
            for oi = 1:length(funclist)
                tfunc = funclist{oi};
                if ischar(tfunc) || isstring(tfunc)
                    tfunc = str2func(tfunc);
                    W.print('preprocess subxgame %s...', funclist{oi});
                else
                    W.print('preprocess subxgame - func')
                end
                sub = table;
                for si = 1:n_sub
                    W.print('    ...processing subject %d/%d', si, n_sub);
                    te = tfunc(games(rowid{si},:));
                    if isstruct(te)
                        tsub = struct2table(te);
                    else
                        tsub = te;
                    end
                    sub = W.tab_vertcat(sub, tsub);
                end
                if size(games,1) == size(sub,1)
                    games = W.tab_horzcat(games, sub, 'overwrite');
                else
                    W.warning('gamexsub does not match original size, ignored');
                end
            end
            W.print('complete preprocessing(subject dependent)');
        end
        function [sub, id, ids] = excludesubject(sub, varargin)
            opt_exclude = W.encell(W.decell(varargin));
            W.print('excluding subjects');
            vi = 1;
            t0 = ones(size(sub,1), 1) == 1;
            id = t0;
            while vi <= length(opt_exclude)
                arg = opt_exclude{vi};
                val = opt_exclude{vi+1};
                td = sub.(arg);
                vi = vi + 2;
                tid = t0;
                if ~isnan(val(1))
                    tid = tid & (td >= val(1));
                end
                if ~isnan(val(2))
                    tid = tid & (td <= val(2));
                end
                ids.(arg) = tid;
                W.print('%d participants excluded, %d remaining', sum(id & ~tid), sum(id & tid));
                id = id & tid;
            end
            sub = sub(id,:);
        end
        function gp = analysis_group(sub, cond_fds, varargin)
            [idx, tab] = W_sub.selectsubject(sub, cond_fds);
            gp = table;
            gp.group_analysis = tab;
            tgp = table;
            for  ii = 1:length(idx)
                te = W.analysis_1group(sub(idx{ii},:), varargin{:});
                tgp = W.tab_vertcat(tgp, te);
            end
            gp = [gp tgp];
        end
        function gp = analysis_1group(sub, switch_paircompare, additional_compare)
            if ~exist('switch_paircompare', 'var') || isempty(switch_paircompare)
                switch_paircompare = true;
            end
            if ~exist('additional_compare', 'var') || isempty(additional_compare)
                additional_compare = [];
            end
            gp = [];
            sub = W.tab_autofieldcombine(sub);
            fnms = W.fieldnames(sub);
            for fi = 1:length(fnms) % ex. regular av/se
                fn = fnms{fi};
                td = sub.(fn);
                if isnumeric(td) || islogical(td)
                    [gp.(['GPav_' fn]), gp.(['GPste_' fn])] = W.avse(td);
                    % pvalue of pairs
                    if switch_paircompare && size(td,2) == 2
                        [~,gp.(['GPpvalue_' fn]), ~, tstat] = ttest(diff(td')');
                        %                         gp.(['cohen_d_' fn]) =  computeCohen_d(td(:,1), td(:,2), 'paired');
                        gp.(['GPtstat_' fn]) = tstat.tstat;
                    end
                elseif (iscell(td) && all(cellfun(@(x)isnumeric(x) || islogical(x), td), 'all'))
                    for tyi = 1:size(td,2) % loop over columns of cells
                        [nx, ny] = size(td{1,tyi});
                        issamesz = cellfun(@(x) size(x,1) == nx && size(x,2) == ny, td(:, tyi));
                        if any(~issamesz)
                            W.warning(sprintf('ignored %s, cells of different size', fn));
                            continue;
                        end
                        [gp.(['GPav_' fn]){tyi}, gp.(['GPste_' fn]){tyi}] = W.cell_avse(td(:, tyi));
                    end
                elseif size(W.unique(td, 'rows'),1) == 1 % all elements are the same
                    gp.(fn) = W.unique(td, 'rows');
                elseif ~any(strcmpi(fn, {'filename','time','comment','csv_filename','subjectid'}))
                    W.warning(sprintf('ignored %s, format not supported', fn));
                end
            end
            for ai = 1:length(additional_compare) % ex. _h1 vs _h6
                tfn = W.encell(additional_compare{ai});
                tds =  cellfun(@(x)sub.(x), tfn, 'UniformOutput', false);
                isnums =  cellfun(@(x)all(isnumeric(x) | islogical(x)), tds);
                if ~all(isnums)
                    continue;
                end
                if length(tds) == 2
                    tpval = NaN(1, size(tds{1},2));
                    tstat = NaN(1, size(tds{1},2));
                    for ci = 1:size(tds{1},2)
                        [~, tpval(ci), ~, tt] = ttest(tds{2}(:,ci) - tds{1}(:,ci));
                        tstat(ci) = tt.tstat;
                    end
                    gp.(['GPpvalue_', strjoin(tfn,'_vs_')]) = tpval;
                    gp.(['GPtstat_', strjoin(tfn,'_vs_')]) = tstat;
                elseif length(tds) == 1
                    tds = tds{1};
                    tpval = NaN(1, size(tds,2));
                    tstat = NaN(1, size(tds,2));
                    for ci = 1:size(tds,2)
                        [~, tpval(ci), ~, tt] = ttest(tds(:,ci));
                        tstat(ci) = tt.tstat;
                    end
                    gp.(['GPpvalue_', tfn{1},'_vs0']) = tpval;
                    gp.(['GPtstat_', tfn{1},'_vs0']) = tstat;
                else
                    W.warning('ANOVA has not been implemented here, to be done');
                end
            end
            gp = struct2table(gp);
            gp.GPn_subject = size(sub,1);
        end
    end
end