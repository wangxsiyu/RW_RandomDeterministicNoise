classdef W_behavior_indexing < handle
    properties
    end
    methods(Static)
        %% select row indices for each subject (out of table of trials)
        function [rowid, tab] = selectsubject(data, cond_fds)
            % In a table where each row is a trial, select row indicies for each subject 
            % based on the uniqueness of fields cond_fds (e.g. {'subjectID', 'date'})
            cond = W.tab_getcombinedID(data, cond_fds);
            conds = W.vert(unique(cond, 'stable'));
            tab = table;
            tab.condition = W.str_parse2cell(conds);
            tab = splitvars(tab, 'condition', 'NewVariableNames', cond_fds);
            rowid = cell(length(conds), 1);
            wtb = waitbar(0, 'selectsubject');
            for i = 1:length(conds)
                waitbar(i/length(conds), wtb, sprintf('extracting index for subject %d', i));
                rowid{i} = find(strcmp(cond, conds{i}));
            end
            tab.rowid = rowid;
            close(wtb);
        end
        %% get subject information (out of table of trials)
        function [subtab] = tab_unique(data, idxsub)
            if ~exist('idxsub', 'var') || isempty(idxsub)
                idxsub = {1:size(data,1)};
            end
            idxsub = W.encell(idxsub);
            fs = data.Properties.VariableNames;
            n_field = length(fs);
            n_sub = length(idxsub);
            flag_uniq = true(1, n_field);
            tout = cell(n_field, n_sub);
            for fi = 1:n_field
                for si = 1:n_sub
                    lines = idxsub{si};
                    td = data.(fs{fi})(lines,:);
                    tout{fi, si} = W.unique(td, 'rows');
                    if size(tout{fi, si}, 1) ~= 1 % if it's not unique
                        flag_uniq(fi) = false;
                        break;
                    end
                end
            end
            sub = [];
            for si = 1:n_sub
                for fi = find(flag_uniq)
                    sub(si).(fs{fi}) = tout{fi, si};
                end
                sub(si).n_games_tab_unique = length(idxsub{si});
            end
            subtab = struct2table(sub);
        end
        %% get combined ID based on several fields (e.g., subjectID x date x time)
        function str = tab_getcombinedID(tab, fds, sep)
            % this is to compute a combined condition by treating
            % everything as strings
            if ~exist('sep', 'var') || isempty(sep)
                sep = ', ';
            end
            if ~exist('fds', 'var') || isempty(fds)
                fds = tab.Properties.VariableNames;
            end
            fds = W.encell(fds);
            n = length(fds);
            wtb = waitbar(0, 'Starting');
            for i = 1:n
                waitbar(i/n, wtb, ...
                    sprintf("tab getcombinedID: field %d/%d, %s", i, n, fds{i}));
                te = tab.(fds{i});
                if isnumeric(te) % watch NaNs, since string(NaN) = <missing>.
                    te = W.arrayfun(@(x)string(num2str(x)), te);
                end
                te = string(te);
                if size(te, 2) > 1 % use ',' to separate numbers in a matrix
                    te = join(te, ',');
                end
                if contains(sep, ',') % replace ',' in data with '.'
                    te = replace(te, ',', '.');
                end
                if i == 1
                    str = te;
                else
                    str = strcat(str, sep, te);
                end
            end
            close(wtb);
        end
    end
end