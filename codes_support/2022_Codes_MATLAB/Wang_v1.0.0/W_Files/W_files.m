classdef W_files < handle
    properties
    end
    methods(Static)
        %%
        function out = get_fullpath(p)
            out = what(p);
            out = out.path;
        end
        %% change directory to current file
        function cd()
            folder = fileparts(matlab.desktop.editor.getActiveFilename);
            if ~isempty(folder)
                cd(folder);
                W.print('change directory to: %s', folder);
            else
                W.print('cd: no Matlab scripts open');
            end
        end
        % mkdir
        function folder = mkdir(folder)
            if ~exist(folder, 'dir')
                W.print('creating directory: %s', folder);
                mkdir(folder);
            end
        end
        %% deext and enext
        function out = deext(file)
            file = string(file);
            [p, n] = fileparts(file);
            if contains(n, ".")
                n = W.str_selectbetween2patterns(n, [], '.', 1, -1); 
            end
            out = fullfile(p, n);
        end
        function out = enext(file, ext)
            file = W.deext(file);
            out = strcat(file, ".", ext);
        end
        %% filenames
        function out = basenames(files)
            out = W.func('fileparts', 2, files);
        end
        function str = file_deprefix(str)
            [p, f] = fileparts(str);
            str = W.strs_selectbetween2patterns(f, '_',[],1);
            str = fullfile(p, str);
        end
        function str = file_desuffix(str)
            str = replace(str, '/', '\');
            deext = W.deext(str);
            deext_new = W.strs_selectbetween2patterns(deext, [], '_',[],-1);
            str = replace(str, deext, deext_new);
        end
        function str = file_prefix(str, pfx, sep)
            if isempty(pfx)
                return;
            end
            if ~exist('sep','var')
                sep = '_';
            end
            [p, n, ext] = fileparts(str);
            n = W.strcat(pfx, sep, n, ext);
            str = fullfile(p, n);
        end
        function str = strcat(varargin)
            varargin = W.cell_enstr(varargin);
            str = strcat(varargin{:});
        end
        function str = file_suffix(str, sfx, sep)
            if isempty(sfx)
                return;
            end
            if ~exist('sep','var')
                sep = '_';
            end
            [p, n, ext] = fileparts(str);
            n = strcat(n, sep, sfx, ext);
            str = fullfile(p, n);
        end
        function str = file_getprefix(str)
            str = W.basenames(str);
            str = W.strs_selectbetween2patterns(str, [], '_', 1,1);
        end
        function str = file_getsuffix(str)
            str = W.basenames(str);
            str = W.strs_selectbetween2patterns(str, '_', [], 1,1);
        end
        %% files and dirs
        function [outtab, out] = dir(str, option) % by default, output table
            arguments
                str char;
                option char = 'all';
                % all - both
                % file - files only
                % folder/dir - folders only
            end
            % exclude . ..
            out = dir(str);
            out = out(arrayfun(@(x)~any(strcmp({'.','..'}, x.name)), out));
            % exclude hidden files
            out = out(arrayfun(@(x)~strcmp(x.name(1), '.'), out));
            % select files or directory
            switch option
                case 'file'
                    out = out([out.isdir] == 0);
                case {'folder', 'dir'}
                    out = out([out.isdir] == 1);
            end
            filename = string({out.name})';
            filepath = string({out.folder})';
            fullpath = fullfile(filepath, filename);
            outtab = table(filename, filepath, fullpath);
        end
        function out = ls(dirs, varargin)
            dirs = W.str2cell(dirs);
            out = W.cellfun(@(x)W.dir(x, varargin{:}).fullpath, dirs);
            out = W.decell(out);
        end
        function out = ls_if_dir(str, varargin)
            str = W.str2cell(str);
            if length(str) == 1 && W.is_stringorchar(str{1}) && ...
                exist(str{1}, 'dir')
                W.print('unfolding folder: %s', str{1});
                out = W.ls(str{1}, varargin{:});
            else
                out = str;
            end
        end
        %% save
        function save(file, varargin)
            nvar = length(varargin);
            varlist = {};
            i = 0;
            while i+2 <= nvar
                varname = varargin{i+1};
                if W.is_stringorchar(varname)
                    varname = char(varname);
                else
                    W.error('save: expecting char for variable names');
                    return;
                end
                varval = varargin{i+2};
                eval([varname '= varval;']);
                varlist{end+1} = varname;
                i = i + 2;
            end
            W.mkdir(fileparts(file));
            save(file, varlist{:}, '-v7.3', varargin{i+1:end});
            W.print('saved successfully: %s', file)
        end
        %% load
        function [out, files] = load(files, option, varargin)
            if ~exist('option', 'var')
                option = 'mat';
            end
            files = W.ls_if_dir(files, 'file');
            files = W.str2cell(files);
            nfile = length(files);
            out = cell(1, nfile);
            for fi = 1:nfile
                files{fi} = W.enext(files{fi}, option);
                W.print('import data: %s', files{fi});
                switch option
                    case 'mat'
                        out{fi} = importdata(files{fi});
                    case 'csv'
                        out{fi} = W.readtable(files{fi}, varargin{:});
                    otherwise
                        W.error('unknown input option:%s', option);
                end
            end
            out = W.decell(out);
            files = string(files);
        end        
        function out = compile_csv(files)
            files = W.ls_if_dir(files);
            files = W.str2cell(files);
            tab = cell(1, length(files));
            for fi = 1:length(files)
                tfile = files{fi};
                W.print('reading %s', tfile);
                ttab = W.readtable(tfile);
                tab{fi} = W.tab_fill(ttab, 'csv_filename', W.basenames(tfile));
            end
            out = W.tab_vertcat(tab{:});
            disp('csv compiling complete');
        end
    end
end