classdef boxQuestion < handle
    properties
        window
        qString
        qTextSize
        qTextColor
        qPos
        margin
        bx
        legalkey
    end
    methods
        function obj = boxQuestion(window)
            obj.window = window;
        end
        function setup(obj,qString,nx,ny)
            obj.qString     = qString;
            obj.qTextSize   = 30;
            colorscale = 1;
            obj.qTextColor  = [1 1 1]*colorscale;
            
            % to keep this simple have it be a set size
            pos = [100 500];
            
            edgeWidth_on = 5;
            edgeWidth_off = 2;
            edgeColor_off = [1 1 1]*colorscale;
            edgeColor_on = [1 1 1]*colorscale;
            textSize = 50;
            textColor = [1 1 1]*colorscale;
            bgColor = [0 0 0]*colorscale;
            pad = 40;
            obj.margin = [pad/2,obj.qTextSize*2.2];
            obj.bx = inputTextBox(obj.window,obj.legalkey);
            obj.bx.setup(pos+obj.margin, nx, ny, ...
                edgeWidth_on, edgeWidth_off, edgeColor_on, edgeColor_off, ...
                textSize, textColor, bgColor, pad);
        end
        function setCornerPosition(obj, pos)
            obj.qPos = pos;
            obj.bx.setCornerPosition(pos+obj.margin);
        end
        function draw(obj)
            sx = obj.qPos(1);
            sy = obj.qPos(2);
            oldTextSize = Screen('TextSize', obj.window, obj.qTextSize);
            DrawFormattedText(obj.window, obj.qString, sx, sy, obj.qTextColor);
            Screen('TextSize', obj.window, oldTextSize);
            obj.bx.draw;
        end        
        function check(obj, x, y)
            obj.bx.check(x,y);
        end
    end
end