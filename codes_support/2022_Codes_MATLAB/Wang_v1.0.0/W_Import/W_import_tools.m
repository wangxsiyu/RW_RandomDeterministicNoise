classdef W_import_tools < handle
    properties
    end
    methods(Static)
        function [data, fnames] = load_twofolders_matchingsuffix(fd1, fd2, fmt1, fmt2, isdesfx1, isdesfx2)
            if ~exist('fmt1', 'var') || isempty(fmt1)
                fmt1 = "mat";
            end
            if ~exist('fmt2', 'var') || isempty(fmt2)
                fmt2 = "mat";
            end
            if ~exist('isdesfx1', 'var') || isempty(isdesfx1)
                isdesfx1 = false;
            end
            if ~exist('isdesfx2', 'var') || isempty(isdesfx2)
                isdesfx2 = false;
            end
            [d1, files1] = W.load(fd1,fmt1);
            [d2, files2] = W.load(fd2,fmt2);
            d1 = W.encell(d1);
            d2 = W.encell(d2);
            % select common files
            b1 = W.file_deprefix(W.basenames(files1));
            if isdesfx1
                b1 = W.file_desuffix(b1);
            end
            b2 = W.file_deprefix(W.basenames(files2));
            if isdesfx2
                b2 = W.file_desuffix(b2);
            end
            fnames = intersect(b1, b2);
            tid = ismember(b1, fnames);
            d1 = d1(tid);
            tid = ismember(b2, fnames);
            d2 = d2(tid);
            fn1 = unique(W.file_getprefix(files1));
            data.(fn1) = W.decell(d1);
            fn2 = unique(W.file_getprefix(files2));
            data.(fn2) = W.decell(d2);
        end
        function import_folder2file(func, dirlist, savelist, varname, isoverwrite, varargin)
            arguments 
                func = @(varargin)[]; % this needs to be a function
                dirlist = {};    
                % dirlist can be lists of lists (there may be multiple folders for the same recording session)
                savelist = {};
                varname string = "data"; % if varname is table, then save as csv instead
                isoverwrite logical = false;
            end
            arguments (Repeating)
                varargin;
            end
            dirlist = W.str2cell(dirlist);
            savelist = W.str2cell(savelist);
            if ~isempty(savelist) && length(savelist) == length(dirlist)
                for di = 1:length(dirlist)
                    W.print('importing session #%d/%d', di, length(dirlist));
                    savelist{di} = W.file_prefix(savelist{di}, varname);
                    is_run = isoverwrite || ...
                        ~(exist(W.enext(savelist{di},'mat'), 'file') || exist(W.enext(savelist{di},'csv'), 'file'));
                    if ~is_run
                        W.print('skip %s', savelist{di});
                    else
                        data = W.import_subfolders2file(func, dirlist{di}, varargin{:});
                        if istable(data)
                            W.writetable(data, savelist{di});
                        elseif ~isempty(data)
                            W.save(savelist{di}, varname, data);
                        end
                    end
                end
            else
                W.warning('folder2file: savelist length != dirlist length, skip');
            end
            W.print('import complete!')
        end
        function data = import_subfolders2file(func, subdirlist, subfoldername, subfolderformat, varargin)
            if ~exist('subfoldername', 'var')
                subfoldername = 'subfolderID';
                % number, letter, or actual names
            end
            if ~exist('subfolderformat', 'var')
                subfolderformat = 'number'; % number or letter
            end
            subdirlist = W.encell(subdirlist);
            ndir = length(subdirlist);
            subfoldername = string(subfoldername);
            subfolderformat = string(subfolderformat);
            switch subfolderformat
                case 'number'
                    subfolderIDs = 1:ndir;
                case 'letter'
                    letterlists = ['A':'Z','a':'z'];
                    letterlists = arrayfun(@(x)string(x),letterlists);
                    subfolderIDs = letterlists(1:ndir);
                otherwise
                    W.warning('subfolders2file: unrecognized format, use number instead')
                    subfolderIDs = 1:ndir;
            end
            data = [];
            for di = 1:ndir
                W.print('importing sub-folder %d/%d', di, ndir);
                tdata = func(subdirlist{di}, varargin{:}); % return struct or table
                if ~isempty(tdata)
                    tdata.(subfoldername)(:,1) = repmat(subfolderIDs(di), max(W.fieldsize(tdata,[],1)),1);
                    if isstruct(tdata)
                        data = W.struct_append(data, tdata);
                    elseif istable(tdata)
                        data = W.tab_vertcat(data, tdata);
                    else
                        W.error('W_import.subfolders2file: func returns neither table nor struct');
                        return;
                    end
                end
            end
        end
    end
end