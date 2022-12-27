classdef W_import_spikes < W_import_tools
    properties
    end
    methods(Static)
        function import_spikes(dirlist, savelist, format, isoverwrite, varargin)
            % varargin
            if ~exist('isoverwrite','var')
                isoverwrite = false;
            end
            func = str2func(strcat('W_import_spikes.import_',format));
            W.import_folder2file(func, dirlist, savelist, 'spikes', isoverwrite, 'boxID', varargin{:});
        end
        %% mksort
        function spike = import_mksort(files, is_sorted)
            if ~exist('is_sorted', 'file') || isempty(is_sorted)
                is_sorted = true;
            end
            count = 0;
            wtb = waitbar(0, 'Starting');
            files = string(files);
            if length(files) == 1 && isfolder(files)
                files = W.dir(fullfile(files, 'waveforms*'));
                files = files.fullpath;
            end 
            for fi = 1:length(files)
                waitbar(fi/length(files), wtb, ...
                    sprintf("importing channel %d", fi));
                td0 = importdata(files(fi));
                if isfield(td0, 'waveforms')
                    td = td0.waveforms;
                    raterconf = td0.rater_confidence;
                else
                    td = td0;
                    raterconf = NaN(1,10);
                end
                tunits = unique(td.units); 
                if is_sorted
                    tunits = tunits(tunits > 0); % ignore noise and unsorted ones
                end
                for ti = 1:length(tunits)
                    count = count + 1;
                    tid = td.units == tunits(ti);
                    spike.spiketrains{count,1} = td.spikeTimes(tid)/1000; % unit s
                    spike.channelID(count,1) = str2double(W.str_selectbetween2patterns(files(fi), '_', '.mat', -1, 1));
                    spike.raterconfidence(count,1) = raterconf(tunits(ti));
                end
            end
            close(wtb);
        end
        function dir_box = mksort_filesbybox(dirlist)
            dirlist = W.str2cell(dirlist);
            dir_box = cell(1, length(dirlist));
            for di = 1:length(dirlist)
                dir_box{di} = {};
                files = W.dir(fullfile(dirlist{di}, 'waveforms*'));
                connectorID = arrayfun(@(x)W.str_selectbetween2patterns(x, '_', '_', 1, 2), files.filename);
                cIDs = unique(connectorID);
                for ci = 1:length(cIDs)
                    dir_box{di}{ci} = files.fullpath(connectorID == cIDs(ci));
                end
            end
        end
    end
end
