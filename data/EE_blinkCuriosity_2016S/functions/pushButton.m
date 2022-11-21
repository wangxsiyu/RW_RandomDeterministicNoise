classdef pushButton < handle
    properties
        window
        edgeWidth
        edgeColor
        edgeRect
        onColor
        offColor
        centerPosition
        fillFrac
        fillRect 
        radius
        isOn
    end
    methods
        function obj = pushButton(window)
            obj.window = window;
        end
        function setup(obj,edgeColor,onColor,offColor,edgeWidth,radius,fillFrac)
            obj.edgeWidth = edgeWidth;
            obj.edgeColor = edgeColor;
            obj.onColor = onColor;
            obj.offColor = offColor;
            obj.radius      = radius;
            obj.fillFrac    = fillFrac;
            obj.isOn        = false;
        end
        function setCornerPosition(obj, pos)
            obj.edgeRect        = [pos(1) pos(2) pos(1) pos(2)] + [0 0 1 1]*obj.radius;
            obj.centerPosition  = obj.edgeRect(1:2) + obj.radius/2;
            obj.fillRect        = ...
                [obj.centerPosition(1:2) obj.centerPosition(1:2)] ...
                +[-1 -1 +1 +1]*obj.radius/2*obj.fillFrac;
        end
        function draw(obj)
            if obj.isOn
                Screen('FillOval', obj.window, obj.onColor, obj.fillRect);
            else
                Screen('FillOval', obj.window, obj.offColor, obj.fillRect);
            end
            Screen('FrameOval', obj.window, obj.edgeColor, obj.edgeRect, obj.edgeWidth);
        end
        function check(obj, x, y)
            if (x > obj.edgeRect(1)) & (x < obj.edgeRect(3)) ...
                    & (y > obj.edgeRect(2)) & (y < obj.edgeRect(4))
                obj.isOn = ~obj.isOn;
                WaitSecs(0.1);
            end
        end
    end 
end