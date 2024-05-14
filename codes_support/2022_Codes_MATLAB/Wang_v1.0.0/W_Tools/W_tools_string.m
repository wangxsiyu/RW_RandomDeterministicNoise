classdef W_tools_string < handle
    properties
    end
    methods(Static)
        function str = str_capitalize1(str)
            str = W.str2cell(str);
            idnonempty = W.cellsize(str) > 0;
            if any(idnonempty)
                idnonempty = find(idnonempty);
                str(idnonempty(1)) = W.cellfun(@(x)W.strcat(upper(x(1)), x(2:end)), str(idnonempty(1)), false);
            end
%             x = str{1};
%             str{1} = W.strcat(upper(x(1)), x(2:end));
            str = W.string(str);
        end
        function out = str_de_(str, opt_str)
            if ~exist('opt_str', 'var') || isempty(opt_str)
                opt_str = ' ';
            end
            out = replace(str, '_', opt_str);
        end
        function out = is_stringorchar(x)
            out = ischar(x) || isstring(x);
        end
        function out = select_cellofstringorchar(x)
            % only keep string/chars from a cell
            x = W.encell(x);
            idchar = cellfun(@(t)W.is_stringorchar(t), x);
            if ~(all(idchar, 'all'))
                W.warning('select_cellofstringorchar: some cells are not character/string variables, ignored');
            end
            out = x(idchar);
        end
        function out = cell_enchar(x)
            x = W.str2cell(x);
            out = cellfun(@(t)char(string(t)), x, 'UniformOutput', false);
        end
        function out = cell_enstr(x)
            x = W.str2cell(x);
            out = cellfun(@(t)string(t), x, 'UniformOutput', false);
        end
        function out = str2cell(str)
            % str2cell: turn arrays of strings to cell arrays of chars
            if W.is_stringorchar(str)
                out = W.arrayfun(@(x)char(x), string(str), false);
            else
                out = W.encell(str);
            end
            out = W.horz(out);
        end
        function out = string(x)
            x = W.decell(x);
            if isnumeric(x)
                out = string(arrayfun(@(t)num2str(t), x, 'UniformOutput', false));
            else
                out = string(x);
            end
        end
        function out = str_selectbetween2patterns(str, spre, spost, npre, npost)
            if ~exist('npre','var') || isempty(npre)
                npre = 1;
            end
            if ~exist('npost','var') || isempty(npost)
                npost = 1;
            end
            if ~exist('spre','var')
                spre = [];
            end
            if ~exist('spost','var')
                spost = [];
            end
            str = char(str);
            if isempty(spre)
                n1 = 1;
            else
                idxpre = strfind(str, spre);
                if npre < 0 % choose according to the inverse order, -1 is the last 
                    npre = length(idxpre) + 1 + npre;
                end
                n1 = idxpre(npre) + length(spre);
            end
            if isempty(spost)
                n2 = length(str);
            else
                idxpost = strfind(str, spost);
                if npost < 0 % choose according to the inverse order, -1 is the last 
                    npost = length(idxpost) + 1 + npost;
                end
                n2 = idxpost(npost) - 1;
            end
            out = string(str(n1:n2));
        end
        function out = strs_selectbetween2patterns(strs, varargin)
            strs = W.string(strs);
            out = W.arrayfun(@(x)W.str_selectbetween2patterns(x, varargin{:}), strs);
        end
        function out = str_parse2cell(strs, sep)
            % str_parse2cell: turn strings separated by sep = ',' into string arrays 
            if ~exist('sep', 'var') || isempty(sep)
                sep = ',';
            end
            strs = string(strs);
            out = arrayfun(@(x)strsplit(x, sep), strs, 'UniformOutput', false);
            LEN = max(W.cellsize(out));
            out = cellfun(@(x)W.extend(x, LEN), out, 'UniformOutput', false);
            out = vertcat(out{:});
        end
        function [out, idxselect] = str_select(str, option)
            % options in isstrprop
            if ~exist('option', 'var') || isempty(option)
                option = 'digit';
            end
            option = char(option);
            if contains(option, '!')
                option = option(2:end);
                opt_rev = 1;
            else
                opt_rev = 0;
            end
            str = W.decell(str); % deal with {"str"}
            str = char(str);
            idxselect = isstrprop(str, option);
            if opt_rev == 1
                option = 'rev';
                idxselect = ~idxselect;
            end
            if ~any(idxselect, 'all')
                out = W.iif(strcmp(option, 'digit'), NaN, '');
            else
                tidxnum = find(idxselect);
                tword = [0 find(diff(tidxnum) > 1) length(tidxnum)] + 1;
                nword = length(tword) - 1;
                out = cell(1, nword);
                for i = 1:nword
                    out{i} = str(tidxnum(tword(i):tword(i+1)-1));
                end
                if strcmp(option, 'digit')
                    out = cellfun(@(x)str2double(x), out);
                end
            end
            out = W.decell(out);
        end
        function [out, idxselect] = strs_select(strs, varargin)
            strs = W.str2cell(strs);
            out = cell(1, length(strs));
            idxselect = cell(1, length(strs));
            for i = 1:length(strs)
                [out{i}, idxselect{i}] = W.str_select(strs{i}, varargin{:});
            end
            out = W.decell(out);
            idxselect = W.decell(idxselect);
        end
        function str = str_datetime(str, informat, outformat)
            str = W.str2cell(str);
            [~, idxnum] = cellfun(@(x)W.str_select(x, 'digit'), str, 'UniformOutput', false);
            digits = W.arrayfun(@(x)str{x}(idxnum{x}), 1:length(str));
            [strs] = cellfun(@(x)W.str_select(x, '!digit'), str, 'UniformOutput', false);
            strs = W.cellfun(@(x)W.iif(iscell(x), x, {x}), strs, false);
            newdigits = W.cellfun(@(x)W.datetime(x, informat, outformat), digits);
            str = arrayfun(@(x)string(strcat(strs{x}{1}, newdigits{x}, strs{x}{2:end})), 1:length(str));
        end
        function [tid, patterns] = str_getID(strs, patterns)
            strs = W.str2cell(strs);
            if ~exist('patterns', 'var') || isempty(patterns)
                patterns = unique(strs);
            end
            tid = W.cellfun(@(x)find(strcmp(x, patterns)), strs);
        end
    end
end