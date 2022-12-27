classdef W_neuro_spikes_cleaning < handle
    methods(Static)
        function [data, spikes_cleaning_info] = clean_spikes(data, thres_fr, thres_perc_missing, alpha_anova, varargin)
            spikes_cleaning_info = W.get_spikes_cleaning_info(data.spikes, data.info_spikes, data.time_window, varargin{:});
            is_keep_fr = spikes_cleaning_info.fr_approx >= thres_fr;
            is_keep_missing = spikes_cleaning_info.perc_missing < thres_perc_missing;
            is_keep_anova = spikes_cleaning_info.percbin_sig > alpha_anova;
            is_keep = is_keep_anova & is_keep_fr & is_keep_missing;
            data.spikes = data.spikes(is_keep);
        end
        function out = get_spikes_cleaning_info(spikes, info_spikes, time_window, wv_anova)
            if ~exist('time_window', 'var') || isempty(time_window)
                time_window = [];
            end
            out = struct;
            out.fr_approx = W.approximate_firingrate(spikes, time_window);
            [perc_missing, perc_startend] = W.identify_missing_spikeschunks(spikes);
            out.perc_missing = W.horz(perc_missing);
            out.perc_startend = perc_startend';
            out.rater_confidence = W.horz(info_spikes.raterconfidence);
            if exist('wv_anova', 'var')
                out.is_sig = W.decell(wv_anova.anova.is_sig);
                out.percbin_sig = W.decell(wv_anova.anova.percbin_sig);
                out.raw_sig = wv_anova.raw_panova;
            end
        end
        function fr_approx = approximate_firingrate(spikes, time_window)
            if ~exist('time_window', 'var') || isempty(time_window) % in ms
                time_window = 1000;
            end
            time_window = time_window/1000;
            fr_approx = cellfun(@(x)mean(x, 'all'), spikes)/time_window;
        end
        function [perc_missing, perc_startend] = identify_missing_spikeschunks(spikes)
            spikes = W.cellfun(@(x)sum(x, 2), spikes, false);
            spikes = horzcat(spikes{:});
            ncell = size(spikes,2);
            perc_missing = zeros(ncell,1);
            perc_startend  = zeros(ncell,2);
            ntrials = size(spikes,1);
            for i = 1:ncell
                t0 = W.get_consecutive0(spikes(:,i));
                if ~all(isnan(t0.duration))
                    perc_missing(i) = max(t0.duration)/ntrials;
                    if any(t0.start == 1)
                        perc_startend(i,1) = t0.duration(t0.start == 1)/ntrials;
                    end
                    if any(t0.end == ntrials)
                        perc_startend(i,2) = t0.duration(t0.end == ntrials)/ntrials;
                    end
                end
            end
        end
    end
end