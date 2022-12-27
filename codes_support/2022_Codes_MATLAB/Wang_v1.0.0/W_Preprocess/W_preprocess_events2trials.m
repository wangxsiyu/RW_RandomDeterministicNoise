classdef W_preprocess_events2trials < handle
    properties
    end
    methods(Static)
        function [event, trialID, pos_event, is_extra] = events2match(event, mks, usenext)
            if ~exist('usenext', 'var')
                usenext = [];
            end
            if ~isempty(usenext)
                usenext = [find(cellfun(@(x)all(ismember(x,[usenext])), mks))];
                % for these identical markers, if there are
                % multiple possible bins, use the next bin (assume no missing markers)
            end
            W.print('matching eventmarkers to template');
            % this function can't deal with cases where almost an entire trial is
            % missing. (for example, cases where a marker in a previous trial is
            % followed by the next marker in the next trial).
            nevent = length(event);
            nmks = length(mks);
            % - calc pos_event --------------------------------------------
            pos_event = NaN(nevent, 1);
            is_extra = false(nevent, 1);
            % find which bins each marker belongs to
            findbins = @(x, mks)find(cellfun(@(t)ismember(x, t), mks));
            bins = W.arrayfun(@(x)findbins(x, mks), event, false);
            id_1bin = cellfun(@(x)length(x) == 1, bins);
            pos_event(id_1bin) = [bins{id_1bin}];
            flag_repeat = true;
            while flag_repeat
                % resolve for eventmarkers that belong to more than 1 bins
                id_not1 = find(arrayfun(@(x)length(bins{x}) ~= 1 && isnan(pos_event(x)), 1:nevent));
                if isempty(id_not1)
                    break;
                end
                % step #0: calculate the range of markers between the unique
                % markers in the bin before and after
                id_not1_excludeheadtail = setdiff(id_not1, [1 nevent]);
                tev_before = pos_event(id_not1_excludeheadtail-1);
                tev_after = pos_event(id_not1_excludeheadtail+1);
                if ismember(1, id_not1)
                    tev_before = [nmks; tev_before];
                    tev_after = [pos_event(2);tev_after];
                end
                if ismember(nevent, id_not1)
                    tev_before = [tev_before; pos_event(nevent - 1)];
                    tev_after = [tev_after; tev_before(end)];
                end
                isnanafter = isnan(tev_after) & ~isnan(tev_before);
                tev_after(isnanafter) = tev_before(isnanafter);
                idnan = isnan(tev_after) | isnan(tev_before);
                id_not1 = id_not1(~idnan);
                tev_before = tev_before(~idnan);
                tev_after = tev_after(~idnan);
                validrange = W.arrayfun(@(x)W.iif(tev_before(x)+1<=tev_after(x)-1, ...
                    tev_before(x)+1:tev_after(x)-1, [tev_before(x)+1:nmks, 1:tev_after(x)-1]), 1:length(id_not1), false);
                % step #1: if there is one possible marker between before
                % and after
                bins_in_validrange = W.arrayfun(@(x)intersect(validrange{x}, bins{id_not1(x)}, 'stable'), 1:length(id_not1), false);
                id_canfix1 = W.cellsize(bins_in_validrange) == 1;
                % step #2: for immediate next indices
                bins_first = cellfun(@(x)W.extend(x,1), bins_in_validrange);
                id_canfix2 = W.horz(W.mod0(tev_before+1, nmks)) == bins_first;
                % step #3: for usenext indices, use the next marker
                id_canfix3 = ismember(bins_first, usenext);
                if any(id_canfix2 & ~id_canfix3 & ~id_canfix1)
                    W.print('#%d ambiguous markers set to be the next adjacent marker (not in usenext)', sum(id_canfix2 & ~id_canfix3 & ~id_canfix1));
                end
                if any(id_canfix3 & ~id_canfix2 & ~id_canfix1)
                    W.print('#%d ambiguous markers set to be the next nonadjacent marker (in usenext)', sum(id_canfix3 & ~id_canfix2 & ~id_canfix1));
                end
                id_canfix = id_canfix1 | id_canfix2 | id_canfix3;
                pos_event(id_not1(id_canfix)) = bins_first(id_canfix);
                flag_repeat = any(id_canfix);
                
                % step %4: consider codes that's not in any bin
                idwrong = arrayfun(@(x)isempty(bins{x}), id_not1);
                if any(idwrong)
                    id_not1 = id_not1(idwrong);
                    validrange = validrange(idwrong);
                    valid_repair = W.cellfun(@(x)[mks{x}], validrange, false);
                    tev = event(id_not1);
                    for ii = 1:length(tev)
                        tismatch =  arrayfun(@(x)W.repair_binarycodecompare(tev(ii), x), valid_repair{ii});
                        if sum(tismatch) == 1 % only one match
                            [ismatch, tcode] = W.repair_binarycodecompare(tev(ii), valid_repair{ii}(find(tismatch)));
                            if ismatch
                                flag_repeat = true;
                                event(id_not1(ii)) = tcode;
                                pos_event(id_not1(ii)) = intersect(validrange{ii}, findbins(tcode,mks));
                            else
                                W.error('should not happen, MUST check!');
                            end
                        elseif sum(tismatch) == 0 % zero match
                            W.warning('extra code: %d', tev(ii));
                            pause;
                            flag_repeat = true;
                            is_extra(id_not1(ii)) = true;
                        else
                            W.warning('code %d has more than 2 matches for potential repair, ignored', tev(ii));
                        end
                    end
                end

                % set pos_event (is_extra) to be the previous pos_event
                id_extra_nanpos = find(is_extra & isnan(pos_event));
                if ~isempty(id_extra_nanpos)
                    for ii = 1:length(id_extra_nanpos)
                        if id_extra_nanpos(ii) == 1
                            pos_event(1) = 1;
                            flag_repeat = true;
                            continue;
                        end
                        if ~isnan(pos_event(id_extra_nanpos(ii) - 1))
                            pos_event(id_extra_nanpos(ii)) = pos_event(id_extra_nanpos(ii) - 1);
                            flag_repeat = true;
                        end
                    end
                end
            end
            % still unfixed ones? (this includes extra markers)
            if any(isnan(pos_event) & ~is_extra)
                W.error('events2trials: unsorted marker ID, please check!')
                disp(find(isnan(pos_event)));
                disp(event(isnan(pos_event)));
                pause;
            end
            % - calc trialID ----------------------------------------------
            trialID = zeros(nevent,1);
            id_trialstart = [0; find(diff(pos_event) < 0)] + 1;
            trialID(id_trialstart) = 1;
            trialID = cumsum(trialID);
        end
        function tab = events2trials(events, mks, mkignore, varargin)
            % varargin: usenext
            if exist('mkignore', 'var')
                id_ignore = ismember(events.eventmarkers, mkignore);
                events = events(~id_ignore,:);
            end
            [events.eventmarkers, trialID, pos_event, is_extra] = W.events2match(events.eventmarkers, mks, varargin{:});
            ntrial = max(trialID);
            nmks = length(mks);
            nevent = length(pos_event);
            tab = table;
            events = W.tab_decombine(events);
            fnms = W.fieldnames(events);
            W.print('converting events to trials');
            for fi = 1:length(fnms)
                fn = fnms{fi};
                if W.is_stringorchar(events.(fn)) | iscell(events.(fn)) % assuming char/cell of chars
                    tab.(fn) = repmat(unique(events.(fn)), ntrial, 1);
                else
                    tab.(fn) = NaN(ntrial, nmks);
                    for i = 1:nevent
                        if ~is_extra(i)
                            tab.(fn)(trialID(i), pos_event(i)) = events.(fn)(i);
                        end
                    end
                end
            end
            tab.extra_markers = cell(ntrial, 1);
            % deal with extra markers
            for i = find(is_extra(i))
                if isempty(tab.extra_markers{trialID(i)})
                    tab.extra_markers{trialID(i)} = events(i,:);
                else
                    tab.extra_markers{trialID(i)} = vertcat(tab.extra_markers{trialID(i)}, events(i,:));
                end
            end
            tab = W.tab_fill(tab, 'event_template', mks);
            tab = W.tab_addID(tab, 'trialID');
        end
    end
end