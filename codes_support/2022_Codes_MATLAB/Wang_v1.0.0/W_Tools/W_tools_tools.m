classdef W_tools_tools < handle
    properties
    end
    methods(Static)
        %% unique
        function [out] = unique(x, varargin)
            if isnumeric(x)
                if ~isempty(varargin) && isnumeric(varargin{1})
                    [out] = W.unique_nan(x, varargin{1}, varargin{2:end});
                else
                    [out] = W.unique_nan(x, [], varargin{:}); % by default, includes 1 NaN
                end
            elseif iscell(x)
                [out] = W.unique_cell(x, varargin{:});
            elseif W.is_stringorchar(x) % change char to string
                x = string(x);
                out = unique(x, varargin{:});
            else
                W.print('neither cell nor numeric: use regular unique');
                [out] = unique(x, varargin{:});
            end
        end
        function [out] = unique_cell(x, varargin)
            % this is the normal unique, but only includes cells that have
            % strings in them
            x = W.select_cellofstringorchar(x);
            x = W.cell_enstr(x);
            lenx = W.cellsize(x);
            if ~(all(lenx == 1, 'all'))
                W.warning('unique_cell: some cells are character/string arrays, ignored');
                x = x(lenx == 1);
            end
            if iscell(x) % 'rows' option is not available for cells
                varargin = setdiff(varargin,'rows');
            end
            x = W.cell_enchar(x);
            [out] = unique(x, varargin{:});
        end
        function [out] = unique_nan(x, optionNaN, varargin)
            if ~exist('optionNaN', 'var') || isempty(optionNaN)
                optionNaN = 1; 
                % 1 - includes a single NaN
                % 0 - excludes NaNs
            end
            ma = max(x(~isinf(x)), [],'all') + 1;
            x = W.changem(x, ma, NaN);
            [x] = unique(x, varargin{:});
            x = W.changem(x, NaN, ma);
            x = W.vert(x);
            if optionNaN == 0
                x = x(~all(isnan(x),2),:);
            end
            out = x;
            if isempty(out) % never return []
                out = NaN(1, size(x,2));
            end
        end       
        %% nan - changem
        function a = changem(a, new, old)
            if ~exist('old', 'var') || isempty(old)
                old = 0;
            end
            idnan = isnan(old);
            if any(idnan)
                a(isnan(a)) = new(idnan);
            end
            a = changem(a, new(~idnan), old(~idnan));
        end
        %% extend
        function y = extend(x, n, x_empty, side_extend)
            if ~exist('side_extend', 'var') || isempty(side_extend)
                side_extend = 'right';
            end
            if ~exist('n','var') || isempty(n)
                n = max(size(x,2), 1); % if x = [], n = 1
            end
            if ~exist('x_empty','var') || isempty(x_empty)
                x_empty = W.empty_create(class(x));
            end
            if isempty(x_empty)
                W.warning('extend: unknown data type');
                y = [];
                return
            end
            if isempty(x) || size(x,1) == 0 % doesn't allow 0xN output
                x = x_empty;
            end
            switch side_extend 
                case 'right'
                    y = [x(:,1:min(size(x,2),n)) repmat(x_empty, size(x,1), n-size(x,2))];
                case 'left'
                    y = [repmat(x_empty, size(x,1), n-size(x,2)) x(:,1:min(size(x,2),n))];
            end
        end
        function y = select(x, n, side)
            if ~exist('side', 'var')
                side = 'left';
            end
            if size(x,2) < n
                W.error('W.select: size(x,2) < n, check!');
                y = x;
                return
            end
            switch side
                case 'left'
                    y = x(:,1:n);
                case 'right'
                    y = x(:,end-n+1:end);
            end
        end
        %% NaNs - select
        function out = nan_selects(a, varargin)
            id = [varargin{:}];
            out = arrayfun(@(x)W.nan_select(a, x), id);
        end
        function out = nan_select(a, id)
            dtype = class(a);
            if isnan(id)
                out = W.empty_create(dtype, [1 1]);
            else
                out = a(id);
            end
        end
        function out = nan_equal(a, b)
            a = W.horz(a);
            b = W.horz(b);
            out = 0 + (a == b);
            tid = isnan(a) | isnan(b);
            out(tid) = NaN(1, sum(tid));
        end
        %% empty
        function out = empty_create(dtype, sz)
            if ~exist('sz', 'var') || isempty(sz)
                sz = 1;
            end
            switch dtype
                case 'cell'
                    out = cell(sz);
                case {'double','logical','numeric'}
                    out = nan(sz);
                case 'char'
                    out = repmat(' ', sz); % this may only create an empty char array
                case 'string'
                    out = repmat("", sz);
                case 'datetime'
                    out = NaT(sz);
                otherwise
                    out = [];
                    W.warning('empty_create: dtype not recognized: %s', dtype);
            end
        end
        %% datetime format change
        function out = datetime(str, informat, outformat, yrhead)
            if ~exist('yrhead', 'var')
                yrhead = '20';
            end
            % can have "dd", "mm", "yyyy" or "yy"
            % and "HH", "MM", "SS"
            str = char(str);
            str = str(W.func('W.str_select', 2, str));
            informat = char(informat);
            outformat = char(outformat);
            dd = str(informat == 'd');
            mm = str(informat == 'm');
            yy = str(informat == 'y');
            HH = str(informat == 'H');
            MM = str(informat == 'M');
            SS = str(informat == 'S');
            if length(yy) == 2
                yy = [yrhead, yy];
            end
            out = outformat;
            if any(outformat == 'd')
                out(outformat == 'd') = dd;
            end
            if any(outformat == 'm')
                out(outformat == 'm') = mm;
            end
            if any(outformat == 'S')
                out(outformat == 'S') = SS;
            end
            if any(outformat == 'M')
                out(outformat == 'M') = MM;
            end
            if any(outformat == 'H')
                out(outformat == 'H') = HH;
            end
            if sum(outformat == 'y') == 2
                yy = yy(3:end);
            end
            out(outformat == 'y') = yy;
        end
        function out = datetimes(strs, varargin)
            strs = W.str2cell(strs);
            out = W.vert(string(W.cellfun(@(x)W.datetime(x, varargin{:}), strs)));
        end
        %% function output
        function out = func(fcn, n, varargin)
            fcn = str2func(fcn);
            if ~exist('n', 'var')
                n = [];
            end
            nOut = nargout(fcn);
            X = cell(1,nOut);
            [X{:}] = fcn(varargin{:});
            if isempty(n)
                n = 1:nOut;
            end
            out = W.decell(X(n));
        end
        %% par
        function poolsize = parpool(nchains)
            poolobj = gcp('nocreate'); % If no pool, do not create new one.
            if isempty(poolobj)
                poolsize = 0;
            else
                poolsize = poolobj.NumWorkers;
            end
            if poolsize == 0
                if exist('nchains', 'var')
                    parpool(nchains, 'IdleTimeout', Inf);
                else
                    parpool('IdleTimeout', Inf);
                end
            end
        end
        function parclose()
            poolobj = gcp('nocreate');
            delete(poolobj);
        end
        %% select column
        function out = col_select(a, id)
            out = W.arrayfun(@(x)W.nan_select(a(x, :), id(x)), 1:length(id));
        end
    end
end