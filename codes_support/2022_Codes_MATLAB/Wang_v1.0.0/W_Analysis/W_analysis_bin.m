classdef W_analysis_bin < handle
    properties
    end
    methods(Static)
        function out = analysis_tab_av_bygroup(tab, gpvar, gpIDs, varnameXs, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if W.is_stringorchar(gpvar) && length(string(gpvar)) == 1                
                strY = upper(gpvar);
                gpvar = tab.(gpvar);
            else
                strY = 'GP';
            end
            if ~exist('gpIDs','var') || isempty(gpIDs)
                gpIDs = unique(gpvar,'stable');
            end
            gpvar = W.string(gpvar);
            gpIDs = W.string(gpIDs);
            out = struct;
            varnameXs = W.encell(varnameXs);
            for i = 1:length(varnameXs)
                fn = varnameXs{i};
                strX = upper(fn);
                [tav, tse, tnum] = ...
                    W.analysis_av_bygroup(tab.(fn), gpvar, gpIDs, ismedian);
                nam = W.iif(ismedian, 'mid', 'av');
                out.(strcat(nam,strX,'_by',strY)) = tav;
                if ~ismedian
                    out.(strcat('se',strX,'_by',strY)) = tse;
                end
                out.(strcat('n',strX,'_by',strY)) = tnum;
            end
        end
        function [av, se, num] = analysis_av_bygroup(x, idgroup, groupnames, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if exist('groupnames', 'var')
                idgroup = W.string(idgroup);
                groupnames = W.string(groupnames);
                idgroup = arrayfun(@(x)W.extend(find(x == groupnames)), idgroup);
            elseif ~isnumeric(idgroup) || max(idgroup) ~= length(unique(idgroup))
                idgroup = W.string(idgroup);
                groupnames = unique(W.string(idgroup), 'stable');
                idgroup = arrayfun(@(x)W.extend(find(x == groupnames)), idgroup);
            else
                groupnames = unique(idgroup);
            end
            ngroup = length(groupnames); 
            av = NaN(ngroup, size(x,2));
            se = NaN(ngroup, size(x,2));
            num = NaN(ngroup, size(x,2));
            x = W.vert(x);
            for i = 1:ngroup
                [av(i,:), se(i,:), num(i,:)] = W.avse(x(idgroup == i,:), ismedian);
            end
            av = W.horz(av);
            se = W.horz(se);
            num = W.horz(num);
        end
        function out = analysis_tab_av(tab, varnameXs, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            fns = W.str2cell(varnameXs);
            for fi = 1:length(fns)
                strX = upper(fns{fi});
                nam = W.iif(ismedian, 'mid', 'av');
                [out.([nam strX]), tse] = W.avse(tab.(fns{fi}), ismedian);
                if ~ismedian
                     out.(['se' strX]) = tse;
                end
            end
        end    
        function [out] = analysis_tab_av_bybin(tab, yvar, xvar, binx, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if W.is_stringorchar(xvar)
                strY = upper(xvar);
                xvar = tab.(xvar);
            else
                strY = 'BIN';
            end
            out = struct;
            yvar = W.encell(yvar);
            for i = 1:length(yvar)
                fn = yvar{i};
                strX = upper(fn);
                [tav, tse, tnum] = ...
                    W.bin_avY_byX(tab.(fn), xvar, binx, ismedian);
                nam = W.iif(ismedian, 'mid', 'av');
                out.(strcat(nam,strX,'_by',strY)) = tav;
                if ~ismedian
                    out.(strcat('se',strX,'_by',strY)) = tse;
                end
                out.(strcat('n',strX,'_by',strY)) = tnum;
            end
        end
        function [av, se, num] = bin_avY_byX(y, x, binx, ismedian)
            % only works for 1-D y and x
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if ~exist('x', 'var') || isempty(x)
                x = 1:length(y);
            end
            y = W.vert(y);
            binx = W.bin_1to2(binx);
            nbin = size(binx,1);
            num = NaN(1, nbin);
            av = NaN(1, nbin);
            se = NaN(1, nbin);
            for bi = 1:nbin
                idx = x >= binx(bi,1) & x < binx(bi,2);
                if ~any(idx)
                    num(bi) = 0;
                else
                    [av(bi), se(bi), num(bi)] = W.avse(y(idx), ismedian);
                end
            end
        end
        function bin = bin_1to2(bin)
            if size(bin,1) > 1 && size(bin,2) > 1
                return;
            end
            bin = horzcat(W.vert(bin(1:end-1)), W.vert(bin(2:end)));
        end
        function out = bin_middle(bin)
            bin = W.bin_1to2(bin);
            out = W.horz(mean(bin, 2));
        end
    end
end