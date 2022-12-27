classdef W_import_behavior < handle
    properties
    end
    methods(Static)
        function data = IMPORT_datafiles_subID_yyyymmddTHHMMSS(datadir, filetemplate, importfunc, ...
                str_subID, num_subID, str_datetime, num_datetime, subIDrange, outputdir, outputname)
            % this function works for files with format:
            % PRESTR_subjectID_yyyymmddTHHMMSS.mat
            % if importfunc includes a column named gameNumber
            files = dir(fullfile(datadir, filetemplate));
            subs = W.get_SubIDDatetime({files.name}, str_subID, num_subID, str_datetime, num_datetime);
            idx_subID = ([subs.subjectID] >= subIDrange(1)) & ([subs.subjectID] <= subIDrange(2));
            files = files(idx_subID);
            subs = subs(idx_subID);
            games = W.IMPORT_datafiles(importfunc, files);
            [games, tid] = W.cell_squeeze(games);
            subs = subs(tid);
            W.print('Processing...');
            subtable = unique(struct2table(subs));
            data = [];
            for gi = 1:length(games)
                tgame = games{gi};
                if istable(tgame)
                    ttab = tgame;
                else
                    tgame = W.struct_fill1(tgame);
                    ttab = struct2table(tgame);
                end
                ttab = join(ttab, subtable);
                data = W.tab_vertcat(data, ttab);
            end
            % re-order excel columns
            idx_filename = find(strcmp(fieldnames(data), 'filename'));
            data = data(:,[idx_filename:size(data,2), 1:idx_filename-1]);
            if exist('outputname','var') && exist('outputdir','var') && ~isempty(outputname)
                writetable(data, fullfile(outputdir ,['RAW_', outputname, '.csv']));
            end
            W.print('Completed - imported from raw files');
        end
        function out = get_SubIDDatetime(filenames, str_subID, num_subID, str_datetime, num_datetime)
            for fi = 1:length(filenames)
                filename = filenames{fi};
                out(fi).subjectID = str2double(W.strs_selectbetween2patterns(filename, str_subID{1}, str_subID{2}, ...
                    num_subID(1), num_subID(2)));
                strdatetime = W.strs_selectbetween2patterns(filename, str_datetime{1}, str_datetime{2}, ...
                    num_datetime(1), num_datetime(2));
                out(fi).date = yyyymmdd(datetime(strdatetime));
                out(fi).time = timeofday(datetime(strdatetime));
                out(fi).filename = string(filename);
            end
        end
        function games = IMPORT_datafiles(funcimport, files)
            % by sywangr@email.arizona.edu
            % version 1.0
            nfile = length(files);
            games = cell(1, nfile);
            for fi = 1:nfile
                filename = files(fi).name;
                W.print('importing file %d/%d: %s', fi, nfile, filename);
                tic
                tdata = load(fullfile(files(fi).folder, filename));
                tgame = funcimport(tdata);
                if ~isempty(tgame)
                    for ti = 1:length(tgame)
                        tgame(ti).filename = string(filename);
                    end
                else
                    W.print('failed to import - empty output');
                end
                games{fi} = tgame;
                toc
            end
            W.print('Complete: %d files imported', nfile);
        end
    end
end