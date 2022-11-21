classdef inputTextBox < handle
    properties
        window
        nx
        ny
        edgeWidth_on
        edgeWidth_off
        edgeColor_on
        edgeColor_off
        textSize
        textColor
        bgColor
        string
        max_string
        edgeRect
        borderRect
        pad
        cornerPosition
        isOn
        legalkey
    end
    methods
        function obj = inputTextBox(window,legalkey)
            obj.window = window;
            obj.legalkey = legalkey;
        end
        function setup(obj,pos, nx, ny, ...
                edgeWidth_on, edgeWidth_off, edgeColor_on, edgeColor_off, ...
                textSize, textColor, bgColor, pad)
            obj.cornerPosition  = pos;
            obj.nx              = nx;
            obj.ny              = ny;
            obj.edgeWidth_on    = edgeWidth_on;
            obj.edgeWidth_off   = edgeWidth_off;
            obj.textSize        = textSize;
            obj.textColor       = textColor;
            obj.edgeColor_on    = edgeColor_on;
            obj.edgeColor_off   = edgeColor_off;
            obj.bgColor         = bgColor;
            obj.isOn            = false;
            obj.string = [];
            % make max_string to get bounding box
            max_string(1:nx,1:ny) = 'X';
            obj.max_string = max_string(:)';
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            [~,~,textbounds] = DrawFormattedText(obj.window, obj.max_string, pos(1), pos(2), obj.textColor);
            Screen('TextSize', obj.window, oldTextSize);
            obj.edgeRect = textbounds;
            obj.pad = pad;
            obj.borderRect = obj.edgeRect + obj.pad/2*[-1 -1 1 1];
        end
        function setCornerPosition(obj, pos)
            obj.cornerPosition = pos;
            edgeRect = obj.edgeRect;
            edgeRect = edgeRect - [edgeRect(1:2) edgeRect(1:2)];
            obj.edgeRect = edgeRect + [pos pos];
            obj.borderRect = obj.edgeRect + obj.pad/2*[-1 -1 1 1];
        end
        function draw(obj)
            switch obj.isOn
                case 0
                    Screen('FrameRect', obj.window, obj.edgeColor_off, obj.borderRect, obj.edgeWidth_off);
                case 1
                    Screen('FrameRect', obj.window, obj.edgeColor_on, obj.borderRect, obj.edgeWidth_on);
            end
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            DrawFormattedText(obj.window, obj.string, obj.edgeRect(1), obj.edgeRect(2), obj.textColor);
            Screen('TextSize', obj.window, oldTextSize);
        end
        function check(obj,x,y)
            if (x > obj.edgeRect(1)) & (x < obj.edgeRect(3)) ...
                    & (y > obj.edgeRect(2)) & (y < obj.edgeRect(4))
                obj.isOn = 1;
                WaitSecs(0.05);
            end
            if obj.isOn 
                obj.enterText;
            end
        end
        function enterText(obj)
            x = obj.edgeRect(1);
            y = obj.edgeRect(2);
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            string = obj.string;
            output = [string 'I'];
            Screen('DrawText', obj.window, output, x, y, obj.textColor, obj.bgColor);
            dontclear = 1;
            Screen('Flip', obj.window, [], dontclear);
            while true
                out = getKbCharOrClick(obj.window);
                switch out.what
                    case 'keyPress'
                        char = KbName(out.ch);
                        switch (abs(out.ch))
                            case KbName('Return')
                                % enter
                                obj.isOn = false;
                                break;
                            case KbName('delete')
                                % backspace
                                if ~isempty(string)
%                                     oldTextColor = Screen('TextColor', obj.window);
%                                     Screen('DrawText', obj.window, output, x, y, obj.bgColor, obj.bgColor);
%                                     Screen('TextColor', obj.window, oldTextColor);
                                    % Remove last character from string:
                                    string = string(1:length(string)-1);
                                end
                            otherwise
%                                 obj.legalkey
                                if ismember(out.ch,obj.legalkey)
                                    string = [string, char(1)] %#ok<AGROW>
                                else
                                    continue;
                                end
                        end
                        oldTextColor = Screen('TextColor', obj.window);
                        Screen('DrawText', obj.window, output, x, y, obj.bgColor, obj.bgColor);
                        Screen('TextColor', obj.window, oldTextColor);
                        output = [string 'I'];
                        Screen('DrawText', obj.window, output, x, y, obj.textColor, obj.bgColor);
                        Screen('Flip', obj.window, [], dontclear);
                        KbReleaseWait;
                    case 'click'
%                         % is the click outside THIS box?
                        chk = (out.x > obj.edgeRect(1)) ...
                            & (out.x < obj.edgeRect(3)) ...
                            & (out.y > obj.edgeRect(2)) ...
                            & (out.y < obj.edgeRect(4));
                    switch chk
                            case 0
                                % box turned off so click was outside
                                obj.isOn = false;
                                break;
                            case 1
                    end     
                end
            end
            obj.string = string;
            Screen('TextSize', obj.window, oldTextSize);
        end
    end
end