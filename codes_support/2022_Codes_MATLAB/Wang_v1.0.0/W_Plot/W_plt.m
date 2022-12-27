classdef W_plt < W_plt_base & W_plt_stat
    properties
    end
    methods
        function obj = W_plt(varargin)
            obj.set_pltsetting(varargin{:});
        end
        function plot(obj, x, y, errbar, type, varargin)
            % x/y = array[line x points] or {line1, line2, line3, etc}
            % ----------- Unify input format
            if ismatrix(y) % turn all lines to cell format
                y = W.arrayfun(@(t)y(t, :), 1:size(y,1), false);
            end
            if ~exist('errbar', 'var') || isempty(errbar)
                errbar = repmat({[]}, 1, length(y));
            elseif exist('errbar', 'var') && ismatrix(errbar)
                errbar = W.arrayfun(@(t)errbar(t, :), 1:size(errbar,1), false);
            end
            if ~exist('x','var') || isempty(x)
                x = 1:length(y{1});
            end
            if ismatrix(x)
                x = W.arrayfun(@(t)x(t, :), 1:size(x,1), false);
            end
            if length(x) == 1
                x = repmat(x, 1, length(y));
            end
            % ----------- get plot type
            if ~exist('type', 'var') || isempty(type)
                type = 'line';
            end
            func = eval(sprintf('@obj.%splot', type));
            func(x, y, errbar, varargin{:}); % NEED TO CHANGE
        end
        function barplot(obj, x, y, errbar, varargin)
            nls = length(y);
            if nls > 1
                W.print('multiple barplots not implemented, only the first bar will be plotted');
            end
            % ----------- Set optional variables
            opt_params = struct('color', [], 'linestype', '.', ...
                'barside', 'both', ...
                'addtolegend', 1, 'individualcolor', 0);
            opt_params = W.struct_set_parameters(opt_params, varargin{:});
            opt_params.color = obj.translatecolors(opt_params.color);
            opt_params = obj.param_autofill(opt_params, nls);
            % ----------- plot
            li = 1;
            tx = x{li};
            ty = y{li};
            terr = errbar{li};
            if ~isempty(terr)
                switch opt_params.barside{1}
                    case 'both'
                        terrneg = terr;
                        terrpos = terr;
                    case '+'
                        terrneg = terr * 0;
                        terrpos = terr;
                    case '-'
                        terrneg = terr;
                        terrpos = terr * 0;
                    case 'auto1'
                        terrneg = terr .* (ty <= 0);
                        terrpos = terr .* (ty >= 0);
                end
            end
            if all(isnan(ty))
                bb = bar(NaN, NaN);
            else
                hold on;
                if opt_params.individualcolor{1}
                    for i = 1:length(tx)
                        bb = bar(tx(i), ty(i));
                        if length(tx) <= length(opt_params.color)
                            bb.FaceColor = opt_params.color{i};
                        end
                        if ~isempty(terr)
                            eb = errorbar(tx(i), ty(i), terrneg(i), terrpos(i), opt_params.linestype{li}, ...
                                'LineWidth', obj.param_plt.linewidth);
                            eb.CapSize = obj.param_plt.capsize_errorbar;
                            if length(tx) <= length(opt_params.color)
                                eb.MarkerFaceColor = opt_params.color{i};
                                eb.Color = opt_params.color{i};
                            end
                        end
                    end
                else
                    bb = bar(tx, ty);
                    if ~isempty(opt_params.color)
                        bb.FaceColor = opt_params.color{1};
                    end
                    if ~isempty(terr)
                        eb = errorbar(tx, ty, terrneg, terrpos, opt_params.linestype{li}, ...
                            'LineWidth', obj.param_plt.linewidth);
                        eb.CapSize = obj.param_plt.capsize_errorbar;
                        if ~isempty(opt_params.color)
                            eb.MarkerFaceColor = opt_params.color{1};
                            eb.Color = opt_params.color{1};
                        end
                    end
                end
                hold off;
            end
            obj.fig.object_list{obj.fig.axi}(end + 1) = bb;
        end
        function lineplot(obj, x, y, errbar, varargin)
            nls = length(y);
            % ----------- Set optional variables
            opt_params = struct('color', [], 'linestyle', '-', 'addtolegend', 1);
            opt_params = W.struct_set_parameters(opt_params, varargin{:});
            opt_params.color = obj.translatecolors(opt_params.color);
            opt_params = obj.param_autofill(opt_params, nls);
            % ----------- plot
            for li = 1:nls
                tx = x{li};
                ty = y{li};
                terr = errbar{li};
                if all(isnan(ty))
                    eb = plot(NaN, NaN);
                else
                    hold on;
                    if isempty(terr)
                        eb = plot(tx, ty, opt_params.linestyle{li}, ...
                            'LineWidth', obj.param_plt.linewidth);
                        eb.MarkerSize = obj.param_plt.markersize;
                    else
                        eb = errorbar(tx, ty, terr, terr, opt_params.linestyle{li}, ...
                            'LineWidth', obj.param_plt.linewidth);
                        eb.CapSize = obj.param_plt.capsize_errorbar;
                    end
                    if li <= length(opt_params.color) && ~isempty(opt_params.color{li}) 
                        eb.Color = opt_params.color{li};
                        eb.MarkerFaceColor = opt_params.color{li};
                    end
                    hold off;
                end
                if opt_params.addtolegend{li}
                    obj.fig.object_list{obj.fig.axi}(end + 1) = eb;
                end
            end
        end
        function [str] = scatter(obj, x, y, option, varargin) 
            % ----------- Set optional variables
            opt_params = struct('color', 'black', 'shape', '.', 'addtolegend', 1);
            opt_params = W.struct_set_parameters(opt_params, varargin{:});
            opt_params.color = obj.translatecolors(opt_params.color);         
            if ~exist('option', 'var') || isempty(option)
                option = 'dot';
            end
            axi = obj.fig.axi;
            x = W.vert(x);
            y = W.vert(y);
            idnan = isnan(x) | isnan(y);
            x = x(~idnan);
            y = y(~idnan);
            [r, p] = corr(x,y);
            dotsize = obj.param_plt.dotsize;
            hold on;
            st = plot(x, y, opt_params.shape, 'MarkerSize', dotsize, 'Color', opt_params.color{1});
            str = sprintf('R = %.2f, p = %g', r, p);
            if opt_params.addtolegend
                obj.fig.object_list{axi}(end + 1) = st;
            end
            switch option
                case 'corr'
                    l = lsline;
                    set(l, 'color', opt_params.color{1});
                    set(l, 'linewidth', obj.param_plt.linewidth);
                case 'diag'
                    xmin = min(min(x), min(y));
                    xmax = max(max(x), max(y));
                    dx = xmax - xmin;
                    xmin = xmin - dx * 0.2;
                    xmax = xmax + dx * 0.2;
                    plot([xmin,xmax], [xmin,xmax], '--k', 'linewidth', obj.param_plt.linewidth);
                    xlim([xmin xmax]);
                    ylim([xmin xmax]);
                otherwise
            end
        end
        function dashY(obj, x, yrg, varargin)
            opt_params = struct('color', 'black');
            opt_params = W.struct_set_parameters(opt_params, varargin{:});
            opt_params.color = obj.translatecolors(opt_params.color);   
            if ~exist('yrg', 'var') || isempty(yrg)
                yrg = ylim;
            end
            hold on;
            plot([x x],yrg(:), '--','LineWidth',obj.param_plt.linewidth/2, 'color', opt_params.color{1});
        end
        function dashX(obj, y, xrg, varargin)
            opt_params = struct('color', 'black');
            opt_params = W.struct_set_parameters(opt_params, varargin{:});
            opt_params.color = obj.translatecolors(opt_params.color);  
            if ~exist('xrg', 'var') || isempty(xrg)
                xrg = xlim;
            end
            hold on;
            plot(xrg(:),[y y], '--','LineWidth',obj.param_plt.linewidth/2, 'color', opt_params.color{1});
        end
    end
end