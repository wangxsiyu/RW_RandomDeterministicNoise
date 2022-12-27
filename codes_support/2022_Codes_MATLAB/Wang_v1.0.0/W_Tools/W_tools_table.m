classdef W_tools_table < handle
    properties
    end
    methods(Static)
        %% read/write
        function out = readtable(filename, varargin)
            if length(varargin) >= 1 && strcmp(varargin{1}, 'TextscanFormats')
                fmt = datastore(filename);
                fmt.TextscanFormats = W.decell({varargin{2:end}});
                out = read(fmt);
            else
                out = readtable(filename, varargin{:});
            end
            out = W.tab_autofieldcombine(out, 1);
        end     
        function tab = tab_autofieldcombine(tab, isnested)
            arguments
                tab table;
                isnested logical = false;
            end
            fs = tab.Properties.VariableNames;
            % get fieldnames with underscores _
            is_ = find(contains(fs, '_'));
            idx_ = strfind(fs, '_');
            % exclude fieldnames with non-number suffix
            tstr_suffix = W.arrayfun(@(x)fs{x}(idx_{x}(end)+1:end), is_, 0);
            idxnonnum_ = cellfun(@(x)isempty(str2double(x)) || isnan(str2double(x)), tstr_suffix);
            is_ = is_(~idxnonnum_); 
                % is_ : indices that have the format fn_number
            % get unique fieldnames with fn_number
            fs_ = unique(W.arrayfun(@(x)fs{x}(1:idx_{x}(end)), is_, false));
            flag = false;
            for fi = 1:length(fs_)
                fn = fs_{fi};
                fs = tab.Properties.VariableNames;
                is_ = find(contains(fs, '_'));
                idx_ = strfind(fs, '_');
                idx_col = find(arrayfun(@(x)ismember(x, is_) && length(fn) < length(fs{x}) && ...
                    strcmp(fs{x}(1:length(fn)),fn) && idx_{x}(end) == length(fn), 1:length(fs)));
                    % idx_col is the table columns with the name fn_X
                ord = arrayfun(@(x)str2double(fs{x}(idx_{x}(end)+1:end)), idx_col);
                if isempty(ord) % no numbers
                    W.warning('tab_autofieldcombine: empty ord, should not happen!!!')
                    continue;
                end
                if length(ord) ~= max(ord) % missing elements, ord has to be 1,2,3,...,n
                    W.warning('tab_autofieldcombine: len != max, ignored. %s', fn);
                    continue;
                end
                flag = true; % some combining operation was done
                [~, idx] = sort(ord);
                idx_col = idx_col(idx);
                if all(W.fieldsize(tab, fs(idx_col), 2) == 1) 
                    % if all fields have 1 column, combine those columns in
                    % a single matrix
                    tab = mergevars(tab, fs(idx_col), 'NewVariableName', fn(1:end-1));
                else 
                    % otherwise, save the whole table (consisting of the n
                    % variables) as the new variable
                    tab.(fn(1:end-1)) = tab(:, idx_col);
                    tab = removevars(tab, fs(idx_col));
                end
            end
            if isnested == 1 && flag 
                tab = W.tab_autofieldcombine(tab, isnested);
            end
        end
        function tab = tab_decombine(tab, isnested)
            arguments
                tab table;
                isnested logical = false;
            end
            flag = false;
            fnms = W.fieldnames(tab);
            for fi = 1:length(fnms)
                fn = fnms{fi};
                if size(tab.(fn),2) > 1
                    flag = true;
                    newnames = W.arrayfun(@(x)strcat(fn, '_', num2str(x)), 1:size(tab.(fn),2));
                    tab = splitvars(tab, fn, 'NewVariableNames', newnames);
                end
            end
            if isnested == 1 && flag
                tab = W.tab_decombine(tab, isnested);
            end
        end
        function writetable(tab, filename, is_squeeze, varargin)
            arguments
                tab table;
                filename string;
                is_squeeze logical = false;
            end
            arguments(Repeating)
                varargin;
            end
            if is_squeeze
                tab = W.tab_autofieldcombine(tab);
                W.error('tab squeezing not yet implemented, need to add');
