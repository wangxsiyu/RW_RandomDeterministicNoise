classdef W_preprocess_trials2games < handle
    properties
    end
    methods(Static)
        function [idcols, indices] = get_eventmarker_indices(markers, varargin)
            % this function trusts that each marker requested only shows up
            % in one column
            if strcmp(varargin{1}, 'template')
                ev_template = varargin{2};
                varargin = varargin(3:end);
            else
                ev_template = markers;
            end
            if istable(ev_template)
                ev_template = table2struct(ev_template(1,:), 'ToScalar', true);
                findid = @(x)find(structfun(@(t)any(ismember(x, t)), ev_template));
            else
                findid = @(x)find(arrayfun(@(t)any(ismember(x, ev_template(:,t))), 1:size(ev_template,2)));
            end
            vars = struct(varargin{:});
            indices = struct;
            idcols = struct;
            fnms = fieldnames(vars);
            for i = 1:length(fnms)
                fn = fnms{i};
                idcols.(fn) = findid(vars.(fn));
                indices.(fn) = ismember(markers(:, idcols.(fn)), vars.(fn));
            end
        end
        function [rt_av, rts] = get_timestamps_indices(tms, idcols, indices)
            if istable(tms)
                tms = table2struct(tms, 'ToScalar', true);
            end
            fnms = fieldnames(idcols);
            rts = struct;
            rt_av = struct;
            for fi = 1:length(fnms)
                fn = fnms{fi};
                if isstruct(tms)
                    rts.(fn) =  W.decell(W.arrayfun(@(x)struct2array(structfun(@(t)t(:,x), tms, 'UniformOutput', false)), idcols.(fn)));
                else
                    rts.(fn) = tms(:,idcols.(fn));
                end
                if exist('indices', 'var') && isfield(indices, fn) 
                    % select not just column, but also only get markers from rows that match the event markers
                    if iscell(rts.(fn))
                        for j = 1:length(rts.(fn))
                            rts.(fn){j}(~indices.(fn)(:,j),:) = NaN;
                        end
                    else
                        rts.(fn)(~indices.(fn),:) = NaN;
                    end
                end
                rt_av.(fn) = W.decell(W.cellfun(@(x)mean(x,2,'omitnan'),  W.encell(rts.(fn))));
            end
        end
    end
end