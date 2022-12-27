classdef W_plt_param_database < handle
    properties
        param_database
    end
    methods
        function obj = W_plt_param_database()
            obj.param_database.colors = W_plt_param_colors;
            obj.param_database.param_plt = W_plt_param_figures;
        end
        function col = translatecolors(obj, col)
            if isempty(col)
                return;
            end
            col = W.str2cell(col);
            id_str = cellfun(@(x)W.is_stringorchar(x), col);
            if any(id_str)
                col(id_str) = W.cellfun(@(x)obj.str2color(x), col(id_str), false);
            end
        end
        function col = str2color(obj, str)
            if isnumeric(str)
                col = str;
                return;
            elseif ~W.is_stringorchar(str)
                W.error('W_plt.str2color: input should be char or string');
                return;
            end
            str = char(str);
            [num, idx] = W.str_select(str);
            if isnan(num)
                num = 100;
            end
            str = str(~idx);
            try
                col = obj.param_database.colors.(str);
            catch
                col = [0,0,0];
                W.warning('color %s not found, use black instead', str);
            end
            col = col * num/100 + (1-num/100) * [1 1 1];
        end
        function col = interpolatecolors(~, cols, vals, x)
            for i = 1:3
                tcol = cellfun(@(x)x(i), cols);
                col(i) = interp1q(W.vert(vals), W.vert(tcol), x);
            end
        end
    end
end