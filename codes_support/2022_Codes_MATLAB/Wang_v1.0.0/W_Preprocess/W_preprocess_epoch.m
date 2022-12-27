classdef W_preprocess_epoch < handle
    properties
    end
    methods(Static)
        function epochs_bybox(spikes, trials, filenames, eventname, eventmarker, eventmarker_ord, t_pre, t_post, stepsize, winsize, isoverwrite, is_use_est, is_verbose)
            if ~exist('isoverwrite', 'var')
                isoverwrite = false;
            end
            if ~exist('is_verbose','var')
                is_verbose = false;
            end
            W.parpool;
            spikes = W.encell(spikes);
            trials = W.encell(trials);
            fds = fileparts(filenames);
            files = W.basenames(filenames);
            files = W.file_deprefix(files);
            files = W.file_prefix(files, 'epoched');
            parfor fi = 1:length(files)
                file = files(fi);
                W.print('session %d/%d: %s',fi, length(files), file);
                savedir = W.mkdir(fullfile(fds(fi), sprintf('%s_win%d_step%d', eventname, winsize, stepsize)));
                savename = fullfile(savedir, W.enext(file,'mat'));
                if isoverwrite || ~exist(savename, 'file')
                    W.epoch_bybox(spikes{fi}, trials{fi}, eventmarker, eventmarker_ord, t_pre, t_post, stepsize, winsize, savename, is_use_est, is_verbose);
                end
            end
            W.parclose;
        end
        function epochs = epoch_bybox(spikes, trials, eventmarker, eventmarker_ord, t_pre, t_post, stepsize, winsize, savename, is_use_est, is_verbose)
            if ~exist('is_use_est', 'var') || isempty(is_use_est)
                is_use_est = false;
            end
            if is_use_est
                savename = W.file_suffix(savename, 'est');
            end
            id_col = find(any(ismember(trials.eventmarkers, eventmarker)), eventmarker_ord, 'first');
            if length(id_col) ~= eventmarker_ord
                W.warning('epoch: eventmarker %d at eventmarker_ord %d does not exist, check!', eventmarker, eventmarker_ord);
                return;
            end
            idx_lb = trials.eventmarkers(:, id_col) == eventmarker;
            nbox = size(trials.timestamps, 2);
            ev_time_box = NaN(size(trials,1), nbox);
            for boxi = 1:nbox
                if is_use_est
                    tm = trials.timestamps_est.(sprintf('timestamps_est_%d', boxi))(:, id_col);
                else
                    tm = trials.timestamps.(sprintf('timestamps_%d', boxi))(:, id_col);
                end
                ev_time_box(idx_lb, boxi) = tm(idx_lb);
                ev_time_box(~idx_lb, boxi) = NaN;
            end
            if is_verbose == 2
                wtb = waitbar(0, 'Starting');
            end
            epochs = cell(1, length(spikes.spiketrains));
            for si = 1:length(spikes.spiketrains)
                if is_verbose == 2
                    waitbar(si/length(spikes.spiketrains), wtb, ...
                        sprintf("epoching spikes %d", si));
                elseif is_verbose == 1
                    W.print('epoching spikes %d', si);
                end
                time_at = [t_pre:stepsize:t_post];
                epochs{si} = W.epoch(spikes.spiketrains{si}, ev_time_box(:, spikes.boxID(si)), time_at/1000, winsize/1000);
            end
            if is_verbose == 2
                close(wtb);
            end
            info_spikes = rmfield(spikes, 'spiketrains');
            if exist('savename', 'var')
                W.save(savename, 'info_spikes', info_spikes, 'epochs', epochs, 'time_at', time_at, 'time_window', winsize);
            end
        end
        function xs = epochs(sts, tm, tat, twin)
            sts = W.encell(sts);
            ncell = length(sts);
            xs = cell(1, ncell);
            for ci = 1:ncell
                xs{ci} = epoch(sts{ci}, tm, tat, twin);
            end
        end
        function x = epoch(st,  tm, tat, twin)
            % st - spike train
            % tm - time stamps
            % tat - time points around tm
            % twin - compute firing in twin around tat
            nbin = length(tat);
            ntrial = length(tm);
            st = W.vert(st);
            tm = W.vert(tm);
            x = zeros(ntrial, nbin);
            for j = 1:nbin
                t1 = tm + tat(j) - twin/2;
                t2 = tm + tat(j) + twin/2;
                x(:, j) = arrayfun(@(x)sum(st >= t1(x) & st < t2(x)), 1:ntrial);
            end
            x(isnan(tm),:) = NaN;
        end
    end
end