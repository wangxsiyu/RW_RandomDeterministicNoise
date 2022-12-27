classdef W_plt_base < W_plt_parameters
    properties
        fig % figure object
        custom_fig  
    end
    methods
        function obj = W_plt_base()
            obj.fig = [];
            obj.custom_fig = {};
        end
        %% figure
        function figure(obj, nx, ny, varargin)
            % optional parameters
            % matrix_hole: allow "off"/hidden axes, matrix of "on" axes 
            % matrix_title: matrix of "on" titles
            % is_title: '1' - only first row, 'all' - all axes
            % matrix_xlabel: matrix of "on" xlabels (>2 means multiple label lines)
            % is_xlabel: '1' - only last row
            % matrix_ylabel: matrix of "on" ylabels (>2 means multiple label lines)        
            % is_ylabel: '1' - only first column
            oldparamplt = obj.param_plt;
            if ~exist('nx', 'var') || isempty(nx) || nx < 1
                nx = 1;
            end
            if ~exist('ny', 'var') || isempty(ny) || ny < 1
                ny = 1;
            end
            % get param_plt (will restore param_plt to this value
            % afterwards
            obj.fig.restore_param_plt = obj.param_plt;
            % set figure parameters
            [defaultsetting_fig] = obj.setparameters_default_figure(nx, ny);
            [setting_fig, vars] = W.struct_set_parameters(defaultsetting_fig, varargin{:}, 'set');
            defaultsetting_plt = obj.param_plt;
            [setting_plt, vars] = W.struct_set_parameters(defaultsetting_plt, vars, 'set');
            [setting_fig] = obj.setparameters_shortcut_figure(setting_fig, vars);
            obj.param_plt = setting_plt;
            if isfield(vars, 'param_scale')
                obj.param_scale(vars.param_scale, setting_plt, 1);
            end
            % calculate rect_axes
            [rect, rect_axes] = obj.get_fig_ax_sizes(nx, ny, setting_fig);
            % create figure
            obj.create_figure(rect, rect_axes);
            % set optional figure param: params_matrix
            xy = cumsum(reshape(setting_fig.matrix_hole', 1,[]));
            xy(find(diff(xy) == 0) + 1) = NaN;
            xy = reshape(xy,ny,nx)';
            addABCs_offset_title = setting_fig.matrix_title | any(setting_fig.matrix_title, 2);
            obj.fig.params_matrix = struct('nx', nx, 'ny', ny, 'xy', xy, ...
                'addABCs_offset_title', addABCs_offset_title);
        end
        %% create figure
        function create_figure(obj, rect, rect_axes, isshow)
            % rect - position of the figure
            % rect_axes - position of the axes
            % isshow - whether to display to figure
            if ~exist('isshow', 'var') || isempty(isshow)
                isshow = obj.param_setting.isshow;
            end
            obj.fig.g = figure('visible', W.iif(isshow, 'on', 'off'));
            set(obj.fig.g, 'Units','pixels','position',rect);
            rect_axes = W.encell(rect_axes);
            obj.fig.n_axes = length(rect_axes);
            obj.fig.axes = [];
            for i = 1:obj.fig.n_axes
                axes('Units', 'pixels', 'position', rect_axes{i});
                obj.fig.axes(i) = gca;
                set(gca, 'tickdir', 'out');
            end
            obj.fig.axi = 1;
            obj.ax(obj.fig.axi);
            obj.fig.object_list =  repmat({[]}, 1, obj.fig.n_axes); % plot objects, for legend generation
            obj.fig.params_matrix = [];
            % clear custom_fig
            obj.custom_fig = cell(1, obj.fig.n_axes);
        end
        %% axes
        function new(obj)
            axi = obj.fig.axi;
            axi = axi + 1;
            if axi > obj.fig.n_axes
                return;
            end
            set(obj.fig.g, 'CurrentAxes', obj.fig.axes(axi));
            obj.fig.axi = axi;
        end
        function ax(obj, varargin)
            switch length(varargin)
                case 1
                    axi = varargin{1};
                case 2
                    x1 = varargin{1};
                    x2 = varargin{2};
                    axi = obj.fig.params_matrix.xy(x1, x2);
                otherwise
                    W.error('W_plt.ax: wrong number of inputs');
            end
            set(obj.fig.g, 'CurrentAxes', obj.fig.axes(axi));
            obj.fig.axi = axi;
        end
        %% setfig
        function setfig_ax(obj, varargin)
            % optional input: axi
            % optional input: 'overwrite'
            % varargin can be pairs of (name, value), or a structure
            varargin = W.encell(varargin);
            i = 1;
            if isnumeric(varargin{i})
                axi = varargin{i};
                i = i + 1;
            else
                axi = obj.fig.axi;
            end
            if length(obj.custom_fig) < axi
                W.error('W_plt.setfig_ax: custom_fig length < axi');
                return;
            end
            if W.is_stringorchar(varargin{i}) && strcmp(varargin{i}, 'overwrite')
                i = i + 1;
                obj.custom_fig{axi} = W.struct_set_parameters(obj.custom_fig{axi}, varargin{i:end}, 'overwrite');
            else
                obj.custom_fig{axi} = W.struct_set_parameters(obj.custom_fig{axi}, varargin{i:end}, 'ignore');
            end
        end
        function setfig(obj, varargin)
            i = 1;
            if isnumeric(varargin{1}) 
                id = varargin{1};
                i = i + 1;
            else
                id = 1:obj.fig.n_axes;
            end
            option = struct(varargin{i:end});
            for i = 1:length(id)
                obj.setfig_ax(id(i), option(i));
            end
        end
        function setfig_all(obj, varargin)
            i = 1;
            if isnumeric(varargin{1}) 
                id = varargin{1};
                i = i + 1;
            else
                id = 1:obj.fig.n_axes;
            end
            option = W.struct(varargin{i:end});
            for i = 1:length(id)
                obj.setfig_ax(id(i), option);
            end
        end
        %% update
        function update_preprocess(obj)
            for axi = 1:obj.fig.n_axes
                if isfield(obj.custom_fig{axi}, 'legend')
                    leg = obj.custom_fig{axi}.legend;
                    leg = W.cell_enchar(leg);
                    obj.custom_fig{axi}.legend = leg;
                end
                if isfield(obj.custom_fig{axi}, 'legloc')
                    legloc = obj.custom_fig{axi}.legloc;
                    legloc = replace(legloc, {'N','S','W','E', 'O'}, ...
                        {'North','South','West','East', 'Outside'});
                    obj.custom_fig{axi}.legloc = legloc;
                end
                if isfield(obj.custom_fig{axi}, 'legord')
                    legord = obj.custom_fig{axi}.legord;
                    if W.is_stringorchar(legord) && strcmp(legord, 'reverse')
                        legord = length(obj.fig.object_list{axi}):-1:1;
                    end
                    obj.custom_fig{axi}.legord = legord;
                end
                if isfield(obj.custom_fig{axi}, 'xticklabel')
                    xtklb = W.horz(W.str2cell(obj.custom_fig{axi}.xticklabel));
                    if size(xtklb,1) > 1
                        xtklb = strtrim(sprintf('%s\\newline%s\n', xtklb{:}));
                    end
                    obj.custom_fig{axi}.xticklabel = xtklb;
                end
            end
        end
        function update(obj, filename, ABClabels)
            arguments
                obj;
                filename = '';
                ABClabels = [];
            end
            obj.update_preprocess;
            fig = obj.fig;
            for axi = 1:fig.n_axes
                set(fig.g,'CurrentAxes',fig.axes(axi));
                pfig = obj.custom_fig{axi};
                if isempty(pfig)
                    continue;
                end
                % set font size
                set(gca, 'FontSize', obj.param_plt.fontsize_axes);
                fnms = fieldnames(pfig);
                for fi = 1:length(fnms)
                    switch fnms{fi}
                        case 'xlim'
                            if ~isempty(pfig.xlim)
                                xlim(pfig.xlim);
                            end
                        case 'ylim'
                            if ~isempty(pfig.ylim)
                                ylim(pfig.ylim);
                            end
                        case 'xlabel'
                            pfig.xlabel = W.str_capitalize1(pfig.xlabel);
                            xlabel(pfig.xlabel, 'FontSize', obj.param_plt.fontsize_label);
                        case 'ylabel'
                            pfig.ylabel = W.str_capitalize1(pfig.ylabel);
                            ylabel(pfig.ylabel, 'FontSize', obj.param_plt.fontsize_label);
                        case 'title'
                            pfig.title = W.str_capitalize1(pfig.title);
                            pfig.title = W.str_de_(pfig.title);
                            title(pfig.title,'FontWeight','normal','FontSize', obj.param_plt.fontsize_title);
                        case 'xtick'
                            if isfield(pfig, 'xticklabel')
                                set(gca,'XTick', pfig.xtick, 'XTickLabel', pfig.xticklabel, ...
                                    'XTickLabelRotation', 0);
                            else
                                set(gca,'XTick', pfig.xtick);
                            end
                        case 'ytick'
                            if isfield(pfig, 'yticklabel')
                                set(gca,'YTick', pfig.ytick, 'YTickLabel', pfig.yticklabel);
                            else
                                set(gca,'YTick', pfig.ytick);
                            end
                        case 'legend'
                            if isfield(pfig, 'legloc')
                                legloc = pfig.legloc;
                            else
                                legloc = 'NorthEast';
                            end
                            leglist = fig.object_list{axi};
                            leg = pfig.legend;
%                             leg = W.str_de_(leg);
%                             leg = W.str_capitalize1(leg);
                            if length(leg) == length(leglist)
                                if isfield(pfig, 'legord')
                                    leg = leg(pfig.legord);
                                    leglist = leglist(pfig.legord);
                                end
                                tpos = get(obj.fig.axes(axi), 'position');
                                legend(leglist, leg, 'Location', legloc, ...
                                    'FontSize', obj.param_plt.fontsize_leg);
                                legend('boxoff');
                                set(obj.fig.axes(axi), 'position', tpos);
                            elseif length(leg) > 0
                                W.warning('W_plt.update: axes #%d legend ignored, number of legend entries != number of plots', axi);
                            end
                        case {'xticklabel', 'yticklabel','legloc','legord'}
                            % skip, these are dealt with in xtick/ytick, legend/legord
                        otherwise
                            W.warning('W_plt.update: unused param %s', fnms{fi});
                    end
                end
            end
            obj.addABCs([],ABClabels);
            if ~isempty(filename)
                obj.save(filename);
            end
            obj.param_plt = obj.fig.restore_param_plt;
        end
        %% addABC
        function addABCs(obj, offset, abcString)
            ax = obj.fig.axes;
            fontsize = obj.param_plt.fontsize_title;
            if ~exist('abcString', 'var') || isempty(abcString)
                abcString = ['ABCDEFGHIJKLMNOPQRSTUVWXYZ'];
            end
            for i = 1:length(ax)
                pos(i,:) = get(ax(i), 'position');
            end
            ABCpos = [pos(:,1) pos(:,2)+pos(:,4)];
            if ~exist('offset', 'var') || isempty(offset)
                offset_title = arrayfun(@(x)obj.fig.params_matrix.addABCs_offset_title(obj.fig.params_matrix.xy == x) * ...
                    obj.param_plt.addABCs_offset_title, 1:obj.fig.n_axes);
                offset = obj.param_plt.addABCs_offset + zeros(obj.fig.n_axes, 1);
                offset(:,2) = offset(:,2) + offset_title';
            end
            ABCpos = ABCpos + offset;
            for i = 1:length(ax)
                tb = annotation('textbox');
                set(tb, 'fontsize', fontsize, 'fontweight', 'normal', ...
                    'margin', 0, 'horizontalAlignment', 'center', ...
                    'verticalAlignment', 'middle', 'lineStyle', 'none')
                set(tb, 'fontunits', 'pixels')
                fs = get(tb, 'fontsize');
                set(tb, 'fontunits', 'points')
                set(tb, 'string', abcString(i))
                rec = [ABCpos(i,1), ABCpos(i,2), fs, fs];
                set(tb, 'Units','pixels', 'position', rec)
            end
        end
        %% save
        function filefullpath = savename(obj, filename, extension)
            if ~exist('extension', 'var')
                extension = obj.param_setting.extension;
            end
            filename = W.file_prefix(filename, obj.param_setting.savepfx);
            filename = W.file_suffix(filename, obj.param_setting.savesfx);
            filename = W.enext(filename, extension);
            savedir = W.mkdir(obj.param_setting.savedir);
            filefullpath = fullfile(savedir, filename);
            if exist(filefullpath, 'file')
                disp('warning - figure exists');
            end
        end
        function save(obj, filename, extension)
            if ~(obj.param_setting.issave) % && isempty(obj.param_setting.savedir)
                return;
            end
            if ~exist('extension', 'var')
                extension = obj.param_setting.extension;
            end
            extension = W.str2cell(extension);
            for ei = 1:length(extension)
                savename = obj.savename(filename, extension{ei});
                switch extension{ei}
                    case 'emf' % not sure if it works
                        if ispc
                            set(obj.fig.g, 'Color', 'white', 'Inverthardcopy', 'off');
                            print –dmeta;
                            print(obj.fig.g, savename, '-dmeta');
                        else
                            disp('unable to save .emf in mac');
                        end
                    case 'eps' % not sure if it works
                        exportgraphics(obj.fig.g, savename);
                    otherwise
                        saveas(obj.fig.g, savename, extension{ei});
                end
            end
        end
        %% assist functions
        % figure - initialize parameters
        function [defaultsetting_fig] = setparameters_default_figure(~, nx, ny)
            matrix_hole = ones(nx, ny);
            matrix_title = zeros(nx, ny);
            matrix_xlabel = ones(nx, ny);
            matrix_ylabel = ones(nx, ny);
            gapH_custom = zeros(1,nx+1);
            gapW_custom = zeros(1,ny+1);
            defaultsetting_fig = struct('matrix_hole', matrix_hole, ...
                'matrix_title', matrix_title, ...
                'matrix_xlabel', matrix_xlabel, 'matrix_ylabel', matrix_ylabel, ...
                'gapH_custom', gapH_custom, 'gapW_custom', gapW_custom); 
        end
        % figure - shortcut parameters
        function [vars] = setparameters_shortcut_figure(~, vars, options)
            % vars is a structure
            if isfield(options, 'is_title') 
                switch options.is_title
                    case {'1', 1}
                        vars.matrix_title(1,:) = 1;
                    case 'all'
                        vars.matrix_title = ones(size(vars.matrix_title));
                end
            end
            if isfield(options, 'is_xlabel')
                switch options.is_xlabel
                    case {'1', 1}
                        vars.matrix_xlabel(1:end-1,:) = 0;
                end
            end
            if isfield(options, 'is_ylabel')
                switch options.is_ylabel
                    case {'1', 1}
                        vars.matrix_ylabel(:,2:end) = 0;
                end
            end
        end
        % figure - calculate rect_axes
        function [rect, rect_axes] = get_fig_ax_sizes(obj, nx, ny, setting_fig)
            [ax_h, ax_w, gap_h, gap_w, figH, figW] = obj.axes_calculate_pos(nx, ny, setting_fig);
            sz = obj.get_screensize();
            rr = max(figH/(sz(4)*0.9), figW/(sz(3)*0.9)); % if doesn't exceed screen size, return 1
            if rr > 1
                obj.param_scale(1/rr, [], 1);
                [ax_h, ax_w, gap_h, gap_w, figH, figW] = obj.axes_calculate_pos(nx, ny, setting_fig);
            end
            offset = sz(4) * 0.05;
            [rect_axes, rect] = obj.axes_pos2rect(ax_h, ax_w, gap_h, gap_w, setting_fig.matrix_hole, offset);
            % calculate rect
        end
        function [ax_h, ax_w, gap_h, gap_w, figH, figW] = axes_calculate_pos(obj, nx, ny, setting_fig)
            setting_plt = obj.param_plt;
            is_xlab = W.horz(any(setting_fig.matrix_xlabel, 2));
            is_ylab = W.horz(any(setting_fig.matrix_ylabel, 1));
            is_title = W.horz(any(setting_fig.matrix_title, 2));
            ax_h = repmat(setting_plt.pixel_h, 1, nx);
            ax_w = repmat(setting_plt.pixel_w, 1, ny);
            gap_h = [setting_plt.pixel_margin(3), ones(1,nx-1)*setting_plt.pixel_gap_h, setting_plt.pixel_margin(1)] + ...
                [0, is_xlab * setting_plt.pixel_xlab] + ...
                [is_title * setting_plt.pixel_title, 0] + ...
                setting_fig.gapH_custom;
            gap_w = [setting_plt.pixel_margin(2), ones(1,ny-1)*setting_plt.pixel_gap_w, setting_plt.pixel_margin(4)] + ...
                [is_ylab * setting_plt.pixel_ylab, 0] + ...
                setting_fig.gapW_custom;
            figH = sum(ax_h) + sum(gap_h);
            figW = sum(ax_w) + sum(gap_w);
        end
        function [rect_axes, rect] = axes_pos2rect(obj, ax_h, ax_w, gap_h, gap_w, matrix_hole, offset)
            % ax_h/gap_h, up to down
            % ax_w/gap_w, left to right
            % calculate relative rect_axes
            % [0(bottom) 0(left) 1(up) 1(right)]
            if ~exist('offset', 'var')
                offset = [0 0];
            end
            % normalize ax_h, ax_w, gap_h, gap_w
            figH = sum(ax_h) + sum(gap_h);
            figW = sum(ax_w) + sum(gap_w);
            % compute axes_rect
            nw = length(ax_w);
            nh = length(ax_h);
            rect_axes = {};
            count = 0;
            for xi = 1:nh 
                for yi = 1:nw
                    if matrix_hole(xi, yi) == 1
                        bx(1) = sum(gap_w(1:yi)) + sum(ax_w(1:yi-1));
                        bx(2) = sum(gap_h(xi+1:end)) + sum(ax_h(xi+1:end));
                        bx(3) = ax_w(yi);
                        bx(4) = ax_h(xi);
                        count = count + 1;
                        rect_axes{count} = bx;
                    end
                end
            end
            rect = [[0, 0] + offset, figW, figH];
        end
        function sz = get_screensize(obj, screenID)
            if ~exist('screenID', 'var') 
                screenID = 0;
            end
            set(screenID,'units','pixels');
            sz = get(screenID,'screensize');
        end
    end
end