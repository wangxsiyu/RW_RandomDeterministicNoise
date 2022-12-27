classdef W_tools_cell < handle
    properties
    end
    methods(Static)
        %%
        function [a, tid] = cell_squeeze(a)
            tid = W.cellsize(a) > 0;
            a = a(tid);
        end
        %% encell/decell
        function a = decell(a)
            while iscell(a) && length(a) == 1
                a =  a{1};
            end
        end
        function a = encell(a)
            if ~iscell(a)
                a = {a};
            end
        end        
        %% size of each element in a cell
        function out = cellsize(a)
            if ~iscell(a)
                W.error('cellsize: input not cell')
                return
            end
            out = cellfun(@(x)length(x), a);
        end
        function out = cell_autoverthorzcat(a)           
            out = a;
            if all(cellfun(@(x)size(x,1), a) == 1) && length(unique(W.cellsize(a))) == 1
                out = vertcat(a{:});
            end
            if all(cellfun(@(x)size(x,2), a) == 1) && length(unique(W.cellsize(a))) == 1
                out = horzcat(a{:});
            end
        end
        %% cell calculations
        function [b, n] = cell_sum(a, opt_nan)
            if ~exist('opt_nan', 'var') || isempty(opt_nan)
                opt_nan = 'omitnan';
            end
            a = W.encell(a);
            if isequal(opt_nan, 'omitnan')
                idnotnan = W.cellfun(@(x)~isnan(x), a, false);
                a = W.cellfun(@(x)W.changem(x, 0, NaN), a, false);
            else
                idnotnan = W.cellfun(@(x)ones(size(x)), a, false);
            end
            b = a{1};
            n = idnotnan{1};
            for i = 2:length(a)
                b = b + a{i};
                n = n + idnotnan{i};
            end
        end
        function [b, n] = cell_mean(a, varargin)
            [b, n] = W.cell_sum(a, varargin{:});
            b = b./n;
        end
        function [b, n] = cell_sd(a, varargin)
            [av, n] = W.cell_mean(a, varargin{:});
            ss = W.cell_sum(W.cellfun(@(x) (x- av).^2, a, false), varargin{:});
            ss = ss./(n - 1);
            b = sqrt(ss);
        end
        function [b, n] = cell_se(a, varargin)
            [b, n] = W.cell_sd(a, varargin{:});
            b = b./sqrt(n);
        end
        function [av, se, n] = cell_avse(a, varargin)
            [av, n] = W.cell_mean(a, varargin{:});    
            [se, n] = W.cell_se(a, varargin{:});
        end
        function mid = cell_median(a, varargin)
            sz = size(a{1});
            mid = NaN(sz);
            for i = 1:sz(1)
                for j = 1:sz(2)
                    td = cellfun(@(x)x(i,j), a);
                    mid(i,j) = median(td, 'all', 'omitnan');
                end
            end
        end
        %% cell rotate
        function a = cell_rotate(a)
            a = W.cellfun(@(x)x', a, false);
        end
    end
end