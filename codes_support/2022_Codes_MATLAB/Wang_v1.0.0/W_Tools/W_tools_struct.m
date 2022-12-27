classdef W_tools_struct < handle
    methods(Static)
        function a = struct_fill1(a)
            if ~isempty(a)
                [fx, fnms] = W.fieldsize(a,[], 1);
                fnms = fnms(fx == 1);
                if length(unique(fx(fx > 1))) > 1
                    W.warning('struct_fill1: struct has different number of rows, ignored');
                    return
                end
                for fi = 1:length(fnms)
                    a.(fnms{fi}) = repmat(a.(fnms{fi}), max(fx),1);
                end
            end
        end
        %% struct mean
        function [av, se] = struct_avse(a, varargin)
            fnms = W.fieldnames(a);
            av = struct;
            se = struct;
            for fi = 1:length(fnms)
                fn = fnms{fi};
                td = W.arrayfun(@(x)x.(fn), a, false);
                [tav, tse] = W.cell_avse(td, varargin{:});
                av.(fn) = tav;
                se.(fn) = tse;
            end
        end
        %% struct median
        function [mid] = struct_median(a, varargin)
            fnms = W.fieldnames(a);
            mid = struct;
            for fi = 1:length(fnms)
                fn = fnms{fi};
                td = W.arrayfun(@(x)x.(fn), a, false);
                [tmid] = W.cell_median(td, varargin{:});
                mid.(fn) = tmid;
            end
        end
        %% struct cat
        function out = struct_append(a, b)
            if isempty(a) || isequal(struct, a)
                out = b;
                return
            elseif isempty(b) || isequal(struct, b)
                out = a;
                return
            end
            fnms = unique([fieldnames(a),fieldnames(b)]);
            fnms = setdiff(fnms, {'Row','Properties','Variables'});
            for i = 1:length(fnms)
                fn = fnms{i};
                out.(fn) = [a.(fn); b.(fn)];
            end
        end
        function out = struct_cat_bydim(a, b, dim)
            if isempty(a) || isequal(struct, a)
                out = b;
                return
            elseif isempty(b) || isequal(struct, b)
                out = a;
                return
            end
            fnms = unique([W.fieldnames(a),W.fieldnames(b)]);
            for i = 1:length(fnms)
                fn = fnms{i};
                out.(fn) = cat(dim, a.(fn), b.(fn));
            end
        end
        %% struct merge - add fields in b that's not in a
        function [a, unusedparams] = struct_merge(a, b, option)
            unusedparams = [];
            if isempty(a)
                a = struct;
            end
            if ~exist('option', 'var') || isempty(option)
                option = 'overwrite';
                % ignore - ignore the duplicated names in b
                % overwrite - ignore the duplicated names in a
                % set - replace the fields in a with corresponding values
                % in b (ignore extra fields in b)
            end
            c = intersect(fieldnames(a), fieldnames(b));
            switch option
                case 'overwrite'
                    a = rmfield(a, c);
                case 'ignore'
                    b = rmfield(b, c);
                case 'set'
                    a = rmfield(a, c);
                    unusedparams = rmfield(b, c);
                    b = rmfield(b, setdiff(fieldnames(b), c));
            end
            a = W.struct_combine(a, b);
        end
        %% struct combine - combine fields
        function a = struct_combine(a, b)
            if isempty(a)
                a = struct;
            end
            a = cell2struct([struct2cell(a); struct2cell(b)], [fieldnames(a); fieldnames(b)],1);
        end
        %% struct set parameters
        function [X, unusedparams] = struct_set_parameters(X, varargin)
            % unusedparams is returned as a structure
            vars = W.encell(varargin);
            if isempty(vars)
                unusedparams = [];
                return
            end
            if length(vars) == 1 && W.is_stringorchar(vars{1}) && ...
                    strcmp(vars{1}, 'help')
                W.print('available parameters are:');
                W.disp(W.fieldnames(X), '-');
            end
            if W.is_stringorchar(vars{end}) && ...
               ( (isstruct(vars{1}) && length(vars) == 2) || ...
                    (W.is_stringorchar(vars{1}) && mod(length(vars), 2) == 1) ) 
                % 1 the first input is a structure and the second input is a string
                % OR 2 the first input is a string and there are odd inputs
                % 
                % 1 or 2: the last input is the struct_merge option
                option = vars{end};
                vars = vars(1:end-1);
            else
                option = [];
            end
            if length(vars) == 1 && isstruct(vars{1})
                X_new = vars{1};
            else
                X_new = cell2struct(vars(2:2:end), vars(1:2:end),2);
            end
            [X, unusedparams] = W.struct_merge(X, X_new, option);
        end
        function X = struct(varargin)
            X = W.struct_set_parameters(struct, varargin{:});
        end
        %% rmfield
        function a = rmfield(a, name)
            if isfield(a, name)
                a = rmfield(a, name);
            end
        end
        % compile
        function out = struct_compilefromcell(strcell, fieldname)
            out = W.cellfun(@(x)x.(fieldname), strcell, false);
            out = W.cell_autoverthorzcat(out);
        end
    end
end