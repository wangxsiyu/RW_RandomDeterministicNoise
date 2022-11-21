classdef pushButtonText < handle
    properties
        window
        
        textSize
        textColor
        textPosition
        cornerPosition
        string
        margin
        
%         isOn
        bt
    end
    methods
        function obj = pushButtonText(window)
            obj.window = window;
            obj.bt = pushButton(window);
        end
        function setup(obj,textSize,textColor,string,edgeColor,onColor,offColor,edgeWidth,radius,fillFrac,margin)
            obj.textSize = textSize;
            obj.textColor = textColor;
            obj.string = string;
            obj.margin = margin;
            obj.bt.setup(edgeColor,onColor,offColor,edgeWidth,radius,fillFrac);
        end
        function setCornerPosition(obj, pos)
            obj.cornerPosition  = pos;            
            obj.bt.setCornerPosition(pos);
            obj.textPosition    = obj.cornerPosition + [obj.bt.radius + obj.margin -0.2*obj.textSize];
        end
        function draw(obj)
            sx = obj.textPosition(1);
            sy = obj.textPosition(2);
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            DrawFormattedText(obj.window, obj.string, sx, sy, obj.textColor);
            Screen('TextSize', obj.window, oldTextSize);
            obj.bt.draw;
        end
        function check(obj,x,y)
            obj.bt.check(x,y);
%             obj.isOn = obj.bt.isOn;
        end
    end
end