%                 tab = W.tab_squeeze(tab);
            end
            tab = W.tab_denested(tab); % a column of the table is table
            filename = W.deext(filename);
            filename = W.enext(filename, 'csv');
            W.mkdir(fileparts(filename));
            writetable(tab, filename, varargin{:});
        end        
        function tab = tab_denested(tab)
             fs = tab.Properties.VariableNames;
             idtab = find(cellfun(@(x)istable(tab.(x)), fs));
             for it = idtab
                 fn = fs{it};
                 te = tab.(fn); % this is the sub-table
                 te = W.tab_prefix(te, fn, []);
                 tab = removevars(tab, fn);
                 tab = W.tab_horzcat(tab, te);
             end
             if ~isempty(idtab)
                 tab = W.tab_denested(tab);
             end
        end
        %% rename
        function tab = tab_prefix(tab, prefix, fn)
            if ~exist('fn', 'var') || isempty(fn)
                fn = tab.Properties.VariableNames;
            end
            fnew = strcat(prefix, '_', fn);
            tab = renamevars(tab, fn, fnew);
        end
        function tab = tab_suffix(tab, suffix, fn)
            if ~exist('fn', 'var') || isempty(fn)
                fn = tab.Properties.VariableNames;
            end
            fnew = strcat(fn, '_', suffix);
            tab = renamevars(tab, fn, fnew);
        end
        %% vertcat/horzcat
        function tab = tab_horzcat(a, b, option) % merge b into a
            arguments
                a table;
                b table;
                option string = 'ignore';
                % ignore - ignore the duplicated names in b
                % overwrite - ignore the duplicated names in a
                % duplicate - save both, name the 2nd table's version as X_duplicate
            end
            if size(a,1) ~= size(b,1)
                W.error('tab_horzcat: table a and b should have the same number of rows');
                return
            end
            c = intersect(a.Properties.VariableNames, b.Properties.VariableNames);
            if ~isempty(c)
                for ci = 1:length(c)
                    if strcmp(option, 'duplicate')
                        W.print('duplicating field %s from the 2nd table', c{ci});
                        b.([c{ci} '_duplicate']) = b.(c{ci});
                        b.(c{ci}) = [];
                    elseif strcmp(option, 'ignore')
                        W.print('ignoring field %s from the 2nd table', c{ci});
                        b.(c{ci}) = [];
                    elseif strcmp(option, 'overwrite')
                        W.print('overwrite field %s from the 1st table', c{ci});
                        a.(c{ci}) = [];
                    end
                end
            end
            tab = horzcat(a, b);
        end        
        function out = tab_vertcat(varargin)
            varargin = W.encell(W.decell(varargin));
            var = varargin(cellfun(@(x)~isempty(x), varargin));
            if isempty(var)
                out = table;
                return;
            end
            try
                out = vertcat(var{:});
            catch
                varnames = W.cellfun(@(x)x.Properties.VariableNames, var, false);
                fn = unique([varnames{:}]);
                sz = cellfun(@(x)W.fieldsize(x, fn, 2), var, 'UniformOutput', false); 
                sz = horzcat(sz{:}); % #fn x #table
                sz_max = max(sz, [], 2); % #fn x 1
                for i = 1:length(fn) % field names
                    idnotnan = find(~isnan(sz(i,:)), 1);
                    dtype = class(var{idnotnan}.(fn{i})); 
                    switch dtype
                        case 'char' % turn chars to strings
                            dtype = 'string';
                            sz_max(i) = 1;
                            for j = 1:size(sz, 2)
                                if ~isnan(sz(i,j))
                                    var{j}.(fn{i}) = string(var{j}.(fn{i}));
                                end
                            end
                        case 'table' % ignore subtable
                            W.warning('tab_vertcat: ignoring sub-table - %s', fn{i});
                            for j = 1:size(sz,2)
                                var{j}.(fn{i}) = [];
                            end
                            continue;
                    end
                    for j = 1:size(sz, 2) % # of tables
                        if isnan(sz(i,j)) || sz(i,j) == 0
                            var{j}.(fn{i}) = W.empty_create(dtype, [size(var{j},1), sz_max(i)]);
                        elseif sz(i,j) ~= sz_max(i)
                            var{j}.(fn{i}) = W.extend(var{j}.(fn{i}), sz_max(i));
                        end
                    end
                end
                out = vertcat(var{:});
            end
        end
        %% table_fill
        function tab = tab_fill(tab, varargin)
            if nargin == 2 % in this case, varargin should be a table (with 1 row)
                fn = varargin{1};
                tab = W.tab_horzcat(tab, repmat(fn, size(tab,1), 1));
            else
                i = 1;
                while i+1 <= length(varargin)
                    fn = varargin{i}; % fieldname
                    x = varargin{i+1}; % value (1 row)
                    tab.(fn) = repmat(x, size(tab,1), 1);
                    i = i + 2;
                end
            end
        end
        function tab = tab_addID(tab, IDname)
            if ~exist('IDname', 'var') || isempty(IDname) || ~W.is_stringorchar(IDname)
                IDname = 'tabID';
            end
            if ~ismember(IDname, W.fieldnames(tab))
                tab.(IDname) = W.vert(1:size(tab,1));
            else
                W.print('tab_addID: tab.%s exists, ignore', IDname);
            end
        end
        %% get fieldsize for tables or structures
        function fnms = fieldnames(d)
            fnms = fieldnames(d);
            fnms = setdiff(fnms, {'Row','Properties','Variables'}, 'stable');
        end
        function [out, fnms] = fieldsize(d, fnms, idx)
            % d - table/structure
            % fnms - field names
            % idx - fieldsize dimension
            fnms0 = W.fieldnames(d);
            if ~exist('fnms', 'var') || isempty(fnms)
                fnms = fnms0;
            end
            tfnms = intersect(fnms, fnms0, 'stable'); % stable means in the order of fnms (1st list)
            out0 = W.cellfun(@(x)size(d.(x)), tfnms, 0); % get size of each field
            mz = max(cellfun(@(x)length(x), out0)); % get maximal size dimension
            tt = cellfun(@(x)W.extend(x, mz), out0, 'UniformOutput', false);
            tt = vertcat(tt{:}); 
            if ~exist('idx', 'var') || isempty(idx)
                idx = 1:size(tt,2); % default value
            end
            tt = tt(:, idx); 
            out = NaN(length(fnms), size(tt,2)); 
            idx = cellfun(@(x)find(strcmp(x, fnms)), tfnms);
            out(idx,:) = tt;
        end
        %% table join
        function [ab, outidxgp, outid] = tab_join(a, b, col_id)
            % [ab, outidxgp, outid] = tab_join(a, b, col_id)
            %       join two tables based on col_id
            fnmsa = W.fieldnames(a);
            fnmsb = W.fieldnames(b);
            fnms_a_b = intersect(fnmsa, fnmsb);
            if ~exist('col_id', 'var') || isempty(col_id)
                col_id = fnms_a_b;
            end
            [idx1, id1] = W.selectsubject(a, col_id);
            [idx2, id2] = W.selectsubject(b, col_id);
            id1 = W.tab_getcombinedID(id1, col_id);
            id2 = W.tab_getcombinedID(id2, col_id);
            id = unique([id1; id2]);
            idxgp = cell(size(id,1), 2);
            idxgp(cellfun(@(x)find(strcmp(x, id)), id1),1) = idx1;
            idxgp(cellfun(@(x)find(strcmp(x, id)), id2),2) = idx2;

            n1 = W.cellsize(idxgp(:,1));
            n2 = W.cellsize(idxgp(:,2));
            ismissing = n1.*n2 == 0;

            idxgp = idxgp(~ismissing, :);
            id = id(~ismissing,:);
            n1 = n1(~ismissing, :);
            n2 = n2(~ismissing, :);
            outidxgp = idxgp;
            outid = id;

            ismatch = (mod(max([n1 n2],[],2),min([n1 n2],[],2)) == 0);
            if ~all(ismatch)
                W.warning('tab_join: critical fields mismatch, can not merge, exit');
                ab = [];
                return;
            end
            nID = length(id);
            for ni = 1:nID
                nmax = max(n1(ni), n2(ni));
                idxgp{ni,1} = repmat(idxgp{ni,1}, nmax/n1(ni), 1);
                idxgp{ni,2} = repmat(idxgp{ni,2}, nmax/n2(ni), 1);
            end
            idxb = find(~cellfun(@(x)any(strcmp(x,col_id)), W.fieldnames(b)));
            row_matched = [vertcat(idxgp{:,1}) vertcat(idxgp{:,2})];
            ab = W.tab_horzcat(a(row_matched(:,1),:), b(row_matched(:,2), idxb), 'duplicate');
        end
    end
end
