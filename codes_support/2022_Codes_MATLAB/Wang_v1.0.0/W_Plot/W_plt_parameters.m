classdef W_plt_parameters < W_plt_param_database
    properties
        param_setting
        param_plt
        custom_vars
    end
    methods
        function obj = W_plt_parameters()
            obj.param_setting = struct('isshow', true, ...
                'issave', false, ...
                'savedir', '', ...
                'savepfx', '', ...
                'savesfx', '', ...
                'extension', 'jpg');
            obj.reload_paramdatabase();
            obj.custom_vars = struct;
        end
        function set_custom_variables(obj, varargin)
            obj.custom_vars = W.struct_set_parameters(obj.custom_vars, varargin{:}, 'overwrite');
        end
        function set_pltsetting(obj, varargin)
            obj.param_setting = W.struct_set_parameters(obj.param_setting, varargin{:});
        end
        function reload_paramdatabase(obj, version_plt, ratio)
            arguments
                obj;
                version_plt = 'default';
                ratio = 1;
            end
            obj.param_plt = obj.param_database.param_plt.(version_plt);
            obj.param_scale(ratio);
        end
        function newparam = param_scale(obj, ratio, setting_plt, issetplt)
            if ~exist('setting_plt', 'var') || isempty(setting_plt)
                setting_plt = obj.param_plt;
            end
            if ~exist('issetplt', 'var') || isempty(issetplt)
                issetplt = false;
            end
            newparam = structfun(@(x)x * ratio, setting_plt, 'UniformOutput', false);
            if issetplt
                obj.param_plt = newparam;
            end
        end
        function param = param_autofill(obj, param, n)
            fnms = W.fieldnames(param);
            for fi = 1:length(fnms)
                fn = fnms{fi};
                param.(fn) = W.encell(param.(fn));
                if length(param.(fn)) == 1
                    param.(fn) = repmat(param.(fn), 1, n);
                end
            end
        end
    end
end