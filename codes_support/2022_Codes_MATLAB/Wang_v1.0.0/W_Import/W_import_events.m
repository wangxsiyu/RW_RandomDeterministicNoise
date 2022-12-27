classdef W_import_events < W_import_tools
    properties
    end
    methods(Static)
        %% import
        function import_events(dirlist, savelist, format, isoverwrite, varargin)
            % varargin
            if ~exist('isoverwrite','var')
                isoverwrite = false;
            end
            func = str2func(strcat('W_import_events.import_',format));
            W.import_folder2file(func, dirlist, savelist, 'events', isoverwrite, 'boxID', varargin{:});
        end
        function [dir_box, fIDs] = nev_filesbybox(dirlist)
            dirlist = W.str2cell(dirlist);        
            boxID = cellfun(@(x)str2double(W.str_selectbetween2patterns(x, '_box', '.nev')), dirlist);
            sessionID = cellfun(@(x)W.str_selectbetween2patterns(x, [], '_box'), dirlist);
            sIDs = unique(sessionID);
            [~, fIDs] = fileparts(sIDs);
            dir_box = cell(1, length(sIDs));
            for i = 1:length(dir_box)
                dir_box{i} = {};
                tidx = find(sessionID == sIDs(i));
                cID = boxID(tidx);
                [~, od] = sort(cID);
                tidx = tidx(od);
                dir_box{i} = dirlist(tidx);
            end
        end
        function events = import_nev(files)
            W.library('NPMK')
            files = W.str2cell(files);
            events = [];
            for fi = 1:length(files)
                filename = char(files{fi});
                W.print('reading NEV: %s', filename);
                nev = openNEV(filename);
                event = table;
                event.eventmarkers = nev.Data.SerialDigitalIO.UnparsedData;
                event.timestamps = nev.Data.SerialDigitalIO.TimeStampSec';
                [~, fname] = fileparts(filename);
                event = W.tab_fill(event, 'filename', string(fname));
                events = W.tab_vertcat(events, event);
            end
        end
        %% merge between boxes
        function ev = merge_box_pair(ev1, ev2, eps)
            ev = table;
            if ~exist('eps', 'var')
                eps = 1e-3; % 1ms
            end
            n1 = size(ev1,1);
            n2 = size(ev2,1);
            n_min = min(n1, n2);
            t1 = ev1.timestamps;
            t2 = ev2.timestamps;
            tm_diff = mode(t1(1:n_min)- t2(1:n_min));
            t2new = t2 + tm_diff;
            if n1 == n2 && max(abs(t1 - t2new)) < eps % everything matches
                ev.eventmarkers_1 = ev1.eventmarkers;
                ev.eventmarkers_2 = ev2.eventmarkers;
                ev.timestamps_1 = t1;
                ev.timestamps_2 = t2;
            else
                W.warning('merge_2box: eventmarker length mismatch');
                % function that checks if each point in t is in t0
                func_tm_match = @(t, t0) arrayfun(@(x)min(abs(x-t0)) < eps, t);
                id_extra = ~func_tm_match(t2new, t1);
                tm_all = sort([t1; t2new(id_extra)]);
                n_total = length(tm_all);
                ev.timestamps_1 = NaN(n_total,1);
                ev.timestamps_2 = NaN(n_total,1);
                ev.eventmarkers_1 = NaN(n_total,1);
                ev.eventmarkers_2 = NaN(n_total,1);
                % function that checks where each point in t is in t0,
                % return NaN if a point in t is not in t0
                find_tm_match = @(t, t0) arrayfun(@(x)W.func('min',2,abs(x-t0)), t);
                id1 = find_tm_match(t1, tm_all);
                id2 = find_tm_match(t2new, tm_all);
                ev.eventmarkers_1(id1) = ev1.eventmarkers;
                ev.eventmarkers_2(id2) = ev2.eventmarkers;
                ev.timestamps_1(id1) = t1;
                ev.timestamps_2(id2) = t2;
            end
            ev.eventmarkers = W.repair_eventmarker_pair(ev.eventmarkers_1, ev.eventmarkers_2);
            ev = removevars(ev, {'eventmarkers_1', 'eventmarkers_2'});
            ev.timestamps_est_1 = ev.timestamps_1;
            tid = isnan(ev.timestamps_1);
            if any(tid)
                W.print('estimated timestamp of box 1 from box 2: %d total', sum(tid));
                ev.timestamps_est_1(tid) = ev.timestamps_2(tid) + tm_diff;
            end
            ev.timestamps_est_2 = ev.timestamps_2;
            tid = isnan(ev.timestamps_2);
            if any(tid)
                W.print('estimated timestamp of box 2 from box 1: %d total', sum(tid));
                ev.timestamps_est_2(tid) = ev.timestamps_1(tid) - tm_diff;
            end
        end
        function mk = repair_eventmarker_pair(mk1, mk2)
            % repairs eventmarkers if one of them is a binary suffix of the
            % other one, e.g. 11000 vs 101011000
            mk = NaN(length(mk1),1);
            tid = mk1 == mk2;
            mk(tid) = mk1(tid);
            tid_nan = isnan(mk1) | isnan(mk2);
            mk(tid_nan) = nanmean([mk1(tid_nan),mk2(tid_nan)]')';
            idxs = find(~tid & ~tid_nan);
            if length(idxs) > 0
                for i = 1:length(idxs)
                    idx = idxs(i);
                    [ismatch, mk(idx)] = W.repair_binarycodecompare(mk1(idx), mk2(idx));
                    if ~ismatch
                        % mismatch
                        W.error('eventmarkers mismatch: two different markers occur at the same time, MUST check!');
                        W.error('eventmarkers mismatch: unable to repair, skipped');
                        return
                    end
                end
            end
        end
        function [ismatch, d] = repair_binarycodecompare(d1, d2)
            b1 = dec2bin(d1);
            b2 = dec2bin(d2);
            len_min = min(length(b1), length(b2));
            ismatch = strcmp(W.select(b1, len_min, 'right'), W.select(b2, len_min, 'right'));
            if ismatch && nargout == 2 % match
                W.print('repaired markers %d vs %d', d1, d2);
                d = max(d1, d2);
            else
                d = NaN;
            end
        end
        function merges_box_pair(files, eventdir_merged)
            % load all events
            evs = W.load(files, 'csv');
            % merge each event file base on time
            for ei = 1:length(evs)
                savename = W.func('fileparts',2,files(ei));
                ev = evs{ei};
                if ~all(ismember(unique(ev.boxID),[1 2]))
                    W.warning('%s: there exists boxID > 3, skipping', savename)
                elseif length(unique(ev.boxID)) == 1
                    W.print('%s: unique boxID, directly saving', savename);
                    W.writetable(ev, fullfile(eventdir_merged, savename));
                    continue;
                end
                t1 = ev(ev.boxID == 1,:);
                t2 = ev(ev.boxID == 2,:);
                W.print('merging file %d: %s', ei, savename);
                ev = W.merge_box_pair(t1, t2);
                W.writetable(ev, fullfile(eventdir_merged, savename));
            end
        end
    end
end

%% removed functions

% function check_2box_consistent_eventmarker(evs) % only works for two boxes
% % check if the event markers are the same in both(all) boxes
% evs = W.encell(evs);
% nfile = length(evs);
% is_same_event = NaN([1, nfile]);
% for i = 1:nfile
%     ev = evs{i};
%     if length(unique(ev.boxID)) < 2
%         is_same_event(i) = 1;
%         continue;
%     end
%     if sum(ev.boxID == 1) ~= sum(ev.boxID == 2)
%         is_same_event(i) = 0;
%         W.print('file #%d: boxID 1 and 2 have different lengths', i);
%         continue;
%     end
%     is_same_event(i) = mean(ev.eventmarkers(ev.boxID == 1) == ev.eventmarkers(ev.boxID == 2));
%     if is_same_event(i) < 1
%         W.print('file #%d: %.2f percent of the markers mismatch', i, (1-is_same_event(i)) * 100);
%     end
% end
% if all(is_same_event == 1)
%     W.print('markers are consistent in all %d files', nfile);
% else
%     W.print('markers are not consistent in the above files');
% end
% end