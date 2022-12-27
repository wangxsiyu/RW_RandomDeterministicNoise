classdef W_tools_print < handle
    properties
    end
    methods(Static)
        function muteprint()
            global muteprint
            muteprint = 1;
        end
        function unmuteprint()
            global muteprint
            muteprint = 0;
        end
        function print(str, varargin)
            global muteprint
            if ~isempty(muteprint) && muteprint
                return;
            end
            fprintf(strcat(str,'\n'), varargin{:});
        end
        function warning(str, varargin)
            global muteprint
            if ~isempty(muteprint) && muteprint
                return;
            end
            cprintf('Yellow', ['[W-Warning] ' char(str) '\n'], varargin{:});
        end
        function error(str, varargin)
            global muteprint
            if ~isempty(muteprint) && muteprint
                return;
            end
            cprintf('Red', ['[W-Error] ' char(str) '\n'], varargin{:});
        end
        function disp(strs, pfx)
            strs = W.string(strs);
            pfx = W.string(pfx);
            if length(pfx) == 1
                pfx = repmat(pfx, 1, length(strs));
            end
            for i = 1:length(strs)
                fprintf('%s%s\n', pfx(i), strs(i));
            end
        end
    end
end