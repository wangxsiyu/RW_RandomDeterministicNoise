classdef W_tools_basic < handle
    properties
    end
    methods(Static)
        %% inline ifelse
        function out = iif(istrue, a, b)
            if istrue
                out = a;
            else
                out = b;
            end
        end
        %% vertical vs horizontal vector
        function a = vert(a)
            if size(a,1) == 1
                a = a';
            end
        end
        function a = horz(a)
            if size(a,2) == 1
                a = a';
            end
        end
        %% a % b - set 0 to b
        function out = mod0(a,b,varargin)
            out = mod(a,b,varargin{:});
            if any(out == 0,'all')
                out(out == 0) = b;
            end
        end
        %% is_between
        function out = is_between(xs, bin)
            out = arrayfun(@(x)x > bin(1) & x < bin(2), xs);
        end
        %% cellfun/arrayfun
        function [out] = cellfun(func, a, uniformoutput)
            % doesn't work for multiple outputs from cellfun
            if ~exist('uniformoutput','var') || isempty(uniformoutput)
                uniformoutput = true;
            end
            a = W.encell(a);
            try
                [out] = cellfun(func, a, 'UniformOutput', uniformoutput);
            catch
                [out] = cellfun(func, a, 'UniformOutput', false);
            end
        end
        function out = arrayfun(func, a, uniformoutput)
            if ~exist('uniformoutput','var') || isempty(uniformoutput)
                uniformoutput = true;
            end
            a = W.decell(a);
            try
                out = arrayfun(func, a, 'UniformOutput', uniformoutput);
            catch
                out = arrayfun(func, a, 'UniformOutput', false);
            end
        end
    end
